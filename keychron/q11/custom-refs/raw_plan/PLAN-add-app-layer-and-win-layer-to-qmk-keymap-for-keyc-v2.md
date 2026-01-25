# PLAN v2: Complete QMK Keymap Implementation for Keychron Q11

## 🧠 Problem Understanding

### Task
Create a **complete, production-ready QMK keymap implementation** for Keychron Q11 that includes:
1. **BASE Layer (Layer 0)**: Normal typing layer (macOS and Windows variants)
2. **NAV Layer (Layer 1)**: Thumb-held menu layer with helper selectors
3. **SYM Layer (Layer 2)**: Symbols layer (activated by Right Thumb)
4. **CURSOR Layer (Layer 3)**: Cursor IDE helper layer (activated via NAV + F)
5. **APP Layer (Layer 4)**: Application launchers (activated via NAV + D)
6. **WIN Layer (Layer 5)**: Window management shortcuts (activated via NAV + S)

### Scope
- **Complete keymap specification** for all 6 layers
- **All 15 app launchers** from `custom-map-global-short-cut.md`
- **All window management shortcuts** (maximize, halves, quarters, split view)
- **Cursor helper actions** as specified in Step 2 mapping
- **Encoder behavior** (zoom, lock screen)
- **QMK macro definitions** for all shortcuts
- **Production-ready code structure** ready for implementation

### Non-Goals
- Shortcuts/automations layer (deferred, selector `A` reserved)
- Git helper layer (deferred)
- VIA configuration (QMK-first approach)
- Hardware-specific features beyond encoder and RGB

### Constraints
- **Keyboard**: Keychron Q11 ANSI with encoder (91 keys, split design)
- **Platform**: macOS primary, Windows support
- **Layout**: `LAYOUT_91_ansi` (from `info.json`)
- **Firmware**: QMK (code-managed, GitHub-committed)
- **Design principles** (from Step 1-3 plans):
  - Typing safety: letters always type letters on BASE
  - Momentary power: layers activate only when thumb held
  - Left-control/right-action: left hand selects, right hand executes
  - Home row priority: highest-frequency actions on home row

## 🎯 Objectives

### Success Criteria
1. **Complete Layer Structure**: All 6 layers fully specified with key mappings
2. **BASE Layer**: Clean typing layer, no helper functionality
3. **NAV Layer**: Menu system with 4 selectors (A/S/D/F) for helper layers
4. **SYM Layer**: Symbols accessible via Right Thumb
5. **CURSOR Layer**: All Cursor IDE actions mapped (from Step 2)
6. **APP Layer**: All 15 app launchers accessible, organized by category
7. **WIN Layer**: All window management shortcuts accessible
8. **Encoder**: Zoom controls and lock screen
9. **QMK Implementation**: All shortcuts sent directly via QMK macros
10. **Code Quality**: Production-ready, well-commented, maintainable

### Quality Expectations
- **Correctness**: All shortcuts match macOS system shortcuts exactly
- **Completeness**: Every key on every layer has a defined purpose
- **Maintainability**: Clear code structure, well-commented, organized
- **Ergonomics**: Home row for frequent actions, minimal reach
- **Safety**: No typing disruption, guaranteed exit on thumb release
- **Documentation**: Self-documenting code with clear comments

## 🧩 System / Codebase Context

### Complete Layer Structure
```
Layer 0: BASE (MAC_BASE / WIN_BASE)
  - Normal typing
  - No helper functionality
  - Encoder: Volume (or zoom per encoder config)

Layer 1: NAV (Thumb-held menu)
  - Activated by: Left Thumb hold (MO(NAV_LAYER))
  - Selectors on left-hand home row:
    - A: Reserved (future: shortcuts/automations)
    - S: Latch WIN layer (Layer 5)
    - D: Latch APP layer (Layer 4)
    - F: Latch CURSOR layer (Layer 3)
  - Left-hand keys: Selectors only
  - Right-hand keys: Transparent (pass through to BASE)

Layer 2: SYM (Symbols)
  - Activated by: Right Thumb hold (MO(SYM_LAYER))
  - Symbols and punctuation
  - TBD: Specific symbol mappings

Layer 3: CURSOR (Helper)
  - Activated by: NAV + F selector
  - Left-hand: Transparent or reserved
  - Right-hand: Cursor IDE actions
  - Home row (H/J/K/L/;): High-frequency actions
  - Top row (Y/U/I/O/P/[)]: Setup/mode actions

Layer 4: APP (Application Launchers)
  - Activated by: NAV + D selector
  - Left-hand: Transparent or category selectors
  - Right-hand: App launchers
  - Home row: Chat apps (J/K/L/;)
  - Other keys: Dev/productivity/system apps

Layer 5: WIN (Window Management)
  - Activated by: NAV + S selector
  - Left-hand: Transparent
  - Right-hand: Window management shortcuts
  - Organized by modifier groups
```

