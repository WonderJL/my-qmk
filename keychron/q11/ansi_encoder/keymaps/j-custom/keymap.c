/* Custom keymap for Keychron Q11 ANSI Encoder
 * Based on default keymap
 *
 * Layer Architecture:
 *   Layer 0: MAC_BASE      - Normal typing (macOS)
 *   Layer 1: NAV_LAYER     - Navigation menu (thumb-held) - A/S/D/F selectors
 *   Layer 2: SYM_LAYER     - Symbols (right thumb)
 *   Layer 3: CURSOR_LAYER  - Cursor IDE helper (NAV + F)
 *   Layer 4: APP_LAYER     - Application launchers (NAV + D)
 *   Layer 5: WIN_LAYER     - Window management (NAV + S)
 *   Layer 6: MAC_FN        - Function keys (existing)
 *   Layer 7: WIN_BASE      - Normal typing (Windows)
 *   Layer 8: WIN_FN        - Function keys (Windows)
 *   Layer 9: LIGHTING_LAYER - RGB lighting controls (NAV + G)
 *   Layer 10: NUMPAD_LAYER  - Number pad (NAV + H)
 *
 * Activation Flow:
 *   BASE → Left Thumb Hold → NAV_LAYER
 *     NAV + Q → Toggle WIN_LAYER
 *     NAV + W → Toggle MAC_FN
 *     NAV + E → Toggle WIN_BASE
 *     NAV + R → Toggle WIN_FN
 *     NAV + A → APP_LAYER (custom switch while holding left space)
 *     NAV + S → WIN_LAYER (custom switch while holding left space)
 *     NAV + D → APP_LAYER (custom switch while holding left space)
 *     NAV + F → CURSOR_LAYER (custom switch while holding left space)
 *     NAV + G → LIGHTING_LAYER (custom switch while holding left space)
 *     NAV + H → NUMPAD_LAYER (toggle)
 *   BASE → Right Thumb Hold → SYM_LAYER
 *   L3-L10 → Left Space Hold → NAV_LAYER
 *
 * Universal Return to Base:
 *   Double-click left encoder (top left) → Returns to MAC_BASE from any layer
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 */
#include QMK_KEYBOARD_H

// ============================================
// Layer Definitions
// ============================================
enum layers {
    MAC_BASE,
    NAV_LAYER,
    SYM_LAYER,
    CURSOR_LAYER,
    APP_LAYER,
    WIN_LAYER,
    MAC_FN,
    WIN_BASE,
    WIN_FN,
    LIGHTING_LAYER,
    NUMPAD_LAYER,
};

// ============================================
// Custom Keycodes (for SEND_STRING macros)
// ============================================
enum custom_keycodes {
    // Symbol macros (SYM_LAYER) - require SEND_STRING
    KC_SYM_BACKTICKS = SAFE_RANGE,  // H: ```\n``` with cursor before closing backticks
    KC_SYM_TILDE_SLASH,              // F: ~/
    KC_SYM_PARENTHESES,              // J: () with cursor in middle
    KC_SYM_CURLY_BRACES,             // K: {} with cursor in middle
    KC_SYM_SQUARE_BRACKETS,          // L: [] with cursor in middle
    // Globe key (macOS Globe/Fn key) - fallback if KC_GLOBE not available
    KC_GLOBE_CUSTOM,                 // Custom Globe key implementation
    // Input method switching (macOS Ctrl+Space)
    KC_IME_NEXT,                     // Switch input method (Ctrl+Space)
    // Custom layer switching for NAV_LAYER selectors
    KC_NAV_SPACE,                    // Custom left space with layer switching
    KC_NAV_APP,                      // Custom A key for APP_LAYER switch
    KC_NAV_WIN,                      // Custom S key for WIN_LAYER switch
    KC_NAV_APP_D,                    // Custom D key for APP_LAYER switch
    KC_NAV_CURSOR,                   // Custom F key for CURSOR_LAYER switch
    KC_NAV_LIGHTING,                 // Custom G key for LIGHTING_LAYER switch
    KC_RETURN_TO_BASE,               // Custom keycode to return to MAC_BASE from any layer
};

// ============================================
// App Launcher Macros (⌥⌘ combinations)
// Using LAG() macro for Left Alt + Left GUI (ensures proper modifier release)
// ============================================
#define KC_APP_CHATGPT   LAG(KC_Z)              // ⌥⌘Z - Z key
#define KC_APP_VSCODE    LAG(KC_V)              // ⌥⌘V - V key
#define KC_APP_CAL       LAG(KC_C)              // ⌥⌘C - C key
#define KC_APP_MAIL      LAG(KC_E)              // ⌥⌘E - E key
#define KC_APP_SLACK     LAG(KC_S)              // ⌥⌘S - S key
#define KC_APP_BGA       LAG(KC_B)              // ⌥⌘B - B key
#define KC_APP_WHATSAPP  LAG(KC_1)              // ⌥⌘1 - J key
#define KC_APP_SIGNAL    LAG(KC_2)              // ⌥⌘2 - K key
#define KC_APP_WECHAT    LAG(KC_3)              // ⌥⌘3 - L key
#define KC_APP_TELEGRAM  LAG(KC_4)              // ⌥⌘4 - ; key
#define KC_APP_CALC      LAG(KC_ESC)            // ⌥⌘Esc - Esc key
#define KC_APP_MUSIC     LAG(KC_GRV)            // ⌥⌘` - ` key
#define KC_APP_NOTION    LCSG(KC_N)             // ⇧⌃⌘N - N key (Left Control + Left Shift + Left GUI)
#define KC_APP_OBSIDIAN  LAG(KC_O)              // ⌥⌘O - O key
#define KC_APP_FINDER    LSAG(KC_SPC)           // ⇧⌥⌘Space - Space key (Left Shift + Left Alt + Left GUI)
#define KC_APP_SLACK_6   LAG(KC_6)              // ⌥⌘6 - Left column Row 3
#define KC_APP_VPN_SHADOWROCKET LCAG(KC_Z)      // ⌃⌥⌘Z - Toggle Shadowrocket VPN (Left Control + Left Alt + Left GUI)

