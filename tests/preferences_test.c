#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

char **process_envp;
extern char **environ;

int32_t doc_font_size = 12;
int32_t ui_font_size = 10;
int32_t doc_wrap_enabled = 1;
int32_t save_confirm_enabled = 1;
extern int32_t clipboard_persistence_enabled;
extern char *preferences_font_path_ptr;

int preferences_load(void);
int preferences_save(void);
void preferences_set_font_path(const char *path);

static void fail(const char *message)
{
    fprintf(stderr, "preferences test: %s\n", message);
    exit(1);
}

static void refresh_environment(void)
{
    process_envp = environ;
}

static void reset_defaults(void)
{
    doc_font_size = 12;
    ui_font_size = 10;
    doc_wrap_enabled = 1;
    save_confirm_enabled = 1;
    clipboard_persistence_enabled = 1;
    preferences_font_path_ptr = NULL;
}

static void expect_defaults(void)
{
    if (doc_font_size != 12 || ui_font_size != 10 ||
        doc_wrap_enabled != 1 || save_confirm_enabled != 1 ||
        clipboard_persistence_enabled != 1)
        fail("invalid entries changed one or more default preferences");
}

static void read_config(const char *path, char *buffer, size_t capacity)
{
    FILE *file = fopen(path, "rb");
    size_t length;
    if (!file)
        fail("could not open saved preferences");
    length = fread(buffer, 1, capacity - 1, file);
    if (ferror(file))
        fail("could not read saved preferences");
    buffer[length] = 0;
    fclose(file);
}

int main(void)
{
    char root[] = "/tmp/nekoedit-preferences-XXXXXX";
    char app_directory[512];
    char file_path[512];
    char contents[8192];
    struct stat st;

    if (!mkdtemp(root))
        fail("mkdtemp failed");
    if (setenv("HOME", root, 1) < 0)
        fail("could not set HOME");
    if (setenv("XDG_CONFIG_HOME", root, 1) < 0)
        fail("could not set the ignored XDG_CONFIG_HOME fixture");
    unsetenv("NEKOEDIT_DISABLE_PREFERENCES");
    refresh_environment();

    reset_defaults();
    if (preferences_load() != 0)
        fail("missing configuration unexpectedly loaded");
    expect_defaults();

    doc_font_size = 28;
    ui_font_size = 15;
    doc_wrap_enabled = 0;
    save_confirm_enabled = 0;
    clipboard_persistence_enabled = 0;
    preferences_set_font_path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf");
    if (!preferences_font_path_ptr)
        fail("absolute TrueType path was not retained");
    if (!preferences_save())
        fail("atomic preference save failed");

    if (snprintf(app_directory, sizeof(app_directory), "%s/.nekoedit", root) <= 0 ||
        snprintf(file_path, sizeof(file_path), "%s/preferences", app_directory) <= 0)
        fail("could not construct configuration test path");
    if (stat(app_directory, &st) < 0)
        fail("~/.nekoedit directory was not created");
    if ((st.st_mode & 0777) != 0700)
        fail("~/.nekoedit directory permissions are not 0700");
    if (stat(file_path, &st) < 0)
        fail("preferences file was not created");
    if ((st.st_mode & 0777) != 0600)
        fail("preferences file permissions are not 0600");
    if (snprintf(contents, sizeof(contents), "%s/nekoedit", root) <= 0)
        fail("could not construct ignored XDG path");
    if (stat(contents, &st) == 0)
        fail("XDG_CONFIG_HOME should not be used for preference storage");

    read_config(file_path, contents, sizeof(contents));
    if (!strstr(contents, "version=1\n") ||
        !strstr(contents, "document_font_size=28\n") ||
        !strstr(contents, "ui_font_size=15\n") ||
        !strstr(contents, "wrap_lines=0\n") ||
        !strstr(contents, "confirm_before_save=0\n") ||
        !strstr(contents, "clipboard_persistence=0\n") ||
        !strstr(contents, "font_path=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf\n"))
        fail("saved configuration is missing one or more values");

    reset_defaults();
    refresh_environment();
    if (preferences_load() != 1)
        fail("existing preferences did not load");
    if (doc_font_size != 28 || ui_font_size != 15 ||
        doc_wrap_enabled != 0 || save_confirm_enabled != 0 ||
        clipboard_persistence_enabled != 0)
        fail("preference roundtrip changed one or more values");
    if (!preferences_font_path_ptr ||
        strcmp(preferences_font_path_ptr,
               "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf") != 0)
        fail("font path did not roundtrip");

    preferences_set_font_path("relative-font.ttf");
    if (preferences_font_path_ptr)
        fail("relative font path should not be persisted");
    preferences_set_font_path("/tmp/font\nbreak.ttf");
    if (preferences_font_path_ptr)
        fail("newline-containing font path should not be persisted");

    {
        FILE *file = fopen(file_path, "wb");
        if (!file)
            fail("could not write malformed-configuration fixture");
        fputs("version=1\n"
              "document_font_size=99\n"
              "ui_font_size=7\n"
              "wrap_lines=2\n"
              "confirm_before_save=9\n"
              "clipboard_persistence=9\n"
              "font_path=relative.ttf\n", file);
        fclose(file);
    }
    reset_defaults();
    refresh_environment();
    if (preferences_load() != 1)
        fail("malformed configuration could not be read");
    expect_defaults();
    if (preferences_font_path_ptr)
        fail("relative or invalid font path was accepted");

    if (setenv("NEKOEDIT_DISABLE_PREFERENCES", "1", 1) < 0)
        fail("could not disable preference storage");
    refresh_environment();
    doc_font_size = 22;
    ui_font_size = 13;
    doc_wrap_enabled = 0;
    save_confirm_enabled = 0;
    preferences_font_path_ptr = NULL;
    clipboard_persistence_enabled = 0;
    if (preferences_load() != 0)
        fail("disabled preference load should be a no-op");
    if (doc_font_size != 22 || ui_font_size != 13 ||
        doc_wrap_enabled != 0 || save_confirm_enabled != 0 ||
        clipboard_persistence_enabled != 0)
        fail("disabled preference load overwrote runtime values");
    if (preferences_save() != 0)
        fail("disabled preference save unexpectedly succeeded");

    unlink(file_path);
    rmdir(app_directory);
    rmdir(root);
    puts("Persistent preferences tests passed (validation, roundtrip, file mode, disable switch).");
    return 0;
}