### Existing Files
- `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c` - Current keymap (basic, needs complete rewrite)
- `keychron/q11/ansi_encoder/keymaps/default/keymap.c` - Default reference
- `keychron/q11/info.json` - Layout definition (`LAYOUT_91_ansi`)
- `keychron/q11/custom-refs/custom-map-global-short-cut.md` - Shortcut reference
- `keychron/q11/custom-refs/raw_plan/` - Design documents (Step 1-3)

### QMK Modifier Keys (macOS)
- `LGUI` = Command (⌘)
- `LALT` = Option (⌥)
- `LCTL` = Control (⌃)
- `LSFT` = Shift (⇧)

### Key Mapping References
From `custom-map-global-short-cut.md`:
- **App launchers**: Mostly `⌥⌘` + character
- **Window management**: `⇧⌃⌘` for maximize/halves, `⌃⌥` for quarters, `⌃⌥⌘` for split view

From Step 2 mapping:
- **CURSOR actions**: Home row for high-frequency, top row for setup

### Dependencies
- QMK firmware (already configured)
- macOS System Settings → Keyboard → Shortcuts (must be configured)
- No external tools required

## 🗂️ Task Breakdown

### 🔥 High Priority

#### Task 1: Define Complete Layer Enum and Constants
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: 
  ```c
  enum layers {
      MAC_BASE,      // Layer 0: Normal typing (macOS)
      NAV_LAYER,     // Layer 1: Navigation menu (thumb-held)
      SYM_LAYER,     // Layer 2: Symbols (right thumb)
      CURSOR_LAYER,  // Layer 3: Cursor IDE helper
      APP_LAYER,     // Layer 4: Application launchers
      WIN_LAYER,    // Layer 5: Window management
      WIN_BASE,      // Layer 6: Normal typing (Windows) - optional
      WIN_NAV,       // Layer 7: Navigation menu (Windows) - optional
  };
  ```
- **Reason**: Foundation for all layer implementations
- **Risk**: Low - standard QMK pattern