// ============================================
// Window Management Macros (modifier combinations)
// Using QMK macros for proper modifier release
// ============================================
// Maximize/Halves (⇧⌃⌘) - Left Control + Left Shift + Left GUI
#define KC_WIN_MAX       LCSG(KC_F)              // ⇧⌃⌘F - F key (maximize)
#define KC_WIN_LEFT      LCSG(KC_LEFT)          // ⇧⌃⌘← - Left arrow
#define KC_WIN_RIGHT     LCSG(KC_RIGHT)         // ⇧⌃⌘→ - Right arrow
#define KC_WIN_TOP       LCSG(KC_UP)            // ⇧⌃⌘↑ - Up arrow
#define KC_WIN_BOTTOM    LCSG(KC_DOWN)          // ⇧⌃⌘↓ - Down arrow

// Quarters (⌃⌥) - Left Control + Left Alt
#define KC_WIN_TL        LCA(KC_LEFT)           // ⌃⌥← - Q key (top left)
#define KC_WIN_TR        LCA(KC_RIGHT)          // ⌃⌥→ - W key (top right)
#define KC_WIN_BL        LSFT(LCA(KC_LEFT))     // ⇧⌃⌥← - A key (bottom left)
#define KC_WIN_BR        LSFT(LCA(KC_RIGHT))    // ⇧⌃⌥→ - S key (bottom right)

// Split View (⌃⌥⌘) - Left Control + Left Alt + Left GUI
#define KC_WIN_SV_L      LCAG(KC_LEFT)          // ⌃⌥⌘← - Z key (split left)
#define KC_WIN_SV_R      LCAG(KC_RIGHT)         // ⌃⌥⌘→ - X key (split right)

// ============================================
// Encoder Macros
// ============================================
#define KC_ZOOM_OUT      LGUI(KC_MINS)          // Cmd - (zoom out)
#define KC_ZOOM_IN       LGUI(KC_EQL)           // Cmd = (zoom in)
#define KC_ZOOM_RESET    LGUI(KC_0)             // Cmd 0 (zoom reset)
#define KC_LOCK_SCREEN   LCG(KC_Q)              // Ctrl+Cmd+Q (lock screen) - Left Control + Left GUI

// ============================================
// Tap Dance
// ============================================
enum {
    TD_ENC_L = 0,  // Left encoder: single = Mute, double = Return to base
    TD_ENC_R = 1,  // Right encoder: single = Zoom reset, double = Lock screen
};

// Tap dance callback functions for debugging
void td_enc_l_finished(tap_dance_state_t *state, void *user_data) {
#ifdef CONSOLE_ENABLE
    uprintf("DEBUG: TD_ENC_L finished - count: %d\n", state->count);
#endif
    if (state->count == 1) {
#ifdef CONSOLE_ENABLE
        uprintf("DEBUG: TD_ENC_L single tap - sending KC_MUTE\n");
#endif
        tap_code(KC_MUTE);
    } else if (state->count == 2) {
#ifdef CONSOLE_ENABLE
        uprintf("DEBUG: TD_ENC_L double tap - executing return to base\n");
        uprintf("DEBUG: Current layer state before: 0x%04X\n", layer_state);
        uprintf("DEBUG: Active layers before: ");
        for (uint8_t i = 0; i < 11; i++) {
            if (layer_state_is(i)) {
                uprintf("L%d ", i);
            }
        }
        uprintf("\n");
#endif
        // Execute return to base directly (same code as KC_RETURN_TO_BASE handler)
        // Turn off all toggle layers explicitly
        layer_off(WIN_LAYER);
        layer_off(MAC_FN);
        layer_off(WIN_BASE);
        layer_off(WIN_FN);
        layer_off(NUMPAD_LAYER);
        
        // Turn off all momentary/custom layers
        layer_off(NAV_LAYER);
        layer_off(SYM_LAYER);
        layer_off(CURSOR_LAYER);
        layer_off(APP_LAYER);
        layer_off(LIGHTING_LAYER);
        
        // Switch to MAC_BASE
        layer_move(MAC_BASE);
        
#ifdef CONSOLE_ENABLE
        uprintf("DEBUG: After layer_move, layer state: 0x%04X\n", layer_state);
        uprintf("DEBUG: Active layers after: ");
        for (uint8_t i = 0; i < 11; i++) {
            if (layer_state_is(i)) {
                uprintf("L%d ", i);
            }
        }
        uprintf("\n");
#endif
    }
}

void td_enc_l_reset(tap_dance_state_t *state, void *user_data) {
#ifdef CONSOLE_ENABLE
    uprintf("DEBUG: TD_ENC_L reset - count: %d\n", state->count);
#endif
}

