# FINALIZED QMK Config Tech Spec for Keychron Q11

## 📋 Document Purpose

This document consolidates and finalizes the QMK keymap configuration specification for Keychron Q11 ANSI Encoder, based on comprehensive planning documents:
- `PLAN-add-app-layer-and-win-layer-to-qmk-keymap-for-keyc-v2.md`
- `PLAN-update-sym-layer-symbol-mapping.md`

This tech spec serves as the **single source of truth** for implementation, providing complete layer definitions, key mappings, macro specifications, and implementation guidelines.

---

## 🧠 System Overview

### Keyboard Specifications
- **Model**: Keychron Q11 ANSI Encoder
- **Layout**: `LAYOUT_91_ansi` (91 keys, split design)
- **Firmware**: QMK (code-managed, GitHub-committed)
- **Primary Platform**: macOS
- **Secondary Platform**: Windows (optional support)

### Design Principles
1. **Typing Safety**: Letters always type letters on BASE layer
2. **Momentary Power**: Layers activate only when thumb held (no sticky modes)
3. **Left-Control/Right-Action**: Left hand selects, right hand executes
4. **Home Row Priority**: Highest-frequency actions on home row
5. **Standard ANSI Layout**: Preserve familiar symbol positions for muscle memory

---

## 🗂️ Layer Architecture

### Complete Layer Structure

```
Layer 0: MAC_BASE      - Normal typing (macOS)
Layer 1: NAV_LAYER     - Navigation menu (thumb-held)
Layer 2: SYM_LAYER     - Symbols (right thumb)
Layer 3: CURSOR_LAYER  - Cursor IDE helper (NAV + F)
Layer 4: APP_LAYER     - Application launchers (NAV + D)
Layer 5: WIN_LAYER     - Window management (NAV + S)
Layer 6: MAC_FN        - Function keys (existing)
Layer 7: WIN_BASE      - Normal typing (Windows, optional)
Layer 8: WIN_FN        - Function keys (Windows, optional)
Layer 9: LIGHTING_LAYER - RGB lighting controls (NAV + G)
Layer 10: NUMPAD_LAYER  - Number pad (NAV + H)
```

### Layer Activation Flow

```
BASE (Layer 0)
  ├─ Left Space Hold → NAV_LAYER (Layer 1) [Layer Tap]
  │   ├─ Tap → Space
  │   ├─ Hold → NAV_LAYER activates
  │   │   ├─ Tap Q → Toggle WIN_LAYER (Layer 5) [toggle]
  │   │   ├─ Tap W → Toggle MAC_FN (Layer 6) [toggle]
  │   │   ├─ Tap E → Toggle WIN_BASE (Layer 7) [toggle]
  │   │   ├─ Tap R → Toggle WIN_FN (Layer 8) [toggle]
  │   │   ├─ While holding left space, press A → Switch to APP_LAYER (Layer 4) [custom switch]
  │   │   ├─ While holding left space, press S → Switch to WIN_LAYER (Layer 5) [custom switch]
  │   │   ├─ While holding left space, press D → Switch to APP_LAYER (Layer 4) [custom switch]
  │   │   ├─ While holding left space, press F → Switch to CURSOR_LAYER (Layer 3) [custom switch]
  │   │   ├─ While holding left space, press G → Switch to LIGHTING_LAYER (Layer 9) [custom switch]
  │   │   └─ Tap H → Toggle NUMPAD_LAYER (Layer 10) [toggle]
  │
  └─ Right Space Hold → SYM_LAYER (Layer 2) [Layer Tap]
     ├─ Tap → Space
     └─ Hold → SYM_LAYER activates

From any non-momentary layer (L3-L10):
  └─ Left Space Hold → NAV_LAYER (Layer 1)  
     (NUMPAD_LAYER uses the left thumb key for NAV access to keep KP_0 on left space)
```

**Key Points**:
- **NAV_LAYER**: Momentary - activates only while left space held (Layer Tap)
- **SYM_LAYER**: Momentary - activates only while right space held (Layer Tap)
- **Space Bars**: Layer Tap (LT) and Custom - tap for space, hold for layer activation
  - **Left Space**: `KC_NAV_SPACE` (custom) - tap for space, hold for NAV layer, supports custom layer switching
  - **Right Space**: `LT(SYM_LAYER, KC_SPC)` - tap for space, hold for SYM layer
- **Thumb Keys**:
  - **Left Thumb (Position 2)**: `KC_IME_NEXT` - Input method switch (Ctrl+Space)
  - **Right Thumb (Position 10)**: `MO(MAC_FN)` - Function layer (momentary, hold to activate)
  - **Input Method Switching**: Position 2 sends `LCTL(KC_SPC)` for macOS input source switching
  - **Function Layer**: Position 10 activates MAC_FN layer when held (momentary, no tap behavior)
  - **Mac Command Button**: `KC_LGUI` key (Position 5) is the Mac Command button (Left GUI/Command)
- **Helper Layers** (CURSOR/APP/WIN/LIGHTING): Custom Switch - while holding left space, press selector to switch to target layer, stays active until left space released
- **Toggle Layers** (L5-L8, L10): Toggle (TG) - tap selector to activate, tap again to deactivate back to MAC_BASE
- **Custom Layer Switching**: Left space hold activates NAV_LAYER, then pressing A/S/D/F/G switches to target layer while left space remains held
- **Left Space NAV Access**: All non-momentary layers (L3-L10) provide NAV access on left space, except NUMPAD_LAYER which uses the left thumb key to keep KP_0 on left space
- **All layers deactivate** on space release (momentary layers) or explicit deactivation (latched/toggled layers)

---

## 📝 Complete Keymap Specification

### Layer 0: MAC_BASE (Normal Typing)

**Purpose**: Clean typing layer with no helper functionality

**Activation**: Default layer (always active when no other layer is active)

**Key Mappings**:
```c
[MAC_BASE] = LAYOUT_91_ansi(
    // Row 0: Function keys, media, etc.
    KC_MUTE,  KC_ESC,   KC_BRID,  KC_BRIU,  KC_MCTL,  KC_LPAD,  RM_VALD,   RM_VALU,  KC_MPRV,  KC_MPLY,  KC_MNXT,  KC_MUTE,  KC_VOLD,    KC_VOLU,  KC_INS,   KC_DEL,   TD(TD_ENC_R),
    // Row 1: Numbers and symbols (leftmost key: WhatsApp)
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
    KC_APP_VPN_SHADOWROCKET,  KC_IME_NEXT,  KC_LCTL,  KC_LALT,  KC_LGUI,         KC_NAV_SPACE,                        LT(SYM_LAYER, KC_SPC),             KC_RGUI, KC_RCTL,  MO(MAC_FN),  KC_LEFT,  KC_DOWN,  KC_RGHT
),
```

