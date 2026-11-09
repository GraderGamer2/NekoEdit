#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

char **process_envp;
extern char **environ;

extern uint32_t compose_locale_active;
extern char compose_locale_current_tag[32];
extern char compose_locale_installed_tag[32];
uint32_t compose_locale_install_pack(const char *source_path);
uint32_t compose_locale_remove_pack(const char *tag);
uint32_t compose_locale_get_directory(char *destination, uint32_t capacity);
uint32_t compose_locale_load(const char *tag);
uint32_t compose_locale_lookup(uint32_t input_count,
                              const uint32_t *input, uint32_t *output);

static void fail(const char *message)
{
    fprintf(stderr, "Compose locale manager test: %s\n", message);
    exit(1);
}

int main(int argc, char **argv)
{
    char app_path[4096], locale_dir[4096], installed_path[4096];
    char actual_directory[4096], expected_directory[4096];
    struct stat st;
    uint32_t input[2] = { 'o', 'i' }, output[8] = {0};
    uint32_t output_count;

    if (argc != 5)
        fail("expected HOME, valid pack, corrupt pack and symlink path");
    if (setenv("HOME", argv[1], 1) < 0)
        fail("could not set HOME");
    process_envp = environ;

    if (!compose_locale_get_directory(actual_directory, sizeof(actual_directory)))
        fail("private locale directory could not be resolved");
    if (snprintf(expected_directory, sizeof(expected_directory),
                 "%s/.nekoedit/locales", argv[1]) <= 0 ||
        strcmp(actual_directory, expected_directory) != 0)
        fail("locale destination is not HOME/.nekoedit/locales");

    if (!compose_locale_install_pack(argv[2]))
        fail("valid pack was not installed");
    if (strcmp(compose_locale_installed_tag, "pt_BR.UTF-8") != 0)
        fail("installed tag did not match the pack header");

    if (snprintf(app_path, sizeof(app_path), "%s/.nekoedit", argv[1]) <= 0 ||
        snprintf(locale_dir, sizeof(locale_dir), "%s/.nekoedit/locales", argv[1]) <= 0 ||
        snprintf(installed_path, sizeof(installed_path),
                 "%s/.nekoedit/locales/pt_BR.UTF-8.nlp", argv[1]) <= 0)
        fail("could not construct destination paths");

    if (stat(app_path, &st) < 0 || (st.st_mode & 0777) != 0700)
        fail("application directory must be mode 0700");
    if (stat(locale_dir, &st) < 0 || (st.st_mode & 0777) != 0700)
        fail("locale directory must be mode 0700");
    if (stat(installed_path, &st) < 0 || (st.st_mode & 0777) != 0600)
        fail("installed pack must be a mode-0600 regular file");
    if (!S_ISREG(st.st_mode))
        fail("installed destination is not a regular file");

    if (!compose_locale_load("pt_BR.UTF-8") || !compose_locale_active)
        fail("installed pack could not be loaded after installation");
    output_count = compose_locale_lookup(2, input, output);
    if (output_count != 2 || output[0] != 0x2603 || output[1] != 0xfe0f)
        fail("installed pack did not resolve the expected multiscalar sequence");

    if (compose_locale_install_pack(argv[3]))
        fail("CRC-corrupt source pack was accepted");
    if (compose_locale_install_pack(argv[4]))
        fail("symlink source pack was followed");
    if (!compose_locale_load("pt_BR.UTF-8") ||
        compose_locale_lookup(2, input, output) != 2 ||
        output[0] != 0x2603 || output[1] != 0xfe0f)
        fail("rejected imports damaged the existing installed pack");

    if (compose_locale_remove_pack("../escape"))
        fail("unsafe locale tag was accepted for removal");
    if (!compose_locale_remove_pack("pt_BR.UTF-8"))
        fail("valid installed pack could not be removed");
    if (lstat(installed_path, &st) == 0)
        fail("removed pack remains on disk");
    if (compose_locale_active ||
        strcmp(compose_locale_current_tag, "en_US.UTF-8") != 0)
        fail("removing the active pack did not restore built-in en_US");
    if (compose_locale_load("pt_BR.UTF-8"))
        fail("removed pack could still be loaded");
    if (compose_locale_remove_pack("pt_BR.UTF-8"))
        fail("missing pack was reported as removed");

    puts("Compose locale manager tests passed (validation, safe install, permissions, activation, corrupt/symlink rejection, safe removal).");
    return 0;
}