tap_dance_action_t tap_dance_actions[] = {
    [TD_ENC_L] = ACTION_TAP_DANCE_FN_ADVANCED(NULL, td_enc_l_finished, td_enc_l_reset),  // Left encoder: single = Mute, double = Return to base
    [TD_ENC_R] = ACTION_TAP_DANCE_DOUBLE(KC_ZOOM_RESET, KC_LOCK_SCREEN),  // Right encoder: single = Zoom reset, double = Lock screen
};

// Windows-specific shortcuts (for WIN_BASE/WIN_FN layers)
#define KC_TASK LGUI(KC_TAB)
#define KC_FLXP LGUI(KC_E)

// ============================================
// Keymaps
// ============================================
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

    // ============================================
    // Layer 0: MAC_BASE - Normal typing (macOS)
    // ============================================
    [MAC_BASE] = LAYOUT_91_ansi(
        // Row 0: Encoder, Esc, F-keys, media
        TD(TD_ENC_L),  KC_ESC,   KC_BRID,  KC_BRIU,  KC_MCTL,  KC_LPAD,  RM_VALD,   RM_VALU,  KC_MPRV,  KC_MPLY,  KC_MNXT,  KC_MUTE,  KC_VOLD,    KC_VOLU,  KC_INS,   KC_DEL,   TD(TD_ENC_R),
        // Row 1: Numbers (leftmost key: WhatsApp)
        KC_APP_WHATSAPP,  KC_GRV,   KC_1,     KC_2,     KC_3,     KC_4,     KC_5,      KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,    KC_EQL,   KC_BSPC,            KC_PGUP,
        // Row 2: QWERTY top row (leftmost key: WeChat)
        KC_APP_WECHAT,  KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,      KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,    KC_RBRC,  KC_BSLS,            KC_PGDN,
        // Row 3: QWERTY home row (leftmost key: Slack)
        KC_APP_SLACK_6,  KC_CAPS,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,      KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,              KC_ENT,             KC_HOME,
        // Row 4: QWERTY bottom row (leftmost key: ChatGPT)
        KC_APP_CHATGPT,  KC_LSFT,            KC_Z,     KC_X,     KC_C,     KC_V,      KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,              KC_RSFT,  KC_UP,
        // Row 5: Modifiers and thumb keys
        //        Position 1: KC_APP_VPN_SHADOWROCKET - VPN toggle
        //        Position 2: KC_IME_NEXT - Input method switch (Ctrl+Space)
        //        Position 3: KC_LCTL - Left Control
        //        Position 4: KC_LALT - Left Option/Alt
        //        Position 5: KC_LGUI - Mac Command button (Left GUI/Command)
        //        Position 6: LT(NAV_LAYER, KC_SPC) - Left Space (tap: space, hold: NAV layer)
        //        Position 7: LT(SYM_LAYER, KC_SPC) - Right Space (tap: space, hold: SYM layer)
        //        Position 8: KC_RGUI - Right Command (Right GUI/Command)
        //        Position 9: KC_RCTL - Right Control
        //        Position 10: MO(MAC_FN) - Function layer (momentary, no tap behavior)
        //        Position 11: KC_LEFT - Left Arrow
        //        Position 12: KC_DOWN - Down Arrow
        //        Position 13: KC_RGHT - Right Arrow
        KC_APP_VPN_SHADOWROCKET,  KC_IME_NEXT,  KC_LCTL,  KC_LALT,  KC_LGUI,      KC_NAV_SPACE,                        LT(SYM_LAYER, KC_SPC),             KC_RGUI, KC_RCTL,  MO(MAC_FN),  KC_LEFT,  KC_DOWN,  KC_RGHT),

    // ============================================
    // Layer 1: NAV_LAYER - Navigation menu (thumb-held)
    // Left-hand home row (A/S/D/F) are layer selectors
    // ============================================
    [NAV_LAYER] = LAYOUT_91_ansi(
        // Row 0: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
        // Row 1: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        // Row 2: Toggle selectors for L5-L8
        _______,  _______,  TG(WIN_LAYER),  TG(MAC_FN),  TG(WIN_BASE),  TG(WIN_FN),  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        // Row 3: Selectors on left-hand home row (custom layer switching)
        //        A: APP_LAYER (switch while holding left space)
        //        S: WIN_LAYER (switch while holding left space)
        //        D: APP_LAYER (switch while holding left space)
        //        F: CURSOR_LAYER (switch while holding left space)
        //        G: LIGHTING_LAYER (switch while holding left space)
        _______,  _______,  KC_NAV_APP,      // A: Custom APP_LAYER switch
                            KC_NAV_WIN,      // S: Custom WIN_LAYER switch
                            KC_NAV_APP_D,    // D: Custom APP_LAYER switch
                            KC_NAV_CURSOR,   // F: Custom CURSOR_LAYER switch
                            KC_NAV_LIGHTING, // G: Custom LIGHTING_LAYER switch
                            TG(NUMPAD_LAYER),          // H: NUMPAD layer (toggle)
                            _______,  _______,  _______,  _______,  _______,            _______,            _______,
        // Row 4: Transparent
        _______,  _______,            _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,              _______,  _______,
        // Row 5: Keep NAV thumb held
        _______,  _______,  _______,  _______,  MO(NAV_LAYER),      _______,                       _______,            _______,  _______,  _______,  _______,  _______,  _______),

    // ============================================
    // Layer 2: SYM_LAYER - Symbols (right thumb)
    // Number row: shifted symbols (!@#$%^&*())
    // Home row: special macros (H:backticks, J:(), K:{}, L:[], F:~/)
    // ============================================
    [SYM_LAYER] = LAYOUT_91_ansi(
        // Row 0: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
        // Row 1: Number row → shifted symbols
        _______,  _______,  KC_EXLM,  KC_AT,    KC_HASH,  KC_DLR,   KC_PERC,  KC_CIRC,  KC_AMPR,  KC_ASTR,  KC_LPRN,  KC_RPRN,  KC_UNDS,  KC_PLUS,  _______,            _______,
        // Row 2: Top row - brackets on [ ] positions, pipe on backslash
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  KC_LCBR,  KC_RCBR,  KC_PIPE,            _______,
        // Row 3: Home row - special macros
        //        F: ~/ macro, H: ``` backticks, J: () parentheses, K: {} curly braces, L: [] square brackets
        _______,  _______,  _______,  _______,  _______,  KC_SYM_TILDE_SLASH,  _______,  KC_SYM_BACKTICKS,  KC_SYM_PARENTHESES,  KC_SYM_CURLY_BRACES,  KC_SYM_SQUARE_BRACKETS,  KC_COLN,  KC_DQUO,              _______,            _______,
        // Row 4: Bottom row - shifted punctuation
        _______,  _______,            _______,  _______,  _______,  _______,  _______,  _______,  _______,  KC_LT,    KC_GT,    KC_QUES,              _______,  _______,
        // Row 5: Keep SYM thumb held
        _______,  _______,  _______,  _______,  _______,            _______,                       _______,            MO(SYM_LAYER),  _______,  _______,  _______,  _______,  _______),

    // ============================================
    // Layer 3: CURSOR_LAYER - Cursor IDE helper (NAV + F)
    // Partial mapping: Y/U/I/O set, remaining actions TBD
    // ============================================
    [CURSOR_LAYER] = LAYOUT_91_ansi(
        // Row 0: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
        // Row 1: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        // Row 2: Top row - Setup/mode actions
        //        Y: Toggle explorer
        //        U: Toggle terminal
        //        I: Open/focus chat
        //        O: Mode picker
        //        P: Model picker (TBD)
        //        [: Submit with codebase (TBD)
        //        ]: Submit no codebase (TBD)
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  LGUI(KC_B),  LGUI(KC_T),  LGUI(KC_I),  LGUI(KC_DOT),  _______,  _______,  _______,  _______,            _______,
        // Row 3: Home row - High-frequency actions (TBD)
        //        H: Focus editor
        //        J: Previous change
        //        K: Next change
        //        L: Apply in editor
        //        ;: Accept all files
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,            _______,
        // Row 4: Transparent
        _______,  _______,            _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,              _______,  _______,
        // Row 5: Left space for NAV access
        _______,  _______,  _______,  _______,  _______,            MO(NAV_LAYER),                 _______,            _______,  _______,  _______,  _______,  _______,  _______),

    // ============================================
    // Layer 4: APP_LAYER - Application launchers (NAV + D)
    // Home row (J/K/L/;): Chat apps
    // Top row: Dev/productivity apps
    // Special keys: Esc (Calc), ` (Music), Space (Finder)
    // ============================================
    [APP_LAYER] = LAYOUT_91_ansi(
        // Row 0: Esc→Calculator, `→Music
        _______,  KC_APP_CALC,   // Esc: Calculator (⌥⌘Esc)
                  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
        // Row 1: `→Music
        _______,  KC_APP_MUSIC,  // `: NetEase Music (⌥⌘`)
                  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        // Row 2: Dev/productivity apps
        //        E: Mail (⌥⌘E)
        //        O: Obsidian (⌥⌘O)
        _______,  _______,  _______,  _______,  KC_APP_MAIL,   // E: Mail
                            _______,  _______,  _______,  _______,  _______,  KC_APP_OBSIDIAN,  // O: Obsidian
                            _______,  _______,  _______,  _______,            _______,
        // Row 3: Home row - Chat apps
        //        J: WhatsApp (⌥⌘1)
        //        K: Signal (⌥⌘2)
        //        L: WeChat (⌥⌘3)
        //        ;: Telegram (⌥⌘4)
        //        S: Slack (⌥⌘S)
        _______,  _______,  _______,  KC_APP_SLACK,  _______,  _______,  _______,  _______,
                            KC_APP_WHATSAPP,   // J: WhatsApp
                            KC_APP_SIGNAL,     // K: Signal
                            KC_APP_WECHAT,     // L: WeChat
                            KC_APP_TELEGRAM,   // ;: Telegram
                            _______,            _______,            _______,
        // Row 4: Bottom row - System apps
        //        Z: ChatGPT (⌥⌘Z)
        //        C: Calendar (⌥⌘C)
        //        V: VS Code (⌥⌘V)
        //        B: BGA (⌥⌘B)
        //        N: Notion (⇧⌃⌘N)
        //        M: (reserved)
        _______,  _______,            KC_APP_CHATGPT,  // Z: ChatGPT
                            _______,
                            KC_APP_CAL,        // C: Calendar
                            KC_APP_VSCODE,     // V: VS Code
                            KC_APP_BGA,        // B: BGA
                            KC_APP_NOTION,     // N: Notion
                            _______,           // M: (reserved)
                            _______,  _______,  _______,              _______,  _______,
        // Row 5: Left space → NAV, Right space → Finder
        _______,  _______,  _______,  _______,  _______,            MO(NAV_LAYER),                 KC_APP_FINDER,  // Right Space: Finder (⇧⌥⌘Space)
                                                                     _______,            _______,  _______,  _______,  _______,  _______),

    // ============================================
    // Layer 5: WIN_LAYER - Window management (NAV + S)
    // Arrow keys: Halves (⇧⌃⌘ + arrow)
    // F: Maximize (⇧⌃⌘F)
    // Q/W: Top quarters (⌃⌥ + left/right)
    // A/S: Bottom quarters (⇧⌃⌥ + left/right)
    // Z/X: Split view (⌃⌥⌘ + left/right)
    // ============================================
    [WIN_LAYER] = LAYOUT_91_ansi(
        // Row 0: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
        // Row 1: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        // Row 2: Top quarters
        //        Q: Top Left (⌃⌥←)
        //        W: Top Right (⌃⌥→)
        _______,  _______,  KC_WIN_TL,  KC_WIN_TR,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        // Row 3: Bottom quarters + Maximize
        //        A: Bottom Left (⇧⌃⌥←)
        //        S: Bottom Right (⇧⌃⌥→)
        //        F: Maximize (⇧⌃⌘F)
        _______,  _______,  KC_WIN_BL,  KC_WIN_BR,  _______,  KC_WIN_MAX,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,            _______,
        // Row 4: Split view
        //        Z: Split View Left (⌃⌥⌘←)
        //        X: Split View Right (⌃⌥⌘→)
        _______,  _______,            KC_WIN_SV_L,  KC_WIN_SV_R,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,              _______,  KC_WIN_TOP,
        // Row 5: Arrow keys for halves
        //        Left: Left Half (⇧⌃⌘←)
        //        Right: Right Half (⇧⌃⌘→)
        //        Up: Top Half (⇧⌃⌘↑)
        //        Down: Bottom Half (⇧⌃⌘↓)
        _______,  _______,  _______,  _______,  _______,            MO(NAV_LAYER),                 _______,            _______,  _______,  _______,  KC_WIN_LEFT,  KC_WIN_BOTTOM,  KC_WIN_RIGHT),

    // ============================================
    // Layer 6: MAC_FN - Function keys (existing)
    // ============================================
    [MAC_FN] = LAYOUT_91_ansi(
        TD(TD_ENC_L),  _______,  KC_F1,    KC_F2,    KC_F3,    KC_F4,    KC_F5,     KC_F6,    KC_F7,    KC_F8,    KC_F9,    KC_F10,   KC_F11,     KC_F12,   _______,  _______,  TD(TD_ENC_R),
        _______,  _______,  _______,  _______,  _______,  _______,  _______,   _______,  _______,  _______,  _______,  _______,  _______,    _______,  _______,            _______,
        _______,  RM_TOGG,  RM_NEXT,  RM_VALU,  RM_HUEU,  RM_SATU,  RM_SPDU,   _______,  _______,  _______,  _______,  _______,  _______,    _______,  _______,            _______,
        _______,  _______,  RM_PREV,  RM_VALD,  RM_HUED,  RM_SATD,  RM_SPDD,   _______,  _______,  _______,  _______,  _______,  _______,              _______,            _______,
        _______,  _______,            _______,  _______,  _______,  _______,   _______,  NK_TOGG,  _______,  _______,  _______,  _______,              _______,  _______,
        _______,  _______,  _______,  _______,  _______,            MO(NAV_LAYER),                 _______,            _______,  _______,    _______,  _______,  _______,  _______),

    // ============================================
    // Layer 7: WIN_BASE - Normal typing (Windows)
    // ============================================
    [WIN_BASE] = LAYOUT_91_ansi(
        TD(TD_ENC_L),  KC_ESC,   KC_F1,    KC_F2,    KC_F3,    KC_F4,    KC_F5,     KC_F6,    KC_F7,    KC_F8,    KC_F9,    KC_F10,   KC_F11,     KC_F12,   KC_INS,   KC_DEL,   TD(TD_ENC_R),
        _______,  KC_GRV,   KC_1,     KC_2,     KC_3,     KC_4,     KC_5,      KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,    KC_EQL,   KC_BSPC,            KC_PGUP,
        _______,  KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,      KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,    KC_RBRC,  KC_BSLS,            KC_PGDN,
        _______,  KC_CAPS,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,      KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,              KC_ENT,             KC_HOME,
        _______,  KC_LSFT,            KC_Z,     KC_X,     KC_C,     KC_V,      KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,              KC_RSFT,  KC_UP,
        _______,  KC_LCTL,  KC_LWIN,  KC_LALT,  MO(WIN_FN),         MO(NAV_LAYER),                 KC_SPC,             KC_RALT,  MO(WIN_FN), KC_RCTL,  KC_LEFT,  KC_DOWN,  KC_RGHT),

    // ============================================
    // Layer 8: WIN_FN - Function keys (Windows)
    // ============================================
    [WIN_FN] = LAYOUT_91_ansi(
        TD(TD_ENC_L),  _______,  KC_BRID,  KC_BRIU,  KC_TASK,  KC_FLXP,  RM_VALD,   RM_VALU,  KC_MPRV,  KC_MPLY,  KC_MNXT,  KC_MUTE,  KC_VOLD,    KC_VOLU,  _______,  _______,  TD(TD_ENC_R),
        _______,  _______,  _______,  _______,  _______,  _______,  _______,   _______,  _______,  _______,  _______,  _______,  _______,    _______,  _______,            _______,
        _______,  RM_TOGG,  RM_NEXT,  RM_VALU,  RM_HUEU,  RM_SATU,  RM_SPDU,   _______,  _______,  _______,  _______,  _______,  _______,    _______,  _______,            _______,
        _______,  _______,  RM_PREV,  RM_VALD,  RM_HUED,  RM_SATD,  RM_SPDD,   _______,  _______,  _______,  _______,  _______,  _______,              _______,            _______,
        _______,  _______,            _______,  _______,  _______,  _______,   _______,  NK_TOGG,  _______,  _______,  _______,  _______,              _______,  _______,
        _______,  _______,  _______,  _______,  _______,            MO(NAV_LAYER),                 _______,            _______,  _______,    _______,  _______,  _______,  _______),

    // ============================================
    // Layer 9: LIGHTING_LAYER - RGB lighting controls (NAV + G, latch - tap to activate)
    // ============================================
    [LIGHTING_LAYER] = LAYOUT_91_ansi(
        // Row 0: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
        // Row 1: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        // Row 2: Mode controls
        _______,  _______,  RM_TOGG,  RM_NEXT,  RM_PREV,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        // Row 3: Brightness and Hue controls
        _______,  _______,  RM_VALU,  RM_VALD,  RM_HUEU,  RM_HUED,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,            _______,
        // Row 4: Saturation and Speed controls
        _______,  _______,            RM_SATU,  RM_SATD,  RM_SPDU,  RM_SPDD,  RM_FLGN,  RM_FLGP,  _______,  _______,  _______,  _______,              _______,  _______,
        // Row 5: Left space for NAV access
        _______,  _______,  _______,  _______,  _______,            MO(NAV_LAYER),                 _______,            _______,  _______,  _______,  _______,  _______,  _______),

    // ============================================
    // Layer 10: NUMPAD_LAYER - Number pad (NAV + H)
    // ============================================
    [NUMPAD_LAYER] = LAYOUT_91_ansi(
        // Row 0: Encoder tap dance for return to base
        TD(TD_ENC_L),  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  TD(TD_ENC_R),
        // Row 1: Numpad top row (7, 8, 9, /) - positions 8-11 (Y/U/I/O keys)
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  KC_KP_7,  KC_KP_8,  KC_KP_9,  KC_KP_SLASH,  _______,  _______,  _______,            _______,
        // Row 2: Numpad second row (4, 5, 6, *) - positions 8-11 (H/J/K/L keys)
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  KC_KP_4,  KC_KP_5,  KC_KP_6,  KC_KP_ASTERISK,  _______,  _______,  _______,            _______,
        // Row 3: Numpad third row (1, 2, 3, -) - positions 8-11 (N/M/,/. keys)
        _______,  _______,            _______,  _______,  _______,  _______,  _______,  _______,  KC_KP_1,  KC_KP_2,  KC_KP_3,  KC_KP_MINUS,              _______,            _______,            _______,
        // Row 4: Numpad bottom row (0, ., +, Enter) - positions 8-11
        _______,  _______,            _______,  _______,  _______,  _______,  _______,  _______,  KC_KP_0,  KC_KP_DOT,  KC_KP_PLUS,  KC_KP_ENTER,              _______,  _______,
        // Row 5: Left space = NAV access, Right space = Numpad Enter
        _______,  _______,  _______,  _______,  _______,            MO(NAV_LAYER),                 KC_KP_ENTER,            _______,  _______,  _______,  _______,  _______,  _______),
};

