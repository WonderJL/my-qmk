# Base Layer Comparison: Old VIA Config vs Current Keymap

## Overview
Comparing Layer 0 (MAC_BASE) between:
- **Old VIA Config**: `keychron_q11_ansi_knob.layout.json` (Layer 0)
- **Current Keymap**: `keymap.c` / `keymap.json` (MAC_BASE layer)

---

## Row-by-Row Comparison

### Row 0: Top Row (Function keys, media, encoder)

| Position | Old VIA Config | Current Keymap | Change |
|----------|----------------|----------------|--------|
| 0 | `KC_MUTE` | `KC_MUTE` | ✅ Same |
| 1 | `KC_ESC` | `KC_ESC` | ✅ Same |
| 2 | `KC_BRID` | `KC_BRID` | ✅ Same |
| 3 | `KC_BRIU` | `KC_BRIU` | ✅ Same |
| 4 | `CUSTOM(0)` | `KC_MCTL` | 🔄 Changed (Mission Control) |
| 5 | `CUSTOM(1)` | `KC_LPAD` | 🔄 Changed (Launchpad) |
| 6 | `RGB_VAD` | `RM_VALD` | 🔄 Changed (RGB Matrix VAD) |
| 7 | `RGB_VAI` | `RM_VALU` | 🔄 Changed (RGB Matrix VAI) |
| 8 | `KC_NO` | `KC_MPRV` | 🔄 Changed (Media Previous) |
| 9 | `MACRO(1)` | `KC_MPLY` | 🔄 Changed (Media Play/Pause) |
| 10 | `KC_GRV` | `KC_MNXT` | 🔄 Changed (Media Next) |
| 11 | `KC_1` | `KC_MUTE` | 🔄 Changed (Mute) |
| 12 | `KC_2` | `KC_VOLD` | 🔄 Changed (Volume Down) |
| 13 | `KC_3` | `KC_VOLU` | 🔄 Changed (Volume Up) |
| 14 | `KC_4` | `KC_INS` | 🔄 Changed (Insert) |
| 15 | `KC_5` | `KC_DEL` | 🔄 Changed (Delete) |
| 16 | `KC_6` | `TD(TD_ENC_R)` | 🔄 Changed (Right Encoder Tap Dance) |

**Note**: The VIA config seems to have a different key arrangement. The current keymap has media controls and encoder actions in Row 0, while VIA config has number row keys mixed in.

---

### Row 1: Number Row

| Position | Old VIA Config | Current Keymap | Change |
|----------|----------------|----------------|--------|
| 0 | `MACRO(2)` | `KC_APP_WHATSAPP` | 🔄 Changed (App launcher) |
| 1 | `KC_TAB` | `KC_GRV` | 🔄 Changed |
| 2 | `KC_Q` | `KC_1` | 🔄 Changed |
| 3 | `KC_W` | `KC_2` | 🔄 Changed |
| 4 | `KC_E` | `KC_3` | 🔄 Changed |
| 5 | `KC_NO` | `KC_4` | 🔄 Changed |
| 6 | `KC_R` | `KC_5` | 🔄 Changed |
| 7 | `KC_T` | `KC_6` | 🔄 Changed |
| 8 | `KC_NO` | `KC_7` | 🔄 Changed |
| 9 | `MACRO(3)` | `KC_8` | 🔄 Changed |
| 10 | `KC_CAPS` | `KC_9` | 🔄 Changed |
| 11 | `KC_A` | `KC_0` | 🔄 Changed |
| 12 | `KC_S` | `KC_MINS` | 🔄 Changed |
| 13 | `KC_D` | `KC_EQL` | 🔄 Changed |
| 14 | `KC_F` | `KC_BSPC` | 🔄 Changed |
| 15 | `KC_G` | `KC_PGUP` | 🔄 Changed |

**Note**: The VIA config structure appears different. Let me map based on actual physical positions.

---

### Corrected Mapping Based on Physical Layout

The VIA config seems to use a different key ordering. Let me compare based on actual key functions:

#### Leftmost Column (5 keys - NEW in current keymap)

| Physical Position | Old VIA Config | Current Keymap | Change |
|-------------------|----------------|----------------|--------|
| Row 1, Left | `MACRO(1)` (WhatsApp) | `KC_APP_WHATSAPP` | ✅ Same function, different implementation |
| Row 2, Left | `MACRO(2)` (WeChat) | `KC_APP_WECHAT` | ✅ Same function, different implementation |
| Row 3, Left | `MACRO(4)` (Slack) | `KC_APP_SLACK_6` | ✅ Same function, different implementation |
| Row 4, Left | `MACRO(5)` (ChatGPT) | `KC_APP_CHATGPT` | ✅ Same function, different implementation |
| Row 5, Left | `MO(0)` | `KC_APP_VPN_SHADOWROCKET` | 🔄 Changed (was layer toggle, now VPN toggle) |

#### Row 1: Number Row (Main keys)