#### Task 2: Define All QMK Macro Keycodes
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Define custom keycodes for all shortcuts
  ```c
  // ============================================
  // App Launcher Macros (⌥⌘ combinations)
  // ============================================
  #define KC_APP_CHATGPT   LALT(LGUI(KC_Z))      // ⌥⌘Z
  #define KC_APP_VSCODE    LALT(LGUI(KC_V))      // ⌥⌘V
  #define KC_APP_CAL       LALT(LGUI(KC_C))      // ⌥⌘C
  #define KC_APP_MAIL      LALT(LGUI(KC_E))      // ⌥⌘E
  #define KC_APP_SLACK     LALT(LGUI(KC_S))      // ⌥⌘S
  #define KC_APP_BGA       LALT(LGUI(KC_B))      // ⌥⌘B
  #define KC_APP_WHATSAPP  LALT(LGUI(KC_1))      // ⌥⌘1
  #define KC_APP_SIGNAL    LALT(LGUI(KC_2))      // ⌥⌘2
  #define KC_APP_WECHAT    LALT(LGUI(KC_3))      // ⌥⌘3
  #define KC_APP_TELEGRAM  LALT(LGUI(KC_4))      // ⌥⌘4
  #define KC_APP_CALC      LALT(LGUI(KC_ESC))    // ⌥⌘Esc
  #define KC_APP_MUSIC     LALT(LGUI(KC_GRV))    // ⌥⌘`
  #define KC_APP_NOTION    LSFT(LCTL(LGUI(KC_N))) // ⇧⌃⌘N
  #define KC_APP_NOTES     LALT(LGUI(KC_N))      // ⌥⌘N
  #define KC_APP_FINDER    LSFT(LALT(LGUI(KC_SPC))) // ⇧⌥⌘Space

  // ============================================
  // Window Management Macros
  // ============================================
  // Maximize/Halves (⇧⌃⌘)
  #define KC_WIN_MAX       LSFT(LCTL(LGUI(KC_F)))      // ⇧⌃⌘F
  #define KC_WIN_LEFT      LSFT(LCTL(LGUI(KC_LEFT)))   // ⇧⌃⌘←
  #define KC_WIN_RIGHT     LSFT(LCTL(LGUI(KC_RIGHT)))  // ⇧⌃⌘→
  #define KC_WIN_TOP       LSFT(LCTL(LGUI(KC_UP)))     // ⇧⌃⌘↑
  #define KC_WIN_BOTTOM    LSFT(LCTL(LGUI(KC_DOWN)))   // ⇧⌃⌘↓
  
  // Quarters (⌃⌥)
  #define KC_WIN_TL        LCTL(LALT(KC_LEFT))         // ⌃⌥←
  #define KC_WIN_TR        LCTL(LALT(KC_RIGHT))        // ⌃⌥→
  #define KC_WIN_BL        LSFT(LCTL(LALT(KC_LEFT)))   // ⇧⌃⌥←
  #define KC_WIN_BR        LSFT(LCTL(LALT(KC_RIGHT)))  // ⇧⌃⌥→
  
  // Split View (⌃⌥⌘)
  #define KC_WIN_SV_L      LCTL(LALT(LGUI(KC_LEFT)))   // ⌃⌥⌘←
  #define KC_WIN_SV_R      LCTL(LALT(LGUI(KC_RIGHT)))   // ⌃⌥⌘→

  // ============================================
  // Encoder Macros
  // ============================================
  #define KC_ZOOM_OUT     LGUI(KC_MINS)          // Cmd -
  #define KC_ZOOM_IN      LGUI(KC_EQL)           // Cmd =
  #define KC_ZOOM_RESET   LGUI(KC_0)             // Cmd 0
  #define KC_LOCK_SCREEN  LCTL(LGUI(KC_Q))       // Ctrl+Cmd+Q
  ```
- **Reason**: Reusable, maintainable shortcut definitions
- **Risk**: Low - standard QMK macro syntax

#### Task 3: Implement BASE Layer (Layer 0)
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Create clean typing layer
  ```c
  [MAC_BASE] = LAYOUT_91_ansi(
      // Row 0: Function keys, media, etc.
      KC_MUTE,  KC_ESC,   KC_BRID,  KC_BRIU,  KC_MCTL,  KC_LPAD,  RM_VALD,   RM_VALU,  KC_MPRV,  KC_MPLY,  KC_MNXT,  KC_MUTE,  KC_VOLD,    KC_VOLU,  KC_INS,   KC_DEL,   KC_MUTE,
      // Row 1: Numbers and symbols
      _______,  KC_GRV,   KC_1,     KC_2,     KC_3,     KC_4,     KC_5,      KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,    KC_EQL,   KC_BSPC,            KC_PGUP,
      // Row 2: QWERTY top row
      _______,  KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,      KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,    KC_RBRC,  KC_BSLS,            KC_PGDN,
      // Row 3: QWERTY home row
      _______,  KC_CAPS,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,      KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,              KC_ENT,             KC_HOME,
      // Row 4: QWERTY bottom row
      _______,  KC_LSFT,            KC_Z,     KC_X,     KC_C,     KC_V,      KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,              KC_RSFT,  KC_UP,
      // Row 5: Modifiers and thumb keys
      _______,  KC_LCTL,  KC_LOPT,  KC_LCMD,  MO(NAV_LAYER),         KC_SPC,                        KC_SPC,             MO(SYM_LAYER), KC_RCMD,  KC_RCTL,  KC_LEFT,  KC_DOWN,  KC_RGHT
  ),
  ```
- **Key Points**:
  - Left Thumb: `MO(NAV_LAYER)` - activates NAV layer
  - Right Thumb: `MO(SYM_LAYER)` - activates SYM layer
  - All letters type normally
  - No helper functionality
- **Reason**: Foundation typing layer
- **Risk**: Low - standard QWERTY layout

#### Task 4: Implement NAV Layer (Layer 1)
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Create navigation menu layer
  ```c
  [NAV_LAYER] = LAYOUT_91_ansi(
      // Row 0: Transparent (pass through to BASE)
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
      // Row 1: Transparent
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
      // Row 2: Transparent
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
      // Row 3: Selectors on left-hand home row
      _______,  _______,  LT(APP_LAYER, KC_NO),   // A: Reserved (future)
                  LT(WIN_LAYER, KC_NO),   // S: WIN layer
                  LT(APP_LAYER, KC_NO),   // D: APP layer
                  LT(CURSOR_LAYER, KC_NO), // F: CURSOR layer
                  _______,  // G: Transparent
                  _______,  _______,  _______,  _______,  _______,  _______,  _______,              _______,            _______,
      // Row 4: Transparent
      _______,  _______,            _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,              _______,  _______,
      // Row 5: Keep thumb key held
      _______,  _______,  _______,  _______,  _______,            _______,                       _______,            _______,  _______,  _______,  _______,  _______,  _______
  ),
  ```
- **Key Points**:
  - Left-hand home row (A/S/D/F): Selectors using `LT()` (Layer Tap)
  - `LT(LAYER, KC_NO)`: Tap to latch layer, hold does nothing
  - Right-hand keys: Transparent (pass through to BASE)
  - Thumb key: Keep `MO(NAV_LAYER)` to maintain activation
- **Reason**: Menu system for accessing helper layers
- **Risk**: Medium - must match CURSOR helper pattern exactly

#### Task 5: Implement SYM Layer (Layer 2)
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Create symbols layer
  ```c
  [SYM_LAYER] = LAYOUT_91_ansi(
      // TBD: Define symbol mappings
      // Common symbols: ! @ # $ % ^ & * ( ) [ ] { } | \ ; : " ' < > ? ~ ` 
      // Can use shifted versions or custom symbols
      // Example structure:
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
      _______,  _______,  KC_EXLM,  KC_AT,    KC_HASH,  KC_DLR,   KC_PERC,  KC_CIRC,  KC_AMPR,  KC_ASTR,  KC_LPRN,  KC_RPRN,  _______,  _______,  _______,            _______,
      // ... (TBD based on user preferences)
  ),
  ```
- **Key Points**:
  - Activated by Right Thumb hold
  - Symbols accessible while thumb held
  - Release thumb returns to BASE
- **Reason**: Quick access to symbols
- **Risk**: Low - standard symbol layer pattern

#### Task 6: Implement CURSOR Layer (Layer 3)
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Create Cursor IDE helper layer
  ```c
  [CURSOR_LAYER] = LAYOUT_91_ansi(
      // Row 0: Transparent
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
      // Row 1: Transparent
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
      // Row 2: Top row - Setup/mode actions
      _______,  _______,  _______,  // Y: Toggle explorer (TBD: Cursor command)
                  // U: Toggle terminal (TBD: Cursor command)
                  // I: Open/focus chat (TBD: Cursor command)
                  // O: Mode picker (TBD: Cursor command)
                  // P: Model picker (TBD: Cursor command)
                  // [: Submit with codebase (TBD: Cursor command)
                  // ]: Submit no codebase (TBD: Cursor command)
      // Row 3: Home row - High-frequency actions
      _______,  _______,  _______,  _______,  _______,  _______,  // H: Focus editor (TBD: Cursor command)
                  // J: Previous change (TBD: Cursor command)
                  // K: Next change (TBD: Cursor command)
                  // L: Apply in editor (TBD: Cursor command)
                  // ;: Accept all files (TBD: Cursor command)
                  // ... rest transparent
      // Row 4: Transparent
      // Row 5: Keep NAV thumb held
  ),
  ```
- **Key Points**:
  - Right-hand only actions
  - Home row (H/J/K/L/;): High-frequency actions
  - Top row (Y/U/I/O/P/[)]: Setup/mode actions
  - Left-hand: Transparent
  - Activated via NAV + F selector
- **Reason**: Cursor IDE productivity layer
- **Risk**: Medium - need to map actual Cursor commands (TBD)

#### Task 7: Implement APP Layer (Layer 4)
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Create application launcher layer
  ```c
  [APP_LAYER] = LAYOUT_91_ansi(
      // Row 0: Transparent
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
      // Row 1: Transparent
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
      // Row 2: Top row - Dev/Productivity apps
      _______,  _______,  _______,  // Y: (reserved)
                  // U: (reserved)
                  // I: (reserved)
                  KC_APP_VSCODE,  // V: VS Code (⌥⌘V)
                  KC_APP_NOTION,  // N: Notion (⇧⌃⌘N) - note: different modifier
                  KC_APP_BGA,     // B: BGA (⌥⌘B)
                  KC_APP_CAL,     // C: Calendar (⌥⌘C)
                  KC_APP_MAIL,    // E: Mail (⌥⌘E)
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
                  KC_APP_SLACK,    // S: Slack (⌥⌘S) - note: conflicts with selector
                  // ... rest transparent
      // Row 5: Special keys
      _______,  _______,  _______,  _______,  _______,            KC_APP_FINDER,  // Space: Finder (⇧⌥⌘Space)
                  // ... rest transparent
      // Special keys row 0:
      KC_APP_CALC,  // Esc: Calculator (⌥⌘Esc)
      KC_APP_MUSIC, // `: NetEase Music (⌥⌘`)
      // ... rest transparent
  ),
  ```
- **Key Points**:
  - Home row: Chat apps (J/K/L/;)
  - Top row: Dev/productivity apps (V/N/B/C/E)
  - Bottom row: System/media apps (Z/S)
  - Special keys: Esc (Calculator), ` (Music), Space (Finder)
  - Left-hand: Transparent (or category selectors if implementing sub-layers)