// ============================================
// Encoder Configuration
// Left encoder: Volume (CCW: down, CW: up)
//   - Single press: Mute
//   - Double press: Return to MAC_BASE layer (works from any layer)
// Right encoder: Zoom (CCW: out, CW: in)
//   - Single press: Zoom reset (Cmd+0)
//   - Double press: Lock screen (Ctrl+Cmd+Q)
// ============================================
#if defined(ENCODER_MAP_ENABLE)
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    [MAC_BASE]       = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [NAV_LAYER]      = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [SYM_LAYER]      = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [CURSOR_LAYER]   = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [APP_LAYER]      = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [WIN_LAYER]      = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [MAC_FN]         = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [WIN_BASE]       = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [WIN_FN]         = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [LIGHTING_LAYER] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
    [NUMPAD_LAYER]   = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU),      ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN) },
};
#endif // ENCODER_MAP_ENABLE

// ============================================
// Custom Layer Switching State
// Tracks which target layer is selected when switching from NAV_LAYER
// ============================================
static uint8_t selected_target_layer = NAV_LAYER;  // Default to NAV_LAYER
static uint16_t nav_space_press_time = 0;          // Track press time for tap detection

// ============================================
// Process Record User - Handle custom keycodes
// SEND_STRING macros must be called from here, not from keymap directly
// ============================================
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
#ifdef CONSOLE_ENABLE
    // Enhanced debug output: Print ALL key presses with keycode, matrix position, and press state
    // This helps debug keymap issues and verify key assignments
    // Decode Layer Tap (LT) keycodes: LT() keycodes are in range 0x4000-0x4FFF
    // Format: 0x4000 + (layer << 8) + (keycode & 0xFF)
    if (keycode >= 0x4000 && keycode < 0x5000) {
        uint8_t layer = (keycode >> 8) & 0x0F;
        uint16_t tap_key = keycode & 0xFF;
        const char* layer_name = (layer == MAC_FN) ? "MAC_FN" :
                                 (layer == NAV_LAYER) ? "NAV_LAYER" :
                                 (layer == SYM_LAYER) ? "SYM_LAYER" :
                                 (layer == CURSOR_LAYER) ? "CURSOR_LAYER" :
                                 (layer == APP_LAYER) ? "APP_LAYER" :
                                 (layer == WIN_LAYER) ? "WIN_LAYER" :
                                 (layer == WIN_BASE) ? "WIN_BASE" :
                                 (layer == WIN_FN) ? "WIN_FN" :
                                 (layer == LIGHTING_LAYER) ? "LIGHTING_LAYER" :
                                 (layer == NUMPAD_LAYER) ? "NUMPAD_LAYER" : "UNKNOWN";
        const char* tap_name = (tap_key == KC_GLOBE_CUSTOM) ? "KC_GLOBE_CUSTOM" :
                               (tap_key == KC_SPC) ? "KC_SPC" :
                               (tap_key == KC_NO) ? "KC_NO" :
                               (tap_key == KC_IME_NEXT) ? "KC_IME_NEXT" : NULL;
        
        
        if (tap_name) {
            uprintf("DEBUG: kc: 0x%04X [LT(%s, %s)], col:%2u, row:%2u, pressed:%u, time:%5u\n", 
                    keycode, layer_name, tap_name,
                    record->event.key.col, 
                    record->event.key.row, 
                    record->event.pressed,
                    record->event.time);
        } else {
            uprintf("DEBUG: kc: 0x%04X [LT(%s, tap:0x%02X)], col:%2u, row:%2u, pressed:%u, time:%5u\n", 
                    keycode, layer_name, tap_key,
                    record->event.key.col, 
                    record->event.key.row, 
                    record->event.pressed,
                    record->event.time);
        }
    } else {
        // Check for tap dance keycodes (TD_*)
        if (keycode >= QK_TAP_DANCE && keycode <= QK_TAP_DANCE_MAX) {
            uint8_t td_index = keycode - QK_TAP_DANCE;
            const char* td_name = (td_index == TD_ENC_L) ? "TD_ENC_L" :
                                 (td_index == TD_ENC_R) ? "TD_ENC_R" : "TD_UNKNOWN";
            uprintf("DEBUG: kc: 0x%04X [%s], col:%2u, row:%2u, pressed:%u, time:%5u\n", 
                    keycode, td_name,
                    record->event.key.col, 
                    record->event.key.row, 
                    record->event.pressed,
                    record->event.time);
        } else {
            // Check for custom keycodes
            const char* custom_name = NULL;
            if (keycode == KC_RETURN_TO_BASE) custom_name = "KC_RETURN_TO_BASE";
            else if (keycode == KC_MUTE) custom_name = "KC_MUTE";
            else if (keycode == KC_ZOOM_RESET) custom_name = "KC_ZOOM_RESET";
            else if (keycode == KC_LOCK_SCREEN) custom_name = "KC_LOCK_SCREEN";
            
            if (custom_name) {
                uprintf("DEBUG: kc: 0x%04X [%s], col:%2u, row:%2u, pressed:%u, time:%5u\n", 
                        keycode, custom_name,
                        record->event.key.col, 
                        record->event.key.row, 
                        record->event.pressed,
                        record->event.time);
            } else {
                uprintf("DEBUG: kc: 0x%04X, col:%2u, row:%2u, pressed:%u, time:%5u\n", 
                        keycode,
                        record->event.key.col, 
                        record->event.key.row, 
                        record->event.pressed,
                        record->event.time);
            }
        }
    }
