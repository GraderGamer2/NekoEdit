#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <xkbcommon/xkbcommon.h>
#include <xkbcommon/xkbcommon-keysyms.h>

extern int xkb_parse_keymap(const char *text, uint32_t size);
extern uint32_t xkb_keymap_ready;
extern uint32_t xkb_parse_error_stage;
extern uint32_t xkb_parse_error_offset;
extern uint32_t xkb_parse_error_token_length;
extern char xkb_parse_error_token[64];
extern uint32_t xkb_unicode_levels[256u * 4u * 8u];

/*
 * xkb_unicode_levels is the application-facing lookup table: ordinary
 * symbols are Unicode scalars, while Multi_key/dead keys use NekoEdit's
 * reserved 0x110000 action range. xkb_keysym_levels is intentionally only
 * for raw modifier keysyms and must not be used to verify printable/actions.
 */
static int
check_symbol(struct xkb_keymap *keymap,
             const char *label,
             xkb_keysym_t wanted,
             uint32_t expected_value)
{
    xkb_keycode_t min_keycode = xkb_keymap_min_keycode(keymap);
    xkb_keycode_t max_keycode = xkb_keymap_max_keycode(keymap);
    unsigned matches = 0;

    for (xkb_keycode_t keycode = min_keycode; keycode <= max_keycode; ++keycode) {
        if (keycode >= 256u)
            continue;

        xkb_layout_index_t layouts = xkb_keymap_num_layouts_for_key(keymap, keycode);
        if (layouts > 4u)
            layouts = 4u;

        for (xkb_layout_index_t group = 0; group < layouts; ++group) {
            xkb_level_index_t levels =
                xkb_keymap_num_levels_for_key(keymap, keycode, group);
            if (levels > 8u)
                levels = 8u;

            for (xkb_level_index_t level = 0; level < levels; ++level) {
                const xkb_keysym_t *symbols = NULL;
                int count = xkb_keymap_key_get_syms_by_level(
                    keymap, keycode, group, level, &symbols);
                if (count <= 0 || symbols == NULL)
                    continue;

                bool found = false;
                for (int i = 0; i < count; ++i) {
                    if (symbols[i] == wanted) {
                        found = true;
                        break;
                    }
                }
                if (!found)
                    continue;

                size_t index = (size_t)keycode * 32u +
                               (size_t)group * 8u + (size_t)level;
                uint32_t parsed = xkb_unicode_levels[index];
                if (parsed != expected_value) {
                    fprintf(stderr,
                            "XKB parser mismatch for %s at keycode %u, group %u, level %u: "
                            "expected 0x%08x, got 0x%08x\n",
                            label, keycode, group, level, expected_value, parsed);
                    return 1;
                }
                ++matches;
            }
        }
    }

    if (matches == 0u) {
        fprintf(stderr, "libxkbcommon did not expose %s in us(intl)\n", label);
        return 1;
    }
    printf("verified %-16s at %u keymap position(s) -> 0x%08x\n",
           label, matches, expected_value);
    return 0;
}

int
main(void)
{
    const struct xkb_rule_names names = {
        .rules = "evdev",
        .model = "pc105",
        .layout = "us",
        .variant = "intl",
        .options = "compose:ralt",
    };

    struct xkb_context *context = xkb_context_new(XKB_CONTEXT_NO_FLAGS);
    if (context == NULL) {
        fputs("could not create libxkbcommon context\n", stderr);
        return 1;
    }
    xkb_context_set_log_level(context, XKB_LOG_LEVEL_ERROR);

    struct xkb_keymap *keymap = xkb_keymap_new_from_names(
        context, &names, XKB_KEYMAP_COMPILE_NO_FLAGS);
    if (keymap == NULL) {
        fputs("libxkbcommon could not compile evdev/pc105/us(intl)/compose:ralt\n",
              stderr);
        xkb_context_unref(context);
        return 1;
    }

    char *text = xkb_keymap_get_as_string(keymap, XKB_KEYMAP_FORMAT_TEXT_V1);
    if (text == NULL) {
        fputs("libxkbcommon did not serialize its compiled keymap\n", stderr);
        xkb_keymap_unref(keymap);
        xkb_context_unref(context);
        return 1;
    }

    size_t text_size = strlen(text) + 1u;
    if (text_size > UINT32_MAX) {
        fputs("compiled keymap is too large for NekoEdit's parser API\n", stderr);
        free(text);
        xkb_keymap_unref(keymap);
        xkb_context_unref(context);
        return 1;
    }

    int parse_result = xkb_parse_keymap(text, (uint32_t)text_size);
    if (parse_result != 0 || xkb_keymap_ready != 1u) {
        fprintf(stderr,
                "NekoEdit rejected a valid libxkbcommon us(intl) keymap: "
                "parse_result=%d ready=%u bytes=%zu stage=%u offset=%u token[%u]=\"%s\"\n",
                parse_result, xkb_keymap_ready, text_size,
                xkb_parse_error_stage, xkb_parse_error_offset,
                xkb_parse_error_token_length, xkb_parse_error_token);
        free(text);
        xkb_keymap_unref(keymap);
        xkb_context_unref(context);
        return 1;
    }

    int failed = 0;
    failed |= check_symbol(keymap, "Multi_key", XKB_KEY_Multi_key, 0x110007u);
    failed |= check_symbol(keymap, "dead_grave", XKB_KEY_dead_grave, 0x110001u);
    failed |= check_symbol(keymap, "dead_circumflex", XKB_KEY_dead_circumflex, 0x110003u);
    failed |= check_symbol(keymap, "period", XKB_KEY_period, (uint32_t)'.');
    failed |= check_symbol(keymap, "A", XKB_KEY_A, (uint32_t)'A');

    if (failed == 0)
        puts("PASS: NekoEdit parsed the real us(intl) keymap and retained Compose/dead-key actions");

    free(text);
    xkb_keymap_unref(keymap);
    xkb_context_unref(context);
    return failed;
}