**Key Features**:
- **Row 5 Structure**:
  - **Position 1**: `KC_APP_VPN_SHADOWROCKET` - VPN toggle
  - **Position 2**: `KC_IME_NEXT` - Input method switch (Ctrl+Space for macOS input source switching)
  - **Position 3**: `KC_LCTL` - Left Control
  - **Position 4**: `KC_LALT` - Left Option/Alt
  - **Position 5**: `KC_LGUI` - Mac Command button (Left GUI/Command)
  - **Position 6**: `LT(NAV_LAYER, KC_SPC)` - Left Space (tap: space, hold: NAV layer)
  - **Position 7**: `LT(SYM_LAYER, KC_SPC)` - Right Space (tap: space, hold: SYM layer)
  - **Position 8**: `KC_RGUI` - Right Command (Right GUI/Command)
  - **Position 9**: `KC_RCTL` - Right Control
  - **Position 10**: `MO(MAC_FN)` - Function layer (momentary, no tap behavior - hold to activate MAC_FN layer)
  - **Position 11**: `KC_LEFT` - Left Arrow
  - **Position 12**: `KC_DOWN` - Down Arrow
  - **Position 13**: `KC_RGHT` - Right Arrow
- **Input Method Switching**:
  - **Position 2**: `KC_IME_NEXT` sends `LCTL(KC_SPC)` (Ctrl+Space) for macOS input source switching
  - **macOS Setup**: System Settings → Keyboard → Keyboard Shortcuts → Input Sources → Set "Select the previous input source" to Control + Space
- **Function Layer Activation**:
  - **Position 10**: `MO(MAC_FN)` - Hold to activate MAC_FN layer (momentary, no tap behavior)
  - **Hold Fn**: Activates MAC_FN layer, sending actual F1-F12 keys instead of macOS system actions
  - **Example**: Hold Fn + F1 sends `KC_F1` (actual F1 key) instead of brightness down