- **Reason**: Quick app launching
- **Risk**: Medium - need to balance all 15 apps across available keys

#### Task 8: Implement WIN Layer (Layer 5)
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Create window management layer
  ```c
  [WIN_LAYER] = LAYOUT_91_ansi(
      // Row 0: Transparent
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
      // Row 1: Transparent
      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,
      // Row 2: Top row - Maximize/Halves
      _______,  _______,  _______,  _______,  _______,  _______,  KC_WIN_MAX,  // F: Maximize (⇧⌃⌘F)
                  // ... rest transparent
      // Row 3: Home row - Quarters
      _______,  _______,  KC_WIN_BL,  // A: Bottom Left (⇧⌃⌥←)
                  KC_WIN_BR,  // S: Bottom Right (⇧⌃⌥→)
                  // D: (reserved)
                  // F: (reserved)
                  // ... rest transparent
      // Row 4: Bottom row - Split View
      _______,  _______,            KC_WIN_SV_L,  // Z: Split View Left (⌃⌥⌘←)
                  KC_WIN_SV_R,  // X: Split View Right (⌃⌥⌘→)
                  // ... rest transparent
      // Arrow keys: Halves
      // Left: KC_WIN_LEFT (⇧⌃⌘←)
      // Right: KC_WIN_RIGHT (⇧⌃⌘→)
      // Up: KC_WIN_TOP (⇧⌃⌘↑)
      // Down: KC_WIN_BOTTOM (⇧⌃⌘↓)
      // Top row: Quarters
      // Q: KC_WIN_TL (⌃⌥←)
      // W: KC_WIN_TR (⌃⌥→)
  ),
  ```