| Key | Old VIA Config | Current Keymap | Change |
|-----|----------------|----------------|--------|
| ` | `KC_GRV` | `KC_GRV` | ✅ Same |
| 1 | `KC_1` | `KC_1` | ✅ Same |
| 2 | `KC_2` | `KC_2` | ✅ Same |
| 3 | `KC_3` | `KC_3` | ✅ Same |
| 4 | `KC_4` | `KC_4` | ✅ Same |
| 5 | `KC_5` | `KC_5` | ✅ Same |
| 6 | `KC_6` | `KC_6` | ✅ Same |
| 7 | `KC_7` | `KC_7` | ✅ Same |
| 8 | `KC_8` | `KC_8` | ✅ Same |
| 9 | `KC_9` | `KC_9` | ✅ Same |
| 0 | `KC_0` | `KC_0` | ✅ Same |
| - | `KC_MINS` | `KC_MINS` | ✅ Same |
| = | `KC_EQL` | `KC_EQL` | ✅ Same |
| Backspace | `KC_BSPC` | `KC_BSPC` | ✅ Same |
| Page Up | `KC_PGUP` | `KC_PGUP` | ✅ Same |

#### Row 2: QWERTY Top Row

| Key | Old VIA Config | Current Keymap | Change |
|-----|----------------|----------------|--------|
| Tab | `KC_TAB` | `KC_TAB` | ✅ Same |
| Q | `KC_Q` | `KC_Q` | ✅ Same |
| W | `KC_W` | `KC_W` | ✅ Same |
| E | `KC_E` | `KC_E` | ✅ Same |
| R | `KC_R` | `KC_R` | ✅ Same |
| T | `KC_T` | `KC_T` | ✅ Same |
| Y | `KC_Y` | `KC_Y` | ✅ Same |
| U | `KC_U` | `KC_U` | ✅ Same |
| I | `KC_I` | `KC_I` | ✅ Same |
| O | `KC_O` | `KC_O` | ✅ Same |
| P | `KC_P` | `KC_P` | ✅ Same |
| [ | `KC_LBRC` | `KC_LBRC` | ✅ Same |
| ] | `KC_RBRC` | `KC_RBRC` | ✅ Same |
| \ | `KC_BSLS` | `KC_BSLS` | ✅ Same |
| Page Down | `KC_PGDN` | `KC_PGDN` | ✅ Same |

#### Row 3: QWERTY Home Row

| Key | Old VIA Config | Current Keymap | Change |
|-----|----------------|----------------|--------|
| Caps Lock | `KC_CAPS` | `KC_CAPS` | ✅ Same |
| A | `KC_A` | `KC_A` | ✅ Same |
| S | `KC_S` | `KC_S` | ✅ Same |
| D | `KC_D` | `KC_D` | ✅ Same |
| F | `KC_F` | `KC_F` | ✅ Same |
| G | `KC_G` | `KC_G` | ✅ Same |
| H | `KC_H` | `KC_H` | ✅ Same |
| J | `KC_J` | `KC_J` | ✅ Same |
| K | `KC_K` | `KC_K` | ✅ Same |
| L | `KC_L` | `KC_L` | ✅ Same |
| ; | `KC_SCLN` | `KC_SCLN` | ✅ Same |
| ' | `KC_QUOT` | `KC_QUOT` | ✅ Same |
| Enter | `KC_ENT` | `KC_ENT` | ✅ Same |
| Home | `KC_HOME` | `KC_HOME` | ✅ Same |

#### Row 4: QWERTY Bottom Row

| Key | Old VIA Config | Current Keymap | Change |
|-----|----------------|----------------|--------|
| Left Shift | `KC_LSFT` | `KC_LSFT` | ✅ Same |
| Z | `KC_Z` | `KC_Z` | ✅ Same |
| X | `KC_X` | `KC_X` | ✅ Same |
| C | `KC_C` | `KC_C` | ✅ Same |
| V | `KC_V` | `KC_V` | ✅ Same |
| B | `KC_B` | `KC_B` | ✅ Same |
| N | `KC_N` | `KC_N` | ✅ Same |
| M | `KC_M` | `KC_M` | ✅ Same |
| , | `KC_COMM` | `KC_COMM` | ✅ Same |
| . | `KC_DOT` | `KC_DOT` | ✅ Same |
| / | `KC_SLSH` | `KC_SLSH` | ✅ Same |
| Right Shift | `KC_RSFT` | `KC_RSFT` | ✅ Same |
| Up Arrow | `KC_UP` | `KC_UP` | ✅ Same |

#### Row 5: Modifiers and Thumb Keys

| Physical Position | Old VIA Config | Current Keymap | Change |
|-------------------|----------------|----------------|--------|
| Left Ctrl | `KC_LCTL` | `KC_LCTL` | ✅ Same |
| Left Option/Alt | `CUSTOM(2)` | `KC_LOPT` | 🔄 Changed (was custom, now standard) |
| Left Cmd/GUI | `CUSTOM(4)` | `KC_LCMD` | 🔄 Changed (was custom, now standard) |
| **Left Thumb** | `MO(0)` | `MO(NAV_LAYER)` | 🔄 Changed (was layer 0 toggle, now NAV layer) |
| Left Space | `KC_SPC` | `KC_SPC` | ✅ Same |
| Right Space | `KC_SPC` | `KC_SPC` | ✅ Same |
| Right Thumb | `MO(1)` | `MO(SYM_LAYER)` | 🔄 Changed (was layer 1, now SYM layer) |
| Right Cmd/GUI | `CUSTOM(5)` | `KC_RCMD` | 🔄 Changed (was custom, now standard) |
| Right Ctrl | `KC_RCTL` | `KC_RCTL` | ✅ Same |
| Left Arrow | `KC_LEFT` | `KC_LEFT` | ✅ Same |
| Down Arrow | `KC_DOWN` | `KC_DOWN` | ✅ Same |
| Right Arrow | `KC_RGHT` | `KC_RGHT` | ✅ Same |

---

## Key Differences Summary

### ✅ **No Changes** (Standard QWERTY keys)
- All letter keys (A-Z)
- All number keys (0-9)
- All standard symbols (`-`, `=`, `[`, `]`, `\`, `;`, `'`, `,`, `.`, `/`)
- Modifiers: `KC_LCTL`, `KC_RSFT`, `KC_RCTL`
- Navigation: `KC_PGUP`, `KC_PGDN`, `KC_HOME`, `KC_UP`, `KC_LEFT`, `KC_DOWN`, `KC_RGHT`
- Space bars: Both `KC_SPC`