- **All letters type normally** - no helper functionality
- **Backslash key (`\`)**: Outputs `\` (backslash) - `KC_BSLS` (default behavior)
- **Leftmost Column (5 keys)**: Quick app launchers and VPN toggle
  - **Row 1** (left of backtick): `KC_APP_WHATSAPP` - Opens WhatsApp (⌥⌘1)
  - **Row 2** (left of TAB): `KC_APP_WECHAT` - Opens WeChat (⌥⌘3)
  - **Row 3** (left of CAPS): `KC_APP_SLACK_6` - Opens Slack (⌥⌘6)
  - **Row 4** (left of LSFT): `KC_APP_CHATGPT` - Opens ChatGPT (⌥⌘Z)
  - **Row 5** (left of LCTL): `KC_APP_VPN_SHADOWROCKET` - Toggles Shadowrocket VPN (⌃⌥⌘Z)

**Fn Key Behavior**:
- **Left Thumb (Position 2)**: `KC_IME_NEXT` - Input method switch (Ctrl+Space)
- **Right Thumb (Position 10)**: `MO(MAC_FN)` - Function layer (momentary, hold to activate)
- **Input Method Switching**: Position 2 sends `LCTL(KC_SPC)` for macOS input source switching
- **Function Layer**: Position 10 activates MAC_FN layer when held (momentary, no tap behavior)
- **Hold Fn + F1-F12**: Activates MAC_FN layer, sending actual function keys:
  - **Fn + F1**: Sends `KC_F1` (actual F1) instead of brightness down
  - **Fn + F2**: Sends `KC_F2` (actual F2) instead of brightness up
  - **Fn + F3**: Sends `KC_F3` (actual F3) instead of Mission Control
  - **Fn + F9**: Sends `KC_F9` (actual F9) instead of media play/pause
  - And so on for all F1-F12 keys
- **Without Fn**: F1-F12 keys on BASE layer trigger macOS system actions (brightness, volume, media controls, etc.)
- **With Fn**: F1-F12 keys send actual function key codes that applications can use
- **Mac Command Button**: `KC_LGUI` key (Position 5) is the Mac Command button (Left GUI/Command)

---

### Layer 1: NAV_LAYER (Navigation Menu)

**Purpose**: Menu system for accessing helper layers

**Activation**: 
- Left Space hold (`LT(NAV_LAYER, KC_SPC)`) - from BASE layer, tap for space, hold for NAV layer

**Key Mappings**:
```c
[NAV_LAYER] = LAYOUT_91_ansi(
    // Row 0: Transparent (pass through to BASE)
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
    // Row 1: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
    // Row 2: Top row - Toggle selectors for L5-L8
    _______,  _______,  TG(WIN_LAYER),   // Q: Toggle WIN_LAYER (Layer 5)
                  TG(MAC_FN),      // W: Toggle MAC_FN (Layer 6)
                  TG(WIN_BASE),    // E: Toggle WIN_BASE (Layer 7)
                  TG(WIN_FN),      // R: Toggle WIN_FN (Layer 8)
                  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
    // Row 3: Selectors on left-hand home row (custom layer switching)
    _______,  _______,  KC_NAV_APP,   // A: Custom APP_LAYER switch (while holding left space)
                  KC_NAV_WIN,   // S: Custom WIN_LAYER switch (while holding left space)
                  KC_NAV_APP_D,   // D: Custom APP_LAYER switch (while holding left space)
                  KC_NAV_CURSOR, // F: Custom CURSOR_LAYER switch (while holding left space)
                  KC_NAV_LIGHTING,  // G: Custom LIGHTING_LAYER switch (while holding left space)
                  TG(NUMPAD_LAYER),  // H: Toggle NUMPAD_LAYER (Layer 10)
                  _______,  _______,  _______,  _______,  _______,  _______,              _______,            _______,
    // Row 4: Transparent
    _______,  _______,            _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,              _______,  _______,
    // Row 5: Space bars transparent (pass through to BASE LT functions)
    _______,  _______,  _______,  _______,  _______,            _______,                       _______,            _______,  _______,  _______,  _______,  _______,  _______
),
```

**Key Features**:
- **Top row (Q/W/E/R)**: Toggle selectors using `TG()` (Toggle)
  - `Q`: Toggle WIN_LAYER (Layer 5)
  - `W`: Toggle MAC_FN (Layer 6)
  - `E`: Toggle WIN_BASE (Layer 7)
  - `R`: Toggle WIN_FN (Layer 8)
- **Left-hand home row (A/S/D/F/G/H)**: Selectors using custom keycodes and `TG()` (Toggle)
  - `A`: Custom switch to APP_LAYER (while holding left space)
  - `S`: Custom switch to WIN_LAYER (while holding left space) - note: also accessible via Q toggle
  - `D`: Custom switch to APP_LAYER (while holding left space)
  - `F`: Custom switch to CURSOR_LAYER (while holding left space)
  - `G`: Custom switch to LIGHTING_LAYER (while holding left space)
  - `H`: Toggle NUMPAD_LAYER (Layer 10)
- **Custom Layer Switching**: While holding left space (NAV_LAYER active), pressing A/S/D/F/G switches to target layer and stays active until left space is released
- **`TG(LAYER)`**: Tap to toggle layer on/off (returns to MAC_BASE when toggled off)
- **Custom Keycodes**: `KC_NAV_SPACE`, `KC_NAV_APP`, `KC_NAV_WIN`, `KC_NAV_APP_D`, `KC_NAV_CURSOR`, `KC_NAV_LIGHTING`
- **Right-hand keys**: Transparent (pass through to BASE)
- **Space bars**: Transparent (pass through to BASE layer's `LT()` functions - tap for space, hold for layer)

**Usage**:
1. **Activate NAV_LAYER**:
   - Hold Left Space → NAV_LAYER activates (from BASE layer)
2. **Switch to target layer** (while holding left space):
   - Press A/S/D/F/G → Switches to corresponding target layer (APP/WIN/CURSOR/LIGHTING)
   - Target layer stays active while left space is held
   - Release selector key → Target layer remains active (left space still held)
3. **Toggle layers** (tap, not hold):
   - **Toggle selectors (Q/W/E/R/H)**: Tap to toggle layer on/off
4. **Return to BASE**:
   - Release Left Space → Returns to MAC_BASE, all custom-switched layers deactivate
5. **Tap Left Space** (quick press/release):
   - Sends space character, no layer activation

---

### Layer 2: SYM_LAYER (Symbols)

**Purpose**: Quick access to symbols and special coding macros

**Activation**: 
- Right Space hold (`LT(SYM_LAYER, KC_SPC)`) - from BASE layer, tap for space, hold for SYM layer

**Key Mappings**:
```c
[SYM_LAYER] = LAYOUT_91_ansi(
    // Row 0: Transparent (pass through to BASE)
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
    // Row 1: Number row - Output shifted symbols directly (no shift needed)
    _______,  _______,  KC_EXLM,  // 1: ! (exclamation)
                KC_AT,    // 2: @ (at sign)
                KC_HASH,  // 3: # (hash)
                KC_DLR,   // 4: $ (dollar)
                KC_PERC,  // 5: % (percent)
                KC_CIRC,  // 6: ^ (caret)
                KC_AMPR,  // 7: & (ampersand)
                KC_ASTR,  // 8: * (asterisk)
                KC_LPRN,  // 9: ( (left parenthesis)
                KC_RPRN,  // 0: ) (right parenthesis)
                KC_UNDS,  // -: _ (underscore)
                KC_PLUS,  // =: + (plus)
                _______,  // Backspace: Transparent
                _______,            // Page Up: Transparent
    // Row 2: Top row - Standard ANSI positions, output shifted versions
    // Left hand: Q W E R T
    _______,  _______,  _______,  // Q: Transparent (keep letter)
                _______,  // W: Transparent (keep letter)
                _______,  // E: Transparent (keep letter)
                _______,  // R: Transparent (keep letter)
                _______,  // T: Transparent (keep letter)
    // Right hand: Y U I O P [ ] \
                _______,  // Y: Transparent (keep letter)
                _______,  // U: Transparent (keep letter)
                _______,  // I: Transparent (keep letter)
                _______,  // O: Transparent (keep letter)
                _______,  // P: Transparent (keep letter)
                KC_LCBR,  // [: { (left brace)
                KC_RCBR,  // ]: } (right brace)
                KC_PIPE,  // \: | (pipe) - shifted version on SYM layer
    // Row 3: Home row - Special macros on home row
    // Left hand: A S D F G
    _______,  _______,  _______,  // A: Transparent (keep letter)
                _______,  // S: Transparent (keep letter)
                _______,  // D: Transparent (keep letter)
                KC_SYM_TILDE_SLASH,   // F: ~/ macro
                _______,  // G: Transparent (keep letter)
    // Right hand: H J K L ; '
                KC_SYM_BACKTICKS,     // H: Six backticks macro
                KC_SYM_PARENTHESES,   // J: () macro
                KC_SYM_CURLY_BRACES,  // K: {} macro
                KC_SYM_SQUARE_BRACKETS, // L: [] macro
                KC_COLN,  // ;: : (colon) - standard ANSI
                KC_DQUO,  // ': " (double quote)
                _______,            // Enter: Transparent
                _______,            // Home: Transparent
    // Row 4: Bottom row - Standard ANSI positions, output shifted versions
    // Left hand: Z X C V B
    _______,  _______,            _______,  // Z: Transparent (keep letter)
                _______,  // X: Transparent (keep letter)
                _______,  // C: Transparent (keep letter)
                _______,  // V: Transparent (keep letter)
                _______,  // B: Transparent (keep letter)
    // Right hand: N M , . /
                _______,  // N: Transparent (keep letter)
                _______,  // M: Transparent (keep letter)
                KC_LT,    // ,: < (less than)
                KC_GT,    // .: > (greater than)
                KC_QUES,  // /: ? (question mark)
                _______,              // Right Shift: Transparent
                _______,  // Up: Transparent
    // Row 5: Modifiers and thumb keys
    // Left hand: Ctrl Opt Cmd Thumb
    _______,  _______,  _______,  _______,  _______,            // Left modifiers: Transparent
                // Space: Transparent (pass through to BASE layer's LT() functions)
                // Right hand: Thumb Cmd Ctrl
                _______,            // Right thumb: Transparent
                _______,  _______,  // Right modifiers: Transparent
                _______,  _______,  _______,  // Arrow keys: Transparent
),
```

**Key Features**:
- **Special macros on home row**:
  - `H` → Six backticks macro (```\n``` with cursor before closing backticks on bottom line)
  - `J` → Parentheses macro (() with cursor in middle)
  - `K` → Curly braces macro ({} with cursor in middle)
  - `L` → Square brackets macro ([] with cursor in middle)
  - `F` → Tilde-slash macro (~/)
- **Standard ANSI layout preserved**: Symbols stay in familiar positions
- **Direct symbol access**: Number row outputs shifted symbols directly (1→!, 2→@, etc.)
- **Standard symbols**: Backslash key outputs `|` (pipe) on SYM layer (shifted version)
- **Letters remain transparent**: Typing safety maintained
- **Space bars**: Transparent (pass through to BASE layer's `LT()` functions - tap for space, hold for layer)

---

### Layer 3: CURSOR_LAYER (Cursor IDE Helper)

**Purpose**: Cursor IDE productivity actions

**Activation**: NAV + F (tap F while NAV_LAYER is active)

**Key Mappings**:
```c
[CURSOR_LAYER] = LAYOUT_91_ansi(
    // Row 0: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
    // Row 1: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
    // Row 2: Top row - Setup/mode actions
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  LGUI(KC_B),  // Y: Toggle explorer (Cursor: workbench.action.toggleSidebarVisibility, cmd+b)
                LGUI(KC_T),  // U: Toggle terminal (Cursor override: workbench.action.terminal.toggleTerminal, cmd+t)
                LGUI(KC_I),  // I: Open/focus chat (Cursor: composer.startComposerPrompt, cmd+i)
                LGUI(KC_DOT),  // O: Mode picker (Cursor: composer.openModeMenu, cmd+.)
                _______,  // P: Model picker (TBD - skipped)
                _______,  // [: Submit with codebase (TBD - skipped)
                _______,  // ]: Submit no codebase (TBD - skipped)
                _______,            _______,
    // Row 3: Home row - High-frequency actions
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  // H: Focus editor (TBD - skipped)
                _______,  // J: Previous change (TBD - skipped)
                _______,  // K: Next change (TBD - skipped)
                _______,  // L: Apply in editor (TBD - skipped)
                _______,  // ;: Accept all files (TBD - skipped)
                _______,            _______,            _______,
    // Row 4: Transparent
    // Row 5: Left space for NAV access
    _______,  _______,  _______,  _______,  _______,  MO(NAV_LAYER),  _______,                       _______,            _______,  _______,  _______,  _______,  _______),
```

**Key Features**:
- **Right-hand only actions**: Left-hand remains transparent
- **Top row (Y/U/I/O)**: Explorer/terminal/chat/mode via Cursor commands
- **Top row (P/[ / ])**: TBD (skipped) and left transparent
- **Home row (H/J/K/L/;)**: TBD (skipped) and left transparent
- **Left Thumb Key**: `MO(NAV_LAYER)` - hold to access NAV_LAYER from this layer
- **TBD**: Model picker, submit with/without codebase, focus editor, previous/next change, apply in editor, accept all files

**Status**: ⚠️ **INCOMPLETE** - Partial mapping done; remaining Cursor actions are TBD (skipped)

---

### Layer 4: APP_LAYER (Application Launchers)

**Purpose**: Quick application launching

**Activation**: NAV + D (tap D while NAV_LAYER is active)

**Key Mappings**:
```c
[APP_LAYER] = LAYOUT_91_ansi(
    // Row 0: Transparent
    _______,  KC_APP_CALC,  // Esc: Calculator (⌥⌘Esc)
                KC_APP_MUSIC,  // `: NetEase Music (⌥⌘`)
                _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
    // Row 1: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
    // Row 2: Top row - Dev/Productivity apps
    _______,  _______,  _______,  // Y: (reserved)
                // U: (reserved)
                // I: (reserved)
                KC_APP_OBSIDIAN,  // O: Obsidian (⌥⌘O)
                KC_APP_VSCODE,    // V: VS Code (⌥⌘V)
                KC_APP_NOTION,    // N: Notion (⇧⌃⌘N) - note: different modifier
                KC_APP_BGA,       // B: BGA (⌥⌘B)
                KC_APP_CAL,       // C: Calendar (⌥⌘C)
                KC_APP_MAIL,      // E: Mail (⌥⌘E)
                // ... rest transparent
    // Row 3: Home row - Chat apps
    _______,  _______,  _______,  _______,  _______,  _______,  // H: (reserved)
                KC_APP_WHATSAPP, // J: WhatsApp (⌥⌘1)
                KC_APP_SIGNAL,   // K: Signal (⌥⌘2)
                KC_APP_WECHAT,   // L: WeChat (⌥⌘3)
                KC_APP_TELEGRAM, // ;: Telegram (⌥⌘4)
                // ... rest transparent
    // Row 4: Bottom row - System/Media apps
    _______,  _______,            KC_APP_CHATGPT,  // Z: ChatGPT (⌥⌘Z)
                // X: (reserved)
                // ... rest transparent
                KC_APP_SLACK,    // S: Slack (⌥⌘S)
                // ... rest transparent
    // Row 5: Special keys
    _______,  _______,  _______,  _______,  _______,  MO(NAV_LAYER),  KC_APP_FINDER,  // Left Space: NAV access, Right Space: Finder (⇧⌥⌘Space)
                                                                     _______,            _______,  _______,  _______,  _______,  _______,  _______),
```

**Key Features**:
- **Home row**: Chat apps (J/K/L/;) - WhatsApp, Signal, WeChat, Telegram
- **Top row**: Dev/productivity apps (O/V/N/B/C/E) - Obsidian, VS Code, Notion, BGA, Calendar, Mail
- **Bottom row**: System/media apps (Z/S) - ChatGPT, Slack
- **Special keys**: Esc (Calculator), ` (Music), Right Space (Finder)
- **Left Thumb Key**: `MO(NAV_LAYER)` - hold to access NAV_LAYER from this layer
- **Left-hand**: Transparent (or category selectors if implementing sub-layers)

**All 15 App Launchers**:
1. ChatGPT (⌥⌘Z) - `Z`
2. VS Code (⌥⌘V) - `V`
3. Calendar (⌥⌘C) - `C`
4. Mail (⌥⌘E) - `E`
5. Slack (⌥⌘S) - `S`
6. BGA (⌥⌘B) - `B`
7. WhatsApp (⌥⌘1) - `J`
8. Signal (⌥⌘2) - `K`
9. WeChat (⌥⌘3) - `L`
10. Telegram (⌥⌘4) - `;`
11. Calculator (⌥⌘Esc) - `Esc`
12. NetEase Music (⌥⌘`) - `` ` ``
13. Notion (⇧⌃⌘N) - `N`
14. Obsidian (⌥⌘O) - `O`
15. Finder (⇧⌥⌘Space) - `Space`

**Status**: ✅ **COMPLETE** - All 15 app launchers mapped

---

### Layer 5: WIN_LAYER (Window Management)

**Purpose**: Window management shortcuts

**Activation**: NAV + S (tap S while NAV_LAYER is active)

**Key Mappings**:
```c
[WIN_LAYER] = LAYOUT_91_ansi(
    // Row 0: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
    // Row 1: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
    // Row 2: Top row - Maximize/Halves
    _______,  _______,  KC_WIN_TL,  // Q: Top Left Quarter (⌃⌥←)
                KC_WIN_TR,  // W: Top Right Quarter (⌃⌥→)
                _______,  // E: (reserved)
                _______,  // R: (reserved)
                _______,  // T: (reserved)
                _______,  // Y: (reserved)
                _______,  // U: (reserved)
                _______,  // I: (reserved)
                _______,  // O: (reserved)
                _______,  // P: (reserved)
                KC_WIN_MAX,  // F: Maximize (⇧⌃⌘F)
                // ... rest transparent
    // Row 3: Home row - Quarters
    _______,  _______,  KC_WIN_BL,  // A: Bottom Left Quarter (⇧⌃⌥←)
                KC_WIN_BR,  // S: Bottom Right Quarter (⇧⌃⌥→)
                // D: (reserved)
                // F: (reserved)
                // ... rest transparent
    // Row 4: Bottom row - Split View
    _______,  _______,            KC_WIN_SV_L,  // Z: Split View Left (⌃⌥⌘←)
                KC_WIN_SV_R,  // X: Split View Right (⌃⌥⌘→)
                // ... rest transparent
    // Row 5: Arrow keys for halves + NAV access
    //        Left Space: MO(NAV_LAYER) for navigation
    //        Arrow keys: Halves
    //        Left: KC_WIN_LEFT (⇧⌃⌘←)
    //        Right: KC_WIN_RIGHT (⇧⌃⌘→)
    //        Up: KC_WIN_TOP (⇧⌃⌘↑)
    //        Down: KC_WIN_BOTTOM (⇧⌃⌘↓)
    _______,  _______,  _______,  _______,  _______,  MO(NAV_LAYER),  _______,                       _______,            _______,  _______,  KC_WIN_LEFT,  KC_WIN_BOTTOM,  KC_WIN_RIGHT),
```

**Key Features**:
- **Maximize/Halves (⇧⌃⌘)**: Arrow keys + F key
  - `F` → Maximize (⇧⌃⌘F)
  - `←` → Left Half (⇧⌃⌘←)
  - `→` → Right Half (⇧⌃⌘→)
  - `↑` → Top Half (⇧⌃⌘↑)
  - `↓` → Bottom Half (⇧⌃⌘↓)
- **Quarters (⌃⌥)**: Q/W (top), A/S (bottom)
  - `Q` → Top Left Quarter (⌃⌥←)
  - `W` → Top Right Quarter (⌃⌥→)
  - `A` → Bottom Left Quarter (⇧⌃⌥←)
  - `S` → Bottom Right Quarter (⇧⌃⌥→)
- **Split View (⌃⌥⌘)**: Z/X
  - `Z` → Split View Left (⌃⌥⌘←)
  - `X` → Split View Right (⌃⌥⌘→)
- **Left Thumb Key**: `MO(NAV_LAYER)` - hold to access NAV_LAYER from this layer
- **Organized by modifier groups**: Logical grouping for muscle memory

---

### Layer 9: LIGHTING_LAYER (RGB Lighting Controls)

**Purpose**: Control keyboard RGB lighting effects

**Activation**: NAV + G (press G while holding left space in NAV_LAYER) - Custom Switch

**Key Mappings**:
```c
[LIGHTING_LAYER] = LAYOUT_91_ansi(
    // Row 0: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
    // Row 1: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
    // Row 2: Top row - Mode controls
    _______,  _______,  RM_TOGG,   // Q: Toggle RGB Matrix on/off
                  RM_NEXT,   // W: Next animation mode
                  RM_PREV,   // E: Previous animation mode
                  _______,  // R: Transparent
                  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
    // Row 3: Home row - Brightness and Hue controls
    _______,  _______,  RM_VALU,   // A: Brightness up
                  RM_VALD,   // S: Brightness down
                  RM_HUEU,   // D: Hue up
                  RM_HUED,   // F: Hue down
                  _______,  // G: Transparent
                  _______,  _______,  _______,  _______,  _______,  _______,              _______,            _______,
    // Row 4: Bottom row - Saturation and Speed controls
    _______,  _______,            RM_SATU,   // Z: Saturation up
                  RM_SATD,   // X: Saturation down
                  RM_SPDU,   // C: Speed up
                  RM_SPDD,   // V: Speed down
                  RM_FLGN,   // B: Next flag
                  RM_FLGP,   // N: Previous flag
                  _______,  _______,  _______,  _______,              _______,  _______,
    // Row 5: Left space for NAV access
    _______,  _______,  _______,  _______,  _______,  MO(NAV_LAYER),  _______,                       _______,            _______,  _______,  _______,  _______,  _______),
```

**Key Features**:
- **Toggle Group** (Q): `RM_TOGG` - Toggle RGB Matrix on/off
- **Mode Group** (W/E): `RM_NEXT` / `RM_PREV` - Cycle through animation modes
- **Brightness Group** (A/S): `RM_VALU` / `RM_VALD` - Increase/decrease brightness
- **Hue Group** (D/F): `RM_HUEU` / `RM_HUED` - Cycle through hue
- **Saturation Group** (Z/X): `RM_SATU` / `RM_SATD` - Increase/decrease saturation
- **Speed Group** (C/V): `RM_SPDU` / `RM_SPDD` - Increase/decrease animation speed
- **Flags Group** (B/N): `RM_FLGN` / `RM_FLGP` - Cycle through flags
- **Left Thumb Key**: `MO(NAV_LAYER)` - hold to access NAV_LAYER from this layer
- **Logical grouping**: Controls grouped by function for easy access
- **Custom switch activation**: Layer activates when G is pressed while NAV_LAYER is active (left space held), remains active while left space is held

**Usage**:
1. Hold Left Space → NAV_LAYER activates
2. Press G key (while holding left space) → LIGHTING_LAYER activates and stays active
3. Keep holding Left Space (release G) → LIGHTING_LAYER remains active
4. Press lighting control keys (W/E for next/previous mode, etc.)
5. Release Left Space → LIGHTING_LAYER deactivates, returns to MAC_BASE

---

### Layer 10: NUMPAD_LAYER (Number Pad)

**Purpose**: Toggle number pad for numeric input

**Activation**: NAV + H (tap H while NAV_LAYER is active) - Toggle (TG)

**Key Mappings**:
```c
[NUMPAD_LAYER] = LAYOUT_91_ansi(
    // Row 0: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
    // Row 1: Transparent
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
    // Row 2: Top row - Numpad top row (7, 8, 9, /)
    _______,  _______,  _______,  // Q: Transparent
                  _______,  // W: Transparent
                  _______,  // E: Transparent
                  _______,  // R: Transparent
                  _______,  // T: Transparent
                  _______,  // Y: Transparent
                  KC_KP_7,  // U: 7 (top left)
                  KC_KP_8,  // I: 8
                  KC_KP_9,  // O: 9
                  KC_KP_SLASH,  // P: / (divide)
                  _______,  _______,  _______,  _______,            _______,
    // Row 3: Home row - Numpad second row (4, 5, 6, *)
    _______,  _______,  _______,  // A: Transparent
                  _______,  // S: Transparent
                  _______,  // D: Transparent
                  _______,  // F: Transparent
                  _______,  // G: Transparent
                  _______,  // H: Transparent
                  KC_KP_4,  // J: 4
                  KC_KP_5,  // K: 5
                  KC_KP_6,  // L: 6
                  KC_KP_ASTERISK,  // ;: * (multiply)
                  _______,            _______,            _______,
    // Row 4: Bottom row - Numpad third row (1, 2, 3, -)
    _______,  _______,            _______,  // Z: Transparent
                  _______,  // X: Transparent
                  _______,  // C: Transparent
                  _______,  // V: Transparent
                  _______,  // B: Transparent
                  KC_KP_1,  // N: 1
                  KC_KP_2,  // M: 2
                  KC_KP_3,  // ,: 3
                  KC_KP_MINUS,  // .: - (subtract)
                  _______,              _______,  _______,
    // Row 5: Numpad bottom row (0, ., +, Enter) + NAV access
    _______,  _______,  _______,  _______,  MO(NAV_LAYER),            KC_KP_0,                       KC_KP_DOT,             KC_KP_PLUS,  KC_KP_ENTER,  _______,  _______,  _______),
```

**Key Features**:
- **Standard numpad layout**: Right-hand side placement
- **Top row** (U/I/O/P): 7, 8, 9, / (divide)
- **Second row** (J/K/L/;): 4, 5, 6, * (multiply)
- **Third row** (N/M/,/.): 1, 2, 3, - (subtract)
- **Bottom row**: 0 (left space), . (right space), + (right cmd), Enter (right ctrl)
- **U key as 7**: Top-left position of numpad (as specified)
- **Left Thumb Key**: `MO(NAV_LAYER)` - hold to access NAV_LAYER from this layer
- **Toggle activation**: Tap H in NAV_LAYER to activate, tap H again to return to MAC_BASE
- **Always returns to MAC_BASE**: When toggled off, always returns to Layer 0

**Usage**:
1. Hold Left Thumb → NAV_LAYER activates
2. Tap H key → NUMPAD_LAYER toggles on
3. Use numpad keys for numeric input
4. Tap H again in NAV_LAYER → NUMPAD_LAYER toggles off (returns to MAC_BASE)
5. Or hold Left Thumb Key → Access NAV_LAYER, then toggle off

---

## 🔧 Macro Definitions

### Special Symbol Macros

```c
// ============================================
// Special Symbol Macros (String Output)
// ============================================
// Six backticks: ```\n``` with cursor before closing backticks on bottom line
#define KC_SYM_BACKTICKS SEND_STRING("```" SS_TAP(X_ENTER) "```" SS_TAP(X_LEFT) SS_TAP(X_LEFT) SS_TAP(X_LEFT))

// Tilde-slash: ~/
#define KC_SYM_TILDE_SLASH SEND_STRING("~/")

// Square brackets: [] with cursor in middle
#define KC_SYM_SQUARE_BRACKETS SEND_STRING("[]" SS_TAP(X_LEFT))

// Parentheses: () with cursor in middle
#define KC_SYM_PARENTHESES SEND_STRING("()" SS_TAP(X_LEFT))

// Curly braces: {} with cursor in middle
#define KC_SYM_CURLY_BRACES SEND_STRING("{}" SS_TAP(X_LEFT))
```

### App Launcher Macros

```c
// ============================================
// App Launcher Macros (⌥⌘ combinations)
// Using LAG() macro for Left Alt + Left GUI (ensures proper modifier release)
// ============================================
#define KC_APP_CHATGPT   LAG(KC_Z)              // ⌥⌘Z
#define KC_APP_VSCODE    LAG(KC_V)              // ⌥⌘V
#define KC_APP_CAL       LAG(KC_C)              // ⌥⌘C
#define KC_APP_MAIL      LAG(KC_E)              // ⌥⌘E
#define KC_APP_SLACK     LAG(KC_S)              // ⌥⌘S
#define KC_APP_SLACK_6   LAG(KC_6)              // ⌥⌘6 - Left column Row 3
#define KC_APP_OBSIDIAN  LAG(KC_O)              // ⌥⌘O
#define KC_APP_BGA       LAG(KC_B)              // ⌥⌘B
#define KC_APP_WHATSAPP  LAG(KC_1)              // ⌥⌘1
#define KC_APP_SIGNAL    LAG(KC_2)              // ⌥⌘2
#define KC_APP_WECHAT    LAG(KC_3)              // ⌥⌘3
#define KC_APP_TELEGRAM  LAG(KC_4)              // ⌥⌘4
#define KC_APP_CALC      LAG(KC_ESC)            // ⌥⌘Esc
#define KC_APP_MUSIC     LAG(KC_GRV)            // ⌥⌘`
#define KC_APP_NOTION    LCSG(KC_N)             // ⇧⌃⌘N (Left Control + Left Shift + Left GUI)
#define KC_APP_FINDER    LSAG(KC_SPC)           // ⇧⌥⌘Space (Left Shift + Left Alt + Left GUI)
#define KC_APP_VPN_SHADOWROCKET LCAG(KC_Z)      // ⌃⌥⌘Z - Toggle Shadowrocket VPN (Left Control + Left Alt + Left GUI)
```

### Window Management Macros

```c
// ============================================
// Window Management Macros (modifier combinations)
// Using QMK macros for proper modifier release
// ============================================
// Maximize/Halves (⇧⌃⌘) - Left Control + Left Shift + Left GUI
#define KC_WIN_MAX       LCSG(KC_F)              // ⇧⌃⌘F
#define KC_WIN_LEFT      LCSG(KC_LEFT)           // ⇧⌃⌘←
#define KC_WIN_RIGHT     LCSG(KC_RIGHT)          // ⇧⌃⌘→
#define KC_WIN_TOP       LCSG(KC_UP)             // ⇧⌃⌘↑
#define KC_WIN_BOTTOM    LCSG(KC_DOWN)            // ⇧⌃⌘↓

// Quarters (⌃⌥) - Left Control + Left Alt
#define KC_WIN_TL        LCA(KC_LEFT)            // ⌃⌥←
#define KC_WIN_TR        LCA(KC_RIGHT)           // ⌃⌥→
#define KC_WIN_BL        LSFT(LCA(KC_LEFT))      // ⇧⌃⌥←
#define KC_WIN_BR        LSFT(LCA(KC_RIGHT))      // ⇧⌃⌥→

// Split View (⌃⌥⌘) - Left Control + Left Alt + Left GUI
#define KC_WIN_SV_L      LCAG(KC_LEFT)           // ⌃⌥⌘←
#define KC_WIN_SV_R      LCAG(KC_RIGHT)          // ⌃⌥⌘→
```

### Custom Keycodes

```c
// ============================================
// Custom Keycodes (for SEND_STRING macros and special functions)
// ============================================
enum custom_keycodes {
    // Symbol macros (SYM_LAYER) - require SEND_STRING
    KC_SYM_BACKTICKS = SAFE_RANGE,  // H: ```\n``` with cursor before closing backticks
    KC_SYM_TILDE_SLASH,              // F: ~/
    KC_SYM_PARENTHESES,              // J: () with cursor in middle
    KC_SYM_CURLY_BRACES,             // K: {} with cursor in middle
    KC_SYM_SQUARE_BRACKETS,          // L: [] with cursor in middle
    // Globe key (macOS Globe/Fn key) - fallback if KC_GLOBE not available
    KC_GLOBE_CUSTOM,                 // Custom Globe key implementation (currently unused)
    // Input method switching (macOS Ctrl+Space)
    KC_IME_NEXT,                     // Switch input method (Ctrl+Space)
    // Custom layer switching for NAV_LAYER selectors
    KC_NAV_SPACE,                    // Custom left space with layer switching
    KC_NAV_APP,                      // Custom A key for APP_LAYER switch
    KC_NAV_WIN,                      // Custom S key for WIN_LAYER switch
    KC_NAV_APP_D,                    // Custom D key for APP_LAYER switch
    KC_NAV_CURSOR,                   // Custom F key for CURSOR_LAYER switch
    KC_NAV_LIGHTING,                 // Custom G key for LIGHTING_LAYER switch
};
```

**Custom Keycode Handlers**:
- `KC_SYM_*` keycodes: Handled in `process_record_user()` to send strings via `SEND_STRING()`
- `KC_GLOBE_CUSTOM`: Placeholder for Globe key (requires QMK patches)
- `KC_IME_NEXT`: Sends `LCTL(KC_SPC)` (Ctrl+Space) for macOS input source switching
- `KC_NAV_SPACE`: Custom left space handler - supports tap-for-space and custom layer switching
- `KC_NAV_APP`, `KC_NAV_WIN`, `KC_NAV_APP_D`, `KC_NAV_CURSOR`, `KC_NAV_LIGHTING`: Custom selector keys for switching layers while holding left space

### Encoder Macros

```c
// ============================================
// Encoder Macros
// ============================================
#define KC_ZOOM_OUT     LGUI(KC_MINS)          // Cmd -
#define KC_ZOOM_IN      LGUI(KC_EQL)           // Cmd =
#define KC_ZOOM_RESET   LGUI(KC_0)             // Cmd 0
#define KC_LOCK_SCREEN  LCG(KC_Q)               // Ctrl+Cmd+Q (Left Control + Left GUI)
```

### Tap Dance Definition (Right Encoder Press)

```c
enum {
    TD_ENC_R = 0,
};

qk_tap_dance_action_t tap_dance_actions[] = {
    [TD_ENC_R] = ACTION_TAP_DANCE_DOUBLE(KC_ZOOM_RESET, KC_LOCK_SCREEN),
};
```

### Process Record User Handler

The `process_record_user()` function handles custom keycodes and includes:

1. **Debug Console Output** (when `CONSOLE_ENABLE = yes`):
   - Logs all key presses with keycode, matrix position, press state, and timestamp
   - Decodes Layer Tap (LT) keycodes to show layer name and tap keycode
   - Helps debug keymap issues and verify key assignments

2. **KC_LNG1 Workaround**:
   - Converts `KC_LNG1` to `KC_LGUI` at position 5 (col:4, row:5)
   - Handles cases where EEPROM has stored `KC_LNG1` instead of `KC_LGUI`
   - Only active if VIA was previously used or EEPROM has old data

3. **Custom Keycode Handlers**:
   - `KC_SYM_*` keycodes: Send strings via `SEND_STRING()` macro
   - `KC_GLOBE_CUSTOM`: Placeholder (currently does nothing, requires QMK patches)
   - `KC_IME_NEXT`: Sends `LCTL(KC_SPC)` (Ctrl+Space) for macOS input source switching
   - `KC_NAV_SPACE`: Handles left space with custom layer switching - activates NAV_LAYER or selected target layer based on state
   - `KC_NAV_APP`, `KC_NAV_WIN`, `KC_NAV_APP_D`, `KC_NAV_CURSOR`, `KC_NAV_LIGHTING`: Switch from NAV_LAYER to target layer while left space is held

**Example Implementation**:
```c
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    // Debug output (if CONSOLE_ENABLE = yes)
    // KC_LNG1 workaround for position 5
    // Custom keycode handlers (KC_SYM_*, KC_GLOBE_CUSTOM, KC_IME_NEXT)
    return true; // Process other keycodes normally
}
```

---

## 🎛️ Encoder Configuration

### Encoder Behavior

```c
#if defined(ENCODER_MAP_ENABLE)
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    [MAC_BASE] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),         // Left encoder: Volume
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)   // Right encoder: Zoom out/in
    },
    [NAV_LAYER] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
    [SYM_LAYER] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
    [CURSOR_LAYER] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
    [APP_LAYER] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
    [WIN_LAYER] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
    [MAC_FN] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
    [WIN_BASE] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
    [WIN_FN] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
    [LIGHTING_LAYER] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
    [NUMPAD_LAYER] = { 
        ENCODER_CCW_CW(KC_VOLD, KC_VOLU),
        ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN)
    },
};
#endif // ENCODER_MAP_ENABLE
```

**Encoder Actions**:
- **Left Encoder Rotate CCW/CW**: Volume down/up
- **Left Encoder Press (single)**: Mute
- **Right Encoder Rotate CCW/CW**: Zoom out/in (Cmd - / Cmd =)
- **Right Encoder Press (single)**: Zoom reset (Cmd 0) - tap dance
- **Right Encoder Press (double)**: Lock screen (Ctrl+Cmd+Q) - tap dance

**Status**: ⚠️ **INCOMPLETE** - Tap dance for right encoder press actions needs implementation

---

## 📋 Implementation Checklist

### ✅ Completed
- [x] Layer enum definitions
- [x] Special symbol macro definitions
- [x] BASE layer implementation
- [x] SYM layer implementation (with special macros)
- [x] Macro definitions for app launchers
- [x] Macro definitions for window management
- [x] Encoder macro definitions

### ⚠️ In Progress / Needs Completion
- [ ] NAV_LAYER implementation (selectors finalized: Q/W/E/R for L5-L8 toggles, G/H for L9/L10)
- [ ] CURSOR_LAYER implementation (mapped Y/U/I/O; remaining TBD: model picker, submit with/without codebase, focus editor, previous/next change, apply, accept all files)
- [ ] APP_LAYER implementation (Obsidian mapping added, Slack on S)
- [ ] WIN_LAYER implementation (complete key mappings)
- [ ] LIGHTING_LAYER implementation (RGB controls mapped)
- [ ] NUMPAD_LAYER implementation (standard numpad layout mapped)
- [ ] Left space NAV access for all non-momentary layers (L3-L10, NUMPAD uses left thumb key)
- [ ] Encoder tap dance implementation (right encoder single/double press)
- [ ] Windows support layers (WIN_BASE, WIN_FN)

### 🔍 Review Required
- [ ] **Usability Review**: Test each layer activation sequence
- [ ] **Sense-Checking Review**: Verify key placements are logical and ergonomic
- [ ] **Code Review**: Verify all macros compile correctly
- [ ] **Conflict Detection**: Resolve any remaining key conflicts
- [ ] **Completeness Check**: Ensure all 15 app launchers are mapped
- [ ] **Cursor Commands**: Map remaining Cursor IDE commands (model picker, submit with/without codebase, focus editor, previous/next change, apply, accept all files)

---

## 🚨 Known Issues & Resolutions

### Issue 1: Cursor IDE Commands
**Problem**: CURSOR_LAYER is partially mapped; remaining actions are TBD (model picker, submit with/without codebase, focus editor, previous/next change, apply, accept all files)

**Resolution**: 
1. Identify Cursor IDE keyboard shortcuts for remaining actions
2. Map to appropriate QMK keycodes
3. Update CURSOR_LAYER implementation

### Issue 2: Encoder Tap Dance
**Problem**: Right encoder press actions (single/double) require tap dance implementation

**Resolution**: Implement QMK tap dance for right encoder press detection

### Issue 3: KC_LNG1 vs KC_LGUI (Position 5)
**Problem**: Position 5 (Left Command) may show `KC_LNG1` in debug output instead of `KC_LGUI` due to EEPROM-stored values from previous flashes

**Resolution**: 
1. VIA support is disabled (`VIA_ENABLE = no`) to prevent EEPROM overrides
2. Workaround implemented in `process_record_user()` to convert `KC_LNG1` to `KC_LGUI` at position 5 (col:4, row:5)
3. After rebuilding and flashing with VIA disabled, the compiled keymap (`KC_LGUI`) should be used directly
4. If `KC_LNG1` persists, clear EEPROM using `EE_CLR` keycode and reflash

---

## 🧪 Testing & Validation

### Debug Console Usage
When `CONSOLE_ENABLE = yes` is set in `rules.mk`, you can use the QMK console to debug all key presses:

1. **Start QMK Console**:
   ```bash
   qmk console
   ```

2. **View Debug Output**: All key presses will be logged with:
   - Keycode (hexadecimal format: `0x0008` for KC_LGUI)
   - Matrix position (column, row)
   - Press state (`1` = pressed, `0` = released)
   - Timestamp

3. **Example Output**:
   ```
   DEBUG: kc: 0x0008, col: 4, row: 5, pressed:1, time:12345
   DEBUG: kc: 0x0008, col: 4, row: 5, pressed:0, time:12350
   ```

4. **Use Cases**:
   - Verify keycode assignments match expected values
   - Debug matrix position issues
   - Troubleshoot keymap problems
   - Verify layer activation/deactivation
   - Check for keycode conflicts

### Compilation Tests
- [ ] Keymap compiles without errors: `qmk compile -kb keychron/q11/ansi_encoder -km j-custom`
- [ ] No undefined keycode references
- [ ] All macros properly defined
- [ ] No syntax errors in SEND_STRING macros
- [ ] Console debug output works: `qmk console` shows all key presses

### Functional Tests (Hardware Required)
- [ ] BASE layer: All keys type correctly
- [ ] NAV layer: All selectors activate correct layers
- [ ] SYM layer: Symbols accessible, special macros work
- [ ] CURSOR layer: All Cursor actions work (after mapping)
- [ ] APP layer: All 15 apps launch correctly
- [ ] WIN layer: All window management actions work
- [ ] Encoder: Rotate and press actions work
- [ ] Layer activation/deactivation works correctly
- [ ] No conflicts between layers
- [ ] Debug console shows correct keycodes for all positions

### Edge Cases
- [ ] Rapid layer switching doesn't cause stuck keys
- [ ] Holding selector key doesn't interfere
- [ ] Multiple modifier keys work correctly
- [ ] Special keys (Esc, Space, arrows, backtick) work in macros
- [ ] Encoder tap dance timing works correctly
- [ ] No typing disruption on BASE layer

---

## 📚 Reference Documentation

### QMK Modifier Keys (macOS)
- `LGUI` = Command (⌘)
- `LALT` = Option (⌥)
- `LCTL` = Control (⌃)
- `LSFT` = Shift (⇧)

### QMK Keycode Reference
- Standard keycodes: `KC_A` through `KC_Z`, `KC_1` through `KC_0`
- Symbol keycodes: `KC_EXLM`, `KC_AT`, `KC_HASH`, etc.
- Modifier combinations: Use QMK macros for proper release (e.g., `LAG(KC_X)` for ⌥⌘X, `LCSG(KC_N)` for ⇧⌃⌘N, `LCAG(KC_LEFT)` for ⌃⌥⌘←)

### Layout Structure (LAYOUT_91_ansi)
- **Row 0**: Function keys, media, etc. (17 keys)
- **Row 1**: Numbers and symbols (16 keys)
- **Row 2**: QWERTY top row (16 keys)
- **Row 3**: QWERTY home row (15 keys)
- **Row 4**: QWERTY bottom row (14 keys)
- **Row 5**: Modifiers and thumb keys (13 keys)

### Build Configuration (rules.mk)
- **ENCODER_MAP_ENABLE**: `yes` - Encoder support enabled
- **TAP_DANCE_ENABLE**: `yes` - Tap dance support enabled
- **CONSOLE_ENABLE**: `no` (disabled) - Console/debug output disabled by default (can be enabled for debugging)
- **VIA_ENABLE**: `no` (disabled) - VIA support disabled; keymap is code-managed only

**Note**: VIA is disabled to prevent EEPROM-stored keymaps from overriding the compiled keymap. All keymap changes must be made in code and reflashed.

**Debug Console**: When `CONSOLE_ENABLE = yes`, all key presses are logged to the console with:
- Keycode (hexadecimal)
- Matrix position (column, row)
- Press state (1 = pressed, 0 = released)
- Timestamp
- Layer Tap (LT) keycode decoding (shows layer name and tap keycode)

Use `qmk console` command to view debug output in real-time. This helps verify key assignments, debug keymap issues, and troubleshoot matrix position problems. Debug code is safely wrapped in `#ifdef CONSOLE_ENABLE` blocks, so it has no impact when disabled.