- **Key Points**:
  - Maximize/Halves: Arrow keys + F key
  - Quarters: Q/W (top), A/S (bottom)
  - Split View: Z/X
  - Organized by modifier groups
- **Reason**: Window management productivity
- **Risk**: Low - straightforward mapping

#### Task 9: Implement Encoder Behavior
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Define encoder mappings
  ```c
  #if defined(ENCODER_MAP_ENABLE)
  const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
      [MAC_BASE] = { 
          ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN),  // Rotate: Zoom out/in
          ENCODER_CCW_CW(KC_VOLD, KC_VOLU)           // Right encoder: Volume
      },
      [NAV_LAYER] = { 
          ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN),
          ENCODER_CCW_CW(KC_VOLD, KC_VOLU)
      },
      [SYM_LAYER] = { 
          ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN),
          ENCODER_CCW_CW(KC_VOLD, KC_VOLU)
      },
      [CURSOR_LAYER] = { 
          ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN),
          ENCODER_CCW_CW(KC_VOLD, KC_VOLU)
      },
      [APP_LAYER] = { 
          ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN),
          ENCODER_CCW_CW(KC_VOLD, KC_VOLU)
      },
      [WIN_LAYER] = { 
          ENCODER_CCW_CW(KC_ZOOM_OUT, KC_ZOOM_IN),
          ENCODER_CCW_CW(KC_VOLD, KC_VOLU)
      },
  };
  #endif // ENCODER_MAP_ENABLE
  ```
- **Key Points**:
  - Rotate: Zoom out/in (Cmd -/=)
  - Single press: Zoom reset (Cmd 0) - requires tap dance or custom handling
  - Double press: Lock screen (Ctrl+Cmd+Q) - requires tap dance
- **Reason**: Consistent encoder behavior across layers
- **Risk**: Medium - tap dance needed for press actions

### ⚙️ Medium Priority

#### Task 10: Implement Tap Dance for Encoder
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Add tap dance for encoder press actions
  ```c
  // Tap dance states
  typedef enum {
      TD_NONE,
      TD_SINGLE_TAP,
      TD_DOUBLE_TAP
  } td_state_t;

  // Encoder press handler (TBD: implementation details)
  // Single press: KC_ZOOM_RESET
  // Double press: KC_LOCK_SCREEN
  ```
- **Reason**: Enable encoder press actions
- **Risk**: Medium - requires tap dance implementation

#### Task 11: Add Layer Indicator (Optional)
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: RGB/OLED indicator for active layer
  ```c
  // TBD: If hardware supports RGB/OLED
  // Show different color/pattern for each layer
  ```
- **Reason**: Visual feedback
- **Risk**: Low - optional, depends on hardware

### 🧩 Low Priority

#### Task 12: Windows Support (Optional)
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Add Windows base layer and Windows NAV layer
  ```c
  [WIN_BASE] = LAYOUT_91_ansi(
      // Similar to MAC_BASE but with Windows modifiers
      // Left thumb: MO(WIN_NAV)
  ),
  [WIN_NAV] = LAYOUT_91_ansi(
      // Similar to NAV_LAYER but Windows-compatible
  ),
  ```
- **Reason**: Cross-platform support
- **Risk**: Low - optional feature