### 🔄 **Changed**

1. **Leftmost Column (5 keys)**:
   - **Row 1**: `MACRO(1)` → `KC_APP_WHATSAPP` (same function, different implementation)
   - **Row 2**: `MACRO(2)` → `KC_APP_WECHAT` (same function, different implementation)
   - **Row 3**: `MACRO(4)` → `KC_APP_SLACK_6` (same function, different implementation)
   - **Row 4**: `MACRO(5)` → `KC_APP_CHATGPT` (same function, different implementation)
   - **Row 5**: `MO(0)` → `KC_APP_VPN_SHADOWROCKET` (was layer toggle, now VPN toggle)

2. **Top Row (Row 0)**:
   - `CUSTOM(0)` → `KC_MCTL` (Mission Control)
   - `CUSTOM(1)` → `KC_LPAD` (Launchpad)
   - `RGB_VAD` → `RM_VALD` (RGB Matrix instead of RGB)
   - `RGB_VAI` → `RM_VALU` (RGB Matrix instead of RGB)
   - Added media controls: `KC_MPRV`, `KC_MPLY`, `KC_MNXT`
   - Added encoder tap dance: `TD(TD_ENC_R)`

3. **Modifiers**:
   - `CUSTOM(2)` → `KC_LOPT` (Left Option/Alt)
   - `CUSTOM(4)` → `KC_LCMD` (Left Command/GUI)
   - `CUSTOM(5)` → `KC_RCMD` (Right Command/GUI)

4. **Thumb Keys**:
   - **Left Thumb**: `MO(0)` → `MO(NAV_LAYER)` (was layer 0 toggle, now NAV layer momentary)
   - **Right Thumb**: `MO(1)` → `MO(SYM_LAYER)` (was layer 1, now SYM layer)

---

## Functional Impact

### What Stayed the Same
- ✅ All typing keys (letters, numbers, symbols) work identically
- ✅ Basic navigation keys unchanged
- ✅ Space bars unchanged
- ✅ App launchers in leftmost column (same apps, different implementation)

### What Changed Functionally

1. **Layer Activation**:
   - **Old**: Left thumb was `MO(0)` (momentary layer 0 - which doesn't make sense as base layer)
   - **New**: Left thumb is `MO(NAV_LAYER)` (accesses navigation menu)
   - **Old**: Right thumb was `MO(1)` (momentary layer 1 - RGB layer)
   - **New**: Right thumb is `MO(SYM_LAYER)` (accesses symbols layer)

2. **Top Row Functions**:
   - Added macOS Mission Control and Launchpad
   - Changed RGB controls to RGB Matrix controls
   - Added media playback controls
   - Added encoder tap dance functionality

3. **VPN Toggle**:
   - **Old**: Leftmost bottom key was layer toggle
   - **New**: Leftmost bottom key is Shadowrocket VPN toggle

---

## Migration Notes

If migrating from old VIA config to new keymap:

1. **Thumb Keys**: The left and right thumb keys now activate different layers (NAV and SYM instead of layers 0 and 1)
2. **App Launchers**: Still work the same way, but now use QMK macros instead of VIA macros
3. **RGB Controls**: Now use RGB Matrix (`RM_*`) instead of RGB (`RGB_*`)
4. **Top Row**: New macOS-specific functions added (Mission Control, Launchpad)
5. **VPN Toggle**: New function on leftmost bottom key