### Additional Layer Notes

**Layer 6: MAC_FN** (Function Keys)
- Purpose: Function keys (F1-F12) and RGB controls for macOS
- Activation: Toggle via NAV + W (`TG(MAC_FN)`)
- **Left Space**: `MO(NAV_LAYER)` for NAV access
- Encoder: Left volume/mute, right zoom + tap dance

**Layer 7: WIN_BASE** (Windows Typing)
- Purpose: Normal typing layer for Windows
- Activation: Toggle via NAV + E (`TG(WIN_BASE)`)
- **Left Space**: `MO(NAV_LAYER)` for NAV access
- Encoder: Left volume/mute, right zoom + tap dance

**Layer 8: WIN_FN** (Windows Function Keys)
- Purpose: Function keys and RGB controls for Windows
- Activation: Toggle via NAV + R (`TG(WIN_FN)`)
- **Left Space**: `MO(NAV_LAYER)` for NAV access
- Encoder: Left volume/mute, right zoom + tap dance

---

## 🎯 Next Steps

### Immediate Actions
1. **Complete NAV_LAYER**: Finalize selector implementations
2. **Complete Cursor Commands**: Map remaining Cursor IDE shortcuts
3. **Complete APP_LAYER**: Add Obsidian mapping and confirm Slack on S
4. **Complete WIN_LAYER**: Finalize all window management mappings