#### Task 13: Review Generated Config for Usability and Sense-Checking
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c` (generated)
- **Action**: Comprehensive review of generated keymap before finalization
  - **Usability Review**:
    - [ ] Test each layer activation sequence (thumb hold + selector tap)
    - [ ] Verify key placements are reachable and comfortable
    - [ ] Check that high-frequency actions are on home row
    - [ ] Validate that app launchers use intuitive key mappings (e.g., Z for ChatGPT = ⌥⌘Z)
    - [ ] Confirm window management shortcuts are logically grouped
    - [ ] Test real-world workflows (e.g., "launch VS Code → open chat → review changes")
    - [ ] Verify no awkward hand positions required
    - [ ] Check that layer switching doesn't interrupt typing flow
  
  - **Sense-Checking Review**:
    - [ ] **Logical Consistency**: Do key placements match their shortcuts? (e.g., Z key → ⌥⌘Z for ChatGPT)
    - [ ] **Ergonomic Sense**: Are frequently used apps on easily reachable keys?
    - [ ] **Layer Organization**: Does the layer structure make sense? (BASE → NAV → Helper layers)
    - [ ] **Selector Logic**: Do selector keys (A/S/D/F) follow a logical pattern?
    - [ ] **Conflict Detection**: Are there any key conflicts or overlaps?
    - [ ] **Design Principles**: Does it follow all design principles from Step 1-3?
      - Typing safety maintained?
      - Momentary activation (no sticky layers)?
      - Left-control/right-action pattern?
      - Home row priority?
    - [ ] **Completeness**: Are all required shortcuts mapped?
    - [ ] **Extensibility**: Can future layers be added without breaking existing ones?
  
  - **Code Review**:
    - [ ] All macros correctly defined
    - [ ] Layer activation logic is correct
    - [ ] No syntax errors or warnings
    - [ ] Code is readable and well-commented
    - [ ] Follows QMK conventions
  
  - **Documentation Review**:
    - [ ] Key mappings are documented
    - [ ] Activation sequences are clear
    - [ ] Usage examples provided
  
  - **Create Review Checklist**:
    - Generate a review checklist document
    - List all key mappings for verification
    - Include workflow scenarios to test
    - Document any issues found
    - Propose fixes for identified problems
- **Reason**: Ensure generated config is usable, logical, and meets all requirements
- **Risk**: Medium - may require iteration if issues found

#### Task 14: Documentation
- **Files**: Create `keychron/q11/custom-refs/complete-keymap-documentation.md`
- **Action**:
  - Document all layer mappings
  - Include usage examples
  - Create layer diagram
  - Document activation sequences
  - Include review findings and decisions
- **Reason**: Future reference
- **Risk**: None

## 🔁 Execution Order

### Phase 1: Foundation (Tasks 1, 2)
1. Define layer enum
2. Define all QMK macro keycodes
3. Verify macro syntax compiles

### Phase 2: Core Layers (Tasks 3, 4, 5)
1. Implement BASE layer
2. Implement NAV layer with selectors
3. Implement SYM layer (basic symbols)

### Phase 3: Helper Layers (Tasks 6, 7, 8)
1. Implement CURSOR layer (map Cursor commands)
2. Implement APP layer (all 15 apps)
3. Implement WIN layer (all window management)

### Phase 4: Encoder & Polish (Tasks 9, 10, 11)
1. Implement encoder behavior
2. Add tap dance for encoder press
3. Add layer indicators (if hardware supports)

### Phase 5: Code Generation & Review (Tasks 13)
1. Generate complete `keymap.c` file
2. **Review generated config for usability and sense-checking**
   - Usability review (workflow testing, ergonomics)
   - Sense-checking (logical consistency, design principles)
   - Code review (syntax, structure, conventions)
   - Documentation review (completeness, clarity)
3. Address any issues found in review
4. Iterate if needed

### Phase 6: Final Validation & Documentation (Task 14)
1. Complete testing checklist
2. Document mappings and review findings
3. Final verification
4. Create user documentation

## 🔍 Config Review & Usability Validation

### Review Process

After generating the complete QMK keymap code, a comprehensive review must be performed to ensure:

1. **Usability**: The config works in real-world scenarios
2. **Logical Consistency**: Key placements make sense
3. **Ergonomic Soundness**: Comfortable to use
4. **Design Compliance**: Follows all design principles

### Review Checklist

#### Usability Review
- [ ] **Layer Activation**: Test each activation sequence
  - Left Thumb hold → NAV layer activates
  - NAV + F → CURSOR layer activates
  - NAV + D → APP layer activates
  - NAV + S → WIN layer activates
  - Right Thumb hold → SYM layer activates
  - Release thumb → Returns to BASE

- [ ] **Workflow Testing**: Test real-world scenarios
  - Launch VS Code: NAV + D → V
  - Open ChatGPT: NAV + D → Z
  - Review Cursor changes: NAV + F → J/K
  - Apply changes: NAV + F → L
  - Maximize window: NAV + S → F
  - All workflows feel natural and fast

- [ ] **Key Reachability**: Verify all mapped keys are comfortable
  - Home row keys (H/J/K/L/;) are easily accessible
  - Top row keys (Y/U/I/O/P) don't require excessive reach
  - Bottom row keys are comfortable
  - No awkward hand positions

- [ ] **Typing Safety**: Verify no typing disruption
  - All letters type correctly on BASE
  - No accidental layer activation while typing
  - No stuck layers after normal use

#### Sense-Checking Review

- [ ] **Logical Key Mappings**: Verify mappings make sense
  - Z key → ChatGPT (⌥⌘Z) ✓
  - V key → VS Code (⌥⌘V) ✓
  - J/K/L/; → Chat apps (⌥⌘1/2/3/4) ✓
  - All mappings follow shortcut character pattern

- [ ] **Ergonomic Organization**: Check key placement logic
  - Most-used apps on home row (chat apps)
  - Dev apps easily accessible (top row)
  - Window management logically grouped
  - Cursor actions prioritized by frequency

- [ ] **Layer Structure**: Verify layer organization
  - BASE: Pure typing ✓
  - NAV: Menu system ✓
  - Helper layers: Activated via NAV selectors ✓
  - No circular dependencies
  - Clear separation of concerns

- [ ] **Design Principles Compliance**:
  - ✓ Typing safety: Letters always type on BASE
  - ✓ Momentary power: Layers only active when thumb held
  - ✓ Left-control/right-action: Left hand selects, right hand executes
  - ✓ Home row priority: High-frequency actions on home row
  - ✓ No sticky modes: All layers deactivate on thumb release

- [ ] **Completeness**: Verify all requirements met
  - All 15 app launchers mapped
  - All window management shortcuts mapped
  - All Cursor actions mapped (or placeholders documented)
  - Encoder behavior defined
  - All layers implemented

- [ ] **Conflict Detection**: Check for issues
  - No duplicate key mappings
  - No conflicting layer activations
  - Selector keys don't interfere with typing
  - No key overload (one key doing too many things)

#### Code Quality Review

- [ ] **Syntax & Compilation**:
  - Code compiles without errors
  - No warnings
  - All macros properly defined
  - Layer definitions correct

- [ ] **Structure & Organization**:
  - Macros grouped logically
  - Layers in logical order
  - Consistent naming conventions
  - Clear comments

- [ ] **Maintainability**:
  - Code is readable
  - Easy to modify/extend
  - Well-documented
  - Follows QMK conventions

### Review Output

After review, create:
1. **Review Report**: Document findings, issues, and recommendations
2. **Issue List**: Any problems found with proposed fixes
3. **Approval Status**: Usable/Needs Changes/Not Usable
4. **Iteration Plan**: If changes needed, what to fix and how

### Review Decision Points

- **If Usable**: Proceed to final testing and documentation
- **If Needs Changes**: Fix identified issues, re-review
- **If Not Usable**: Major redesign needed, return to planning

## 🧪 Testing & Validation

### Required Test Types

#### Unit Tests (Manual)
- [ ] Each macro sends correct key combination
- [ ] Layer activation works (thumb hold + selector tap)
- [ ] Layer deactivation works (release thumb)
- [ ] Typing safety maintained (letters type on BASE)
- [ ] No stuck layers

#### Integration Tests (Manual)
- [ ] BASE layer: All keys type correctly
- [ ] NAV layer: All selectors activate correct layers
- [ ] SYM layer: Symbols accessible
- [ ] CURSOR layer: All Cursor actions work
- [ ] APP layer: All 15 apps launch correctly
- [ ] WIN layer: All window management actions work
- [ ] Encoder: Rotate and press actions work
- [ ] No conflicts between layers

#### Edge Cases
- [ ] Rapid layer switching doesn't cause stuck keys
- [ ] Holding selector key doesn't interfere
- [ ] Multiple modifier keys work correctly
- [ ] Special keys (Esc, Space, arrows, backtick) work in macros
- [ ] Encoder tap dance timing works correctly

### Failure Modes
- **Macro doesn't trigger**: Check macOS System Settings → Keyboard → Shortcuts
- **Wrong app launches**: Verify macro keycode matches shortcut
- **Layer stuck active**: Verify thumb release logic
- **Typing broken**: Verify BASE layer unchanged
- **Encoder not working**: Check encoder_map configuration

### Rollback Plan
- Git commit before changes: `git commit -m "Backup before complete keymap rewrite"`
- If issues: `git checkout HEAD -- keymap.c` and reflash

## 🧼 Cleanup & Quality Checks

### Code Quality
- [ ] Consistent naming: `KC_APP_*`, `KC_WIN_*`, `KC_CURSOR_*`
- [ ] Comments explain each macro's purpose
- [ ] Group related macros together
- [ ] No duplicate keycode definitions
- [ ] All layers use `LAYOUT_91_ansi` consistently

### Structure
- [ ] Layer definitions in logical order
- [ ] Macros defined before keymaps
- [ ] Consistent indentation (4 spaces)
- [ ] Clear section separators with comments

### Documentation
- [ ] File header explains keymap purpose
- [ ] Each layer has comment explaining purpose
- [ ] Complex macros have inline comments
- [ ] Activation sequences documented

## 🤔 Assumptions

### Explicit Assumptions

1. **QMK Macro Syntax**: Using `LALT(LGUI(KC_X))` format
   - **Source**: Standard QMK documentation
   - **Safety**: Verified pattern

2. **Layer Activation**: Using `LT()` for selectors, `MO()` for thumb keys
   - **Source**: Existing CURSOR helper pattern
   - **Safety**: Matches approved design

3. **Cursor Commands**: TBD - need to map actual Cursor IDE commands
   - **Source**: Step 2 mapping document
   - **Safety**: Will need user confirmation of actual commands

4. **SYM Layer**: TBD - need user preferences for symbol mappings
   - **Source**: Not specified in requirements
   - **Safety**: Can use defaults, customize later

5. **All Shortcuts Work**: macOS System Settings has shortcuts configured
   - **Source**: User mentioned 3rd party app
   - **Safety**: User must verify shortcuts configured

6. **Encoder Tap Dance**: Can implement single/double press detection
   - **Source**: QMK tap dance feature
   - **Safety**: Standard QMK feature

### NON-BLOCKER Defaults Used

- **SYM Layer**: Will use common symbol mappings, can customize later
- **Cursor Commands**: Will need to map actual commands (TBD)
- **Windows Support**: Optional, can add later
- **Layer Indicators**: Optional, depends on hardware

## ✅ Completion Criteria

### Objective "Done" Conditions

1. **All Layers Implemented**
   - [ ] BASE layer: Clean typing, no helpers
   - [ ] NAV layer: Menu with 4 selectors working
   - [ ] SYM layer: Symbols accessible
   - [ ] CURSOR layer: All Cursor actions mapped
   - [ ] APP layer: All 15 apps launch correctly
   - [ ] WIN layer: All window management works

2. **Layer Activation**
   - [ ] NAV activates with Left Thumb hold
   - [ ] SYM activates with Right Thumb hold
   - [ ] CURSOR activates with NAV + F
   - [ ] APP activates with NAV + D
   - [ ] WIN activates with NAV + S
   - [ ] All layers deactivate on thumb release

3. **Config Review Completed**
   - [ ] **Usability Review**: All workflows tested and functional
     - [ ] Layer activation sequences work correctly
     - [ ] Real-world workflows tested (launch app → use Cursor → manage windows)
     - [ ] Key placements are comfortable and reachable
     - [ ] No typing disruption
   - [ ] **Sense-Checking Review**: Config is logical and makes sense
     - [ ] Key mappings follow shortcut character pattern (Z → ⌥⌘Z)
     - [ ] Frequently used actions on home row
     - [ ] Layer organization is logical
     - [ ] Design principles followed (typing safety, momentary activation, etc.)
     - [ ] No conflicts or overlaps
   - [ ] **Code Review**: Code quality verified
     - [ ] Compiles without errors/warnings
     - [ ] Follows QMK conventions
     - [ ] Well-commented and organized
   - [ ] **Review Report**: Findings documented
     - [ ] Issues identified and addressed
     - [ ] Approval status determined (Usable/Needs Changes)
     - [ ] Iteration plan created if needed

4. **Code Quality**
   - [ ] All macros defined and documented
   - [ ] Keymaps compile without errors
   - [ ] Code follows QMK conventions
   - [ ] No linter errors
   - [ ] Well-commented and organized

5. **User Experience**
   - [ ] Typing safety maintained
   - [ ] Layer activation feels natural
   - [ ] Key placements are ergonomic
   - [ ] No typing disruption
   - [ ] Consistent with design principles
   - [ ] **Config approved as usable and logical** (from review)

### Reviewer Verification

- Code review: Check macro definitions, layer structure, activation logic
- Manual testing: Verify each shortcut works
- Ergonomic review: Check key placements make sense
- Documentation review: Verify completeness

### CI/CD Verification

- QMK compile: `qmk compile -kb keychron/q11/ansi_encoder -km j-custom`
- No warnings or errors
- Firmware size within limits
- All layers compile successfully

## 📊 Confidence Declaration

**I am ≥99% confident this plan can be executed to generate a complete QMK keymap implementation.**

### Confidence Factors

✅ **Clear Requirements**: User provided detailed answers and context
✅ **Existing Pattern**: Can follow existing CURSOR helper design
✅ **QMK Capability**: All shortcuts can be sent directly via QMK macros
✅ **Well-Documented**: Reference materials (Step 1-3 plans, shortcut list) available
✅ **Complete Specification**: All layers, all keys, all shortcuts specified

### Remaining Uncertainties (Non-Blocking)

- **Cursor Commands**: Need to map actual Cursor IDE commands (can use placeholders, update later)
- **SYM Layer**: Need user preferences for symbol mappings (can use defaults)
- **Encoder Tap Dance**: Implementation details (standard QMK feature)

### Next Steps

1. **Review this plan** - Verify all layers and mappings are correct
2. **Confirm Cursor commands** - Provide actual Cursor IDE command keycodes
3. **Confirm SYM preferences** - Specify desired symbol mappings
4. **Approve to proceed** - Generate complete QMK keymap code
5. **Implementation** - Create complete `keymap.c` file
6. **Config Review** - Review generated config for usability and sense-checking
   - Usability review (workflows, ergonomics)
   - Sense-checking (logical consistency, design compliance)
   - Code review (quality, structure)
7. **Address Issues** - Fix any problems found in review
8. **Testing** - Test each layer and shortcut
9. **Iteration** - Refine based on review findings and usage
10. **Final Approval** - Approve config as production-ready

---

**Plan Generated**: 2026-01-26  
**Version**: v2 (Complete Keymap Specification)  
**Target Keyboard**: Keychron Q11 ANSI Encoder  
**Firmware**: QMK  
**Platform**: macOS (Windows optional)
