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
 *     NAV + A → APP_LAYER (reserved, same as D for now)
 *     NAV + S → WIN_LAYER
 *     NAV + D → APP_LAYER
 *     NAV + F → CURSOR_LAYER
 *     NAV + G → LIGHTING_LAYER (momentary)
 *     NAV + H → NUMPAD_LAYER (toggle)
 *   BASE → Right Thumb Hold → SYM_LAYER
 *   L3-L10 → Left Space Hold → NAV_LAYER
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
};

// ============================================
// App Launcher Macros (modifier combinations - can be used directly)
// ============================================
#define KC_APP_CHATGPT   LALT(LGUI(KC_Z))       // ⌥⌘Z - Z key
#define KC_APP_VSCODE    LALT(LGUI(KC_V))       // ⌥⌘V - V key
#define KC_APP_CAL       LALT(LGUI(KC_C))       // ⌥⌘C - C key
#define KC_APP_MAIL      LALT(LGUI(KC_E))       // ⌥⌘E - E key
#define KC_APP_SLACK     LALT(LGUI(KC_S))       // ⌥⌘S - S key
#define KC_APP_BGA       LALT(LGUI(KC_B))       // ⌥⌘B - B key
#define KC_APP_WHATSAPP  LALT(LGUI(KC_1))       // ⌥⌘1 - J key
#define KC_APP_SIGNAL    LALT(LGUI(KC_2))       // ⌥⌘2 - K key
#define KC_APP_WECHAT    LALT(LGUI(KC_3))       // ⌥⌘3 - L key
#define KC_APP_TELEGRAM  LALT(LGUI(KC_4))       // ⌥⌘4 - ; key
#define KC_APP_CALC      LALT(LGUI(KC_ESC))     // ⌥⌘Esc - Esc key
#define KC_APP_MUSIC     LALT(LGUI(KC_GRV))     // ⌥⌘` - ` key
#define KC_APP_NOTION    LSFT(LCTL(LGUI(KC_N))) // ⇧⌃⌘N - N key
#define KC_APP_OBSIDIAN  LALT(LGUI(KC_O))       // ⌥⌘O - O key
#define KC_APP_FINDER    LSFT(LALT(LGUI(KC_SPC))) // ⇧⌥⌘Space - Space key

// ============================================
// Window Management Macros (modifier combinations)
// ============================================
// Maximize/Halves (⇧⌃⌘)
#define KC_WIN_MAX       LSFT(LCTL(LGUI(KC_F)))      // ⇧⌃⌘F - F key (maximize)
#define KC_WIN_LEFT      LSFT(LCTL(LGUI(KC_LEFT)))   // ⇧⌃⌘← - Left arrow
#define KC_WIN_RIGHT     LSFT(LCTL(LGUI(KC_RIGHT)))  // ⇧⌃⌘→ - Right arrow
#define KC_WIN_TOP       LSFT(LCTL(LGUI(KC_UP)))     // ⇧⌃⌘↑ - Up arrow
#define KC_WIN_BOTTOM    LSFT(LCTL(LGUI(KC_DOWN)))   // ⇧⌃⌘↓ - Down arrow

// Quarters (⌃⌥)
#define KC_WIN_TL        LCTL(LALT(KC_LEFT))         // ⌃⌥← - Q key (top left)
#define KC_WIN_TR        LCTL(LALT(KC_RIGHT))        // ⌃⌥→ - W key (top right)
#define KC_WIN_BL        LSFT(LCTL(LALT(KC_LEFT)))   // ⇧⌃⌥← - A key (bottom left)
#define KC_WIN_BR        LSFT(LCTL(LALT(KC_RIGHT)))  // ⇧⌃⌥→ - S key (bottom right)

// Split View (⌃⌥⌘)
#define KC_WIN_SV_L      LCTL(LALT(LGUI(KC_LEFT)))   // ⌃⌥⌘← - Z key (split left)
#define KC_WIN_SV_R      LCTL(LALT(LGUI(KC_RIGHT)))  // ⌃⌥⌘→ - X key (split right)