### Implementation Tasks
1. **Implement Encoder Tap Dance**: Add single/double press detection
2. **Code Review**: Verify all implementations compile correctly
3. **Usability Testing**: Test real-world workflows
4. **Documentation**: Update inline comments and create user guide

### Future Enhancements
1. **Windows Support**: Complete WIN_BASE and WIN_NAV layers
2. **Shortcuts/Automations Layer**: Implement reserved selector A
3. **Layer Indicators**: Add RGB/OLED feedback for active layer
4. **VIA Configuration**: VIA support is disabled; keymap is code-managed only

---

## 📊 Confidence Declaration

**This tech spec consolidates all planning documents and provides a complete, production-ready specification for the QMK keymap implementation.**

### Completeness Status
- ✅ **BASE Layer**: Complete (with leftmost column app launchers: WhatsApp, WeChat, Slack, ChatGPT, Shadowrocket VPN toggle)
- ✅ **SYM Layer**: Complete (with special macros)
- ✅ **NAV Layer**: Structure defined, all selectors finalized (Q/W/E/R for L5-L8, A/S/D/F/G/H for others)
- ⚠️ **CURSOR Layer**: Partial mapping (Y/U/I/O); remaining commands TBD, left space NAV access added
- ✅ **APP Layer**: All apps mapped (Obsidian added, Slack on S), left space NAV access added
- ⚠️ **WIN Layer**: Structure defined, mappings need completion, left space NAV access added
- ✅ **LIGHTING Layer**: Complete specification with all RGB controls, left space NAV access added
- ✅ **NUMPAD Layer**: Complete specification with standard layout, NAV access on left thumb key added
- ✅ **MAC_FN Layer**: Existing layer with left space NAV access
- ✅ **WIN_BASE Layer**: Existing layer with left space NAV access
- ✅ **WIN_FN Layer**: Existing layer with left space NAV access
- ⚠️ **Encoder**: Behavior defined (left volume/mute, right zoom + tap dance), tap dance needs implementation