#endif
    
    // Workaround: Convert KC_LNG1 to KC_LGUI for position 5 (col:4, row:5)
    // This handles cases where VIA or EEPROM has stored KC_LNG1 instead of KC_LGUI
    // Note: The keymap array has KC_LGUI, but EEPROM/VIA may override it with KC_LNG1
    if (keycode == KC_LNG1 && record->event.key.col == 4 && record->event.key.row == 5) {
#ifdef CONSOLE_ENABLE
        uprintf("WORKAROUND: Converting KC_LNG1 to KC_LGUI at position 5\n");
#endif
        if (record->event.pressed) {
            register_code(KC_LGUI);
        } else {
            unregister_code(KC_LGUI);
        }
        return false; // We've handled it, don't process KC_LNG1
    }
    
    switch (keycode) {
        // Symbol macros - only trigger on key press (not release)
        case KC_SYM_BACKTICKS:
            if (record->event.pressed) {
                // Six backticks: ```\n``` with cursor before closing backticks
                SEND_STRING("```" SS_TAP(X_ENTER) "```" SS_TAP(X_LEFT) SS_TAP(X_LEFT) SS_TAP(X_LEFT));
            }
            return false;

        case KC_SYM_TILDE_SLASH:
            if (record->event.pressed) {
                // Tilde-slash: ~/
                SEND_STRING("~/");
            }
            return false;

        case KC_SYM_PARENTHESES:
            if (record->event.pressed) {
                // Parentheses: () with cursor in middle
                SEND_STRING("()" SS_TAP(X_LEFT));
            }
            return false;

        case KC_SYM_CURLY_BRACES:
            if (record->event.pressed) {
                // Curly braces: {} with cursor in middle
                SEND_STRING("{}" SS_TAP(X_LEFT));
            }
            return false;

        case KC_SYM_SQUARE_BRACKETS:
            if (record->event.pressed) {
                // Square brackets: [] with cursor in middle
                SEND_STRING("[]" SS_TAP(X_LEFT));
            }
            return false;

        // Globe key fallback - Globe key requires QMK patches/modules to work
        // To enable Globe key support, you need to:
        // 1. Apply QMK patches for KC_GLOBE support (see: https://gist.github.com/lordpixel23/87498dc42e328eabdff6dd258a667efd)
        // 2. Or use tzarc/qmk_modules globe_key module
        // 3. Add KEYBOARD_SHARED_EP = yes to rules.mk
        // For now, this sends nothing (KC_NO) - replace with KC_GLOBE once patches are applied
        case KC_GLOBE_CUSTOM:
            // TODO: Implement Globe key once KC_GLOBE is available via patches
            // For now, this does nothing - Globe key functionality requires QMK patches
            return false;

        // Input method switching (macOS Ctrl+Space)
        case KC_IME_NEXT:
            if (record->event.pressed) {
                tap_code16(LCTL(KC_SPC));  // Ctrl + Space for macOS input source switching
            }
            return false;

        // Custom layer switching - Left Space
        // Handles layer activation based on selected target layer
        // Supports tap-for-space and hold-for-layer behavior
        case KC_NAV_SPACE:
            if (record->event.pressed) {
                nav_space_press_time = record->event.time;
                if (selected_target_layer != NAV_LAYER && selected_target_layer < 11) {
                    // Activate selected target layer (APP/WIN/CURSOR/LIGHTING)
                    layer_on(selected_target_layer);
                } else {
                    // Default: activate NAV_LAYER
                    layer_on(NAV_LAYER);
                }
            } else {
                // Release - check if this was a tap (quick press/release)
                // TAPPING_TERM is typically 200ms, defined by QMK
                uint16_t press_duration = TIMER_DIFF_16(record->event.time, nav_space_press_time);
                bool was_tap = press_duration < TAPPING_TERM;
                
                // Deactivate all possible layers
                layer_off(NAV_LAYER);
                layer_off(APP_LAYER);
                layer_off(WIN_LAYER);
                layer_off(CURSOR_LAYER);
                layer_off(LIGHTING_LAYER);
                
                // Reset selection to default
                selected_target_layer = NAV_LAYER;
                
                // If it was a tap (not a hold), send space character
                if (was_tap) {
                    tap_code(KC_SPC);
                }
            }
            return false; // We've handled it

        // Custom layer switching - Selector keys
        // These keys switch from NAV_LAYER to target layer while left space is held
        // Only work when NAV_LAYER is currently active
        case KC_NAV_APP:  // A key - Switch to APP_LAYER
            if (record->event.pressed) {
                if (layer_state_is(NAV_LAYER)) {
                    selected_target_layer = APP_LAYER;
                    layer_off(NAV_LAYER);
                    layer_on(APP_LAYER);
                }
            }
            return false;

        case KC_NAV_WIN:  // S key - Switch to WIN_LAYER
            if (record->event.pressed) {
                if (layer_state_is(NAV_LAYER)) {
                    selected_target_layer = WIN_LAYER;
                    layer_off(NAV_LAYER);
                    layer_on(WIN_LAYER);
                }
            }
            return false;

        case KC_NAV_APP_D:  // D key - Switch to APP_LAYER
            if (record->event.pressed) {
                if (layer_state_is(NAV_LAYER)) {
                    selected_target_layer = APP_LAYER;
                    layer_off(NAV_LAYER);
                    layer_on(APP_LAYER);
                }
            }
            return false;

        case KC_NAV_CURSOR:  // F key - Switch to CURSOR_LAYER
            if (record->event.pressed) {
                if (layer_state_is(NAV_LAYER)) {
                    selected_target_layer = CURSOR_LAYER;
                    layer_off(NAV_LAYER);
                    layer_on(CURSOR_LAYER);
                }
            }
            return false;

        case KC_NAV_LIGHTING:  // G key - Switch to LIGHTING_LAYER
            if (record->event.pressed) {
                if (layer_state_is(NAV_LAYER)) {
                    selected_target_layer = LIGHTING_LAYER;
                    layer_off(NAV_LAYER);
                    layer_on(LIGHTING_LAYER);
                }
            }
            return false;

        // Return to base - explicitly turn off all layers and return to MAC_BASE
        // This works from any layer, including toggle layers
        case KC_RETURN_TO_BASE:
            if (record->event.pressed) {
#ifdef CONSOLE_ENABLE
                uprintf("DEBUG: KC_RETURN_TO_BASE triggered! Current layer state: 0x%04X\n", layer_state);
                uprintf("DEBUG: Active layers before: ");
                for (uint8_t i = 0; i < 11; i++) {
                    if (layer_state_is(i)) {
                        uprintf("L%d ", i);
                    }
                }
                uprintf("\n");
#endif
                // Turn off all toggle layers explicitly
                layer_off(WIN_LAYER);
                layer_off(MAC_FN);
                layer_off(WIN_BASE);
                layer_off(WIN_FN);
                layer_off(NUMPAD_LAYER);
                
                // Turn off all momentary/custom layers
                layer_off(NAV_LAYER);
                layer_off(SYM_LAYER);
                layer_off(CURSOR_LAYER);
                layer_off(APP_LAYER);
                layer_off(LIGHTING_LAYER);
                
                // Switch to MAC_BASE
                layer_move(MAC_BASE);
                
                // Reset custom layer switching state
                selected_target_layer = NAV_LAYER;
                
#ifdef CONSOLE_ENABLE
                uprintf("DEBUG: After layer_move, layer state: 0x%04X\n", layer_state);
                uprintf("DEBUG: Active layers after: ");
                for (uint8_t i = 0; i < 11; i++) {
                    if (layer_state_is(i)) {
                        uprintf("L%d ", i);
                    }
                }
                uprintf("\n");
#endif
            }
            return false;

        default:
            return true; // Process all other keycodes normally
    }
}
