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
extern int32_t text_input_opt_in;
extern char *preferences_font_path_ptr;
extern char *preferences_locale_ptr;
int preferences_locale_is_pt_br(void);
int preferences_locale_is_builtin(void);
int preferences_set_locale_tag(const char *tag);

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
    text_input_opt_in = 0;
    preferences_font_path_ptr = NULL;
    preferences_locale_ptr = NULL;
}

static void expect_defaults(void)
{
    if (doc_font_size != 12 || ui_font_size != 10 ||
        doc_wrap_enabled != 1 || save_confirm_enabled != 1 ||
        clipboard_persistence_enabled != 1 || text_input_opt_in != 0)
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
    unsetenv("NEKOEDIT_ENABLE_TEXT_INPUT");
    refresh_environment();

    reset_defaults();
    if (preferences_load() != 0)
        fail("missing configuration unexpectedly loaded");
    expect_defaults();
    if (preferences_locale_is_builtin())
        fail("unset locale preference must remain distinguishable from explicit en_US");

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


    if (!preferences_set_locale_tag("pt_BR.UTF-8") ||
        !preferences_locale_is_pt_br() || !preferences_locale_ptr ||
        strcmp(preferences_locale_ptr, "pt_BR.UTF-8") != 0)
        fail("valid Brazilian Portuguese locale preference was not accepted");
    if (!preferences_save())
        fail("locale preference could not be persisted");
    read_config(file_path, contents, sizeof(contents));
    if (!strstr(contents, "compose_locale=pt_BR.UTF-8\n"))
        fail("locale tag is missing from saved preferences");

    if (!preferences_set_locale_tag("en_US.UTF-8") ||
        preferences_locale_is_pt_br() || !preferences_locale_is_builtin() || !preferences_save())
        fail("built-in en_US locale preference could not be saved");
    if (!preferences_set_locale_tag("en_US") || !preferences_locale_is_builtin() ||
        !preferences_set_locale_tag("C") || !preferences_locale_is_builtin() ||
        !preferences_set_locale_tag("C.UTF-8") || !preferences_locale_is_builtin() ||
        !preferences_set_locale_tag("POSIX") || !preferences_locale_is_builtin())
        fail("a built-in locale alias was not recognized");
    if (!preferences_set_locale_tag("aa_TEST.UTF-8") || preferences_locale_is_builtin())
        fail("a generic installed locale tag was misclassified as built-in");
    read_config(file_path, contents, sizeof(contents));
    if (!strstr(contents, "compose_locale=en_US.UTF-8\n"))
        fail("built-in locale selection did not roundtrip");

    if (preferences_set_locale_tag("../outside") ||
        preferences_set_locale_tag("pt_BR.UTF-8/../../outside") ||
        preferences_set_locale_tag("bad\nlocale"))
        fail("unsafe locale tag was accepted");
    if (!preferences_set_locale_tag("pt_BR.UTF-8") || !preferences_save())
        fail("valid locale could not be restored after rejected input");
    if (preferences_locale_is_builtin())
        fail("pt_BR was incorrectly classified as a built-in locale");

    reset_defaults();
    refresh_environment();
    if (preferences_load() != 1)
        fail("existing preferences did not load");
    if (!preferences_locale_is_pt_br())
        fail("persisted pt_BR locale did not survive reload");
    if (doc_font_size != 28 || ui_font_size != 15 ||
        doc_wrap_enabled != 0 || save_confirm_enabled != 0 ||
        clipboard_persistence_enabled != 0)
        fail("preference roundtrip changed one or more values");
    if (!preferences_font_path_ptr ||
        strcmp(preferences_font_path_ptr,
               "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf") != 0)
        fail("font path did not roundtrip");

    if (setenv("NEKOEDIT_ENABLE_TEXT_INPUT", "1", 1) < 0)
        fail("could not enable optional text-input-v3 for test");
    refresh_environment();
    if (preferences_load() != 1 || text_input_opt_in != 1)
        fail("explicit text-input-v3 opt-in was not recognized");
    if (unsetenv("NEKOEDIT_ENABLE_TEXT_INPUT") < 0)
        fail("could not clear optional text-input-v3 opt-in");
    refresh_environment();
    if (preferences_load() != 1 || text_input_opt_in != 0)
        fail("text-input-v3 was not disabled by default");

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
    if (setenv("NEKOEDIT_ENABLE_TEXT_INPUT", "1", 1) < 0)
        fail("could not enable text-input-v3 with preference storage disabled");
    refresh_environment();
    doc_font_size = 22;
    ui_font_size = 13;
    doc_wrap_enabled = 0;
    save_confirm_enabled = 0;
    preferences_font_path_ptr = NULL;
    clipboard_persistence_enabled = 0;
    if (preferences_load() != 0)
        fail("disabled preference load should be a no-op");
    if (text_input_opt_in != 1)
        fail("text-input-v3 opt-in should work when stored preferences are disabled");
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