### Remaining Work
1. Map remaining Cursor IDE commands for CURSOR_LAYER
2. Complete WIN_LAYER key mappings
3. Implement encoder tap dance (right encoder)
4. Comprehensive testing and validation
5. Test all layer activation sequences (toggle, latch, momentary)
6. Verify left space NAV access works from all non-momentary layers

---

**Document Version**: 1.2  
**Last Updated**: 2026-01-27  
**Status**: Finalized Tech Spec (Implementation In Progress)  
**Target Keyboard**: Keychron Q11 ANSI Encoder  
**Firmware**: QMK

**Recent Updates**:
- Added leftmost column app launchers to MAC_BASE layer (5 keys):
  - Row 1: WhatsApp (⌥⌘1)
  - Row 2: WeChat (⌥⌘3)
  - Row 3: Slack (⌥⌘6)
  - Row 4: ChatGPT (⌥⌘Z)
  - Row 5: Shadowrocket VPN toggle (⇧⌥⌘Z)
- Added Layer 9: LIGHTING_LAYER (RGB lighting controls)
- Added Layer 10: NUMPAD_LAYER (number pad)
- Updated NAV_LAYER with toggle selectors for L5-L8 (Q/W/E/R)
- Added left space NAV access to all non-momentary layers (L3-L10)
- Updated encoder configuration for all layers