// ============================================
// Encoder Macros
// ============================================
#define KC_ZOOM_OUT      LGUI(KC_MINS)          // Cmd - (zoom out)
#define KC_ZOOM_IN       LGUI(KC_EQL)           // Cmd = (zoom in)
#define KC_ZOOM_RESET    LGUI(KC_0)             // Cmd 0 (zoom reset)
#define KC_LOCK_SCREEN   LCTL(LGUI(KC_Q))       // Ctrl+Cmd+Q (lock screen)

// ============================================
// Tap Dance
// ============================================
enum {
    TD_ENC_R = 0,
};

qk_tap_dance_action_t tap_dance_actions[] = {
    [TD_ENC_R] = ACTION_TAP_DANCE_DOUBLE(KC_ZOOM_RESET, KC_LOCK_SCREEN),
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
        KC_MUTE,  KC_ESC,   KC_BRID,  KC_BRIU,  KC_MCTL,  KC_LPAD,  RM_VALD,   RM_VALU,  KC_MPRV,  KC_MPLY,  KC_MNXT,  KC_MUTE,  KC_VOLD,    KC_VOLU,  KC_INS,   KC_DEL,   TD(TD_ENC_R),
        // Row 1: Numbers
        _______,  KC_GRV,   KC_1,     KC_2,     KC_3,     KC_4,     KC_5,      KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,    KC_EQL,   KC_BSPC,            KC_PGUP,
        // Row 2: QWERTY top row
        _______,  KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,      KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,    KC_RBRC,  KC_BSLS,            KC_PGDN,
        // Row 3: QWERTY home row
        _______,  KC_CAPS,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,      KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,              KC_ENT,             KC_HOME,
        // Row 4: QWERTY bottom row
        _______,  KC_LSFT,            KC_Z,     KC_X,     KC_C,     KC_V,      KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,              KC_RSFT,  KC_UP,
        // Row 5: Modifiers and thumb keys
        //        Left Thumb: MO(NAV_LAYER) for layer menu
        //        Right Thumb: MO(SYM_LAYER) for symbols
        _______,  KC_LCTL,  KC_LOPT,  KC_LCMD,  MO(NAV_LAYER),      KC_SPC,                        KC_SPC,             MO(SYM_LAYER), KC_RCMD,  KC_RCTL,  KC_LEFT,  KC_DOWN,  KC_RGHT),

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
        // Row 3: Selectors on left-hand home row
        //        A: Reserved (currently APP_LAYER)
        //        S: WIN_LAYER (window management)
        //        D: APP_LAYER (app launchers)
        //        F: CURSOR_LAYER (Cursor IDE)
        _______,  _______,  LT(APP_LAYER, KC_NO),      // A: Reserved → APP_LAYER
                            LT(WIN_LAYER, KC_NO),      // S: WIN layer
                            LT(APP_LAYER, KC_NO),      // D: APP layer
                            LT(CURSOR_LAYER, KC_NO),   // F: CURSOR layer
                            MO(LIGHTING_LAYER),        // G: LIGHTING layer (momentary)
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
        KC_MUTE,  _______,  KC_F1,    KC_F2,    KC_F3,    KC_F4,    KC_F5,     KC_F6,    KC_F7,    KC_F8,    KC_F9,    KC_F10,   KC_F11,     KC_F12,   _______,  _______,  TD(TD_ENC_R),
        _______,  _______,  _______,  _______,  _______,  _______,  _______,   _______,  _______,  _______,  _______,  _______,  _______,    _______,  _______,            _______,
        _______,  RM_TOGG,  RM_NEXT,  RM_VALU,  RM_HUEU,  RM_SATU,  RM_SPDU,   _______,  _______,  _______,  _______,  _______,  _______,    _______,  _______,            _______,
        _______,  _______,  RM_PREV,  RM_VALD,  RM_HUED,  RM_SATD,  RM_SPDD,   _______,  _______,  _______,  _______,  _______,  _______,              _______,            _______,
        _______,  _______,            _______,  _______,  _______,  _______,   _______,  NK_TOGG,  _______,  _______,  _______,  _______,              _______,  _______,
        _______,  _______,  _______,  _______,  _______,            MO(NAV_LAYER),                 _______,            _______,  _______,    _______,  _______,  _______,  _______),

    // ============================================
    // Layer 7: WIN_BASE - Normal typing (Windows)
    // ============================================
    [WIN_BASE] = LAYOUT_91_ansi(
        KC_MUTE,  KC_ESC,   KC_F1,    KC_F2,    KC_F3,    KC_F4,    KC_F5,     KC_F6,    KC_F7,    KC_F8,    KC_F9,    KC_F10,   KC_F11,     KC_F12,   KC_INS,   KC_DEL,   TD(TD_ENC_R),
        _______,  KC_GRV,   KC_1,     KC_2,     KC_3,     KC_4,     KC_5,      KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,    KC_EQL,   KC_BSPC,            KC_PGUP,
        _______,  KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,      KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,    KC_RBRC,  KC_BSLS,            KC_PGDN,
        _______,  KC_CAPS,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,      KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,              KC_ENT,             KC_HOME,
        _______,  KC_LSFT,            KC_Z,     KC_X,     KC_C,     KC_V,      KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,              KC_RSFT,  KC_UP,
        _______,  KC_LCTL,  KC_LWIN,  KC_LALT,  MO(WIN_FN),         MO(NAV_LAYER),                 KC_SPC,             KC_RALT,  MO(WIN_FN), KC_RCTL,  KC_LEFT,  KC_DOWN,  KC_RGHT),

    // ============================================
    // Layer 8: WIN_FN - Function keys (Windows)
    // ============================================
    [WIN_FN] = LAYOUT_91_ansi(
        KC_MUTE,  _______,  KC_BRID,  KC_BRIU,  KC_TASK,  KC_FLXP,  RM_VALD,   RM_VALU,  KC_MPRV,  KC_MPLY,  KC_MNXT,  KC_MUTE,  KC_VOLD,    KC_VOLU,  _______,  _______,  TD(TD_ENC_R),
        _______,  _______,  _______,  _______,  _______,  _______,  _______,   _______,  _______,  _______,  _______,  _______,  _______,    _______,  _______,            _______,
        _______,  RM_TOGG,  RM_NEXT,  RM_VALU,  RM_HUEU,  RM_SATU,  RM_SPDU,   _______,  _______,  _______,  _______,  _______,  _______,    _______,  _______,            _______,
        _______,  _______,  RM_PREV,  RM_VALD,  RM_HUED,  RM_SATD,  RM_SPDD,   _______,  _______,  _______,  _______,  _______,  _______,              _______,            _______,
        _______,  _______,            _______,  _______,  _______,  _______,   _______,  NK_TOGG,  _______,  _______,  _______,  _______,              _______,  _______,
        _______,  _______,  _______,  _______,  _______,            MO(NAV_LAYER),                 _______,            _______,  _______,    _______,  _______,  _______,  _______),

    // ============================================
    // Layer 9: LIGHTING_LAYER - RGB lighting controls (NAV + G)
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
        // Row 0: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
        // Row 1: Transparent
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
        // Row 2: Numpad top row (7, 8, 9, /)
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  KC_KP_7,  KC_KP_8,  KC_KP_9,  KC_KP_SLASH,  _______,  _______,  _______,            _______,
        // Row 3: Numpad second row (4, 5, 6, *)
        _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  KC_KP_4,  KC_KP_5,  KC_KP_6,  KC_KP_ASTERISK,  _______,            _______,            _______,
        // Row 4: Numpad third row (1, 2, 3, -)
        _______,  _______,            _______,  _______,  _______,  _______,  _______,  KC_KP_1,  KC_KP_2,  KC_KP_3,  KC_KP_MINUS,              _______,  _______,  _______,
        // Row 5: Numpad bottom row (0, ., +, Enter) + NAV access
        _______,  _______,  _______,  _______,  MO(NAV_LAYER),      KC_KP_0,                    KC_KP_DOT,           KC_KP_PLUS,  KC_KP_ENTER,  _______,  _______,  _______,  _______),
};

// ============================================
// Encoder Configuration
// Left encoder: Volume (CCW: down, CW: up), press: Mute
// Right encoder: Zoom (CCW: out, CW: in), press: Tap dance (Cmd+0 / Ctrl+Cmd+Q)
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
// Process Record User - Handle custom keycodes
// SEND_STRING macros must be called from here, not from keymap directly
// ============================================
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
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

        default:
            return true; // Process all other keycodes normally
    }
}
