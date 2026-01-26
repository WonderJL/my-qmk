# PLAN: Implement QMK Keymap for Keychron Q11

## 🧠 Problem Understanding

### Task Description
Implement the complete QMK keymap configuration for Keychron Q11 ANSI Encoder based on the finalized tech spec (`specs/qmk-config-tech-spec-keychron-q11.md`). The implementation involves completing partially-implemented layers, fixing macro implementations, and adding all helper layers with their respective macros.

### Scope
**In Scope:**
- Fix critical macro implementation issue (SEND_STRING macros incorrectly used in keymap)
- Complete NAV_LAYER with layer selectors (A/S/D/F keys)
- Complete APP_LAYER with 15 application launcher macros
- Complete WIN_LAYER with window management macros
- Complete CURSOR_LAYER structure (with TBD commands documented)
- Update encoder configuration for zoom functionality
- Add all missing macro definitions (app launchers, window management)
- Ensure keymap compiles without errors

**Out of Scope (Non-Goals):**
- Cursor IDE command mapping (documented as TBD in spec - requires research)
- Windows platform support layers (WIN_BASE, WIN_NAV) - optional in spec
- Encoder tap dance implementation (deferred enhancement)
- RGB/OLED layer indicators

**Configuration Requirements:**
- Bootmagic: Enabled in `info.json` (allows reset via key combination)
  - Configured in `info.json` with `"bootmagic": true` in features
  - Matrix position: [0, 1] for left side, [6, 7] for right side (split keyboard)
- VIA: Enabled in `rules.mk` (allows runtime keymap configuration via VIA app)
  - Added `VIA_ENABLE = yes` to `rules.mk`
  - Increased `DYNAMIC_KEYMAP_LAYER_COUNT` to 9 in `config.h` to support all layers
  - Increased EEPROM `backing_size` from 4096 to 8192 in `info.json` to accommodate VIA's dynamic keymap storage

### Constraints
- **Firmware**: QMK
- **Keyboard**: Keychron Q11 ANSI Encoder (`LAYOUT_91_ansi`)
- **Platform**: macOS primary
- **Code Location**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Build Command**: `qmk compile -kb keychron/q11/ansi_encoder -km j-custom`

---

## 🎯 Objectives

### Definition of Success
1. Keymap compiles without errors or warnings
2. All 6 primary layers are fully defined (MAC_BASE, NAV_LAYER, SYM_LAYER, CURSOR_LAYER, APP_LAYER, WIN_LAYER)
3. All 15 app launcher macros work correctly
4. All window management macros work correctly
5. Special symbol macros (backticks, parentheses, braces, brackets, tilde-slash) work correctly
6. Layer activation flow works as designed (NAV → latch to CURSOR/APP/WIN)
7. Encoder supports zoom in/out rotation

### Quality Expectations
- Code follows QMK best practices
- All macros properly defined using custom keycodes and `process_record_user()`
- Inline comments document key mappings
- No dead/unreachable code
- Consistent formatting with existing codebase

---

## 🧩 System / Codebase Context

### Relevant Files
| File | Purpose |
|------|---------|
| `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c` | Main keymap file (primary modification target) |
| `keychron/q11/ansi_encoder/keymaps/j-custom/rules.mk` | Build rules (may need SEND_STRING features) |
| `specs/qmk-config-tech-spec-keychron-q11.md` | Source of truth for layer definitions |

### Current Implementation State
| Layer | Status | Notes |
|-------|--------|-------|
| MAC_BASE | ✅ Complete | Has MO(NAV_LAYER) and MO(SYM_LAYER) thumb keys |
| NAV_LAYER | ❌ TBD | Placeholder only - needs selectors on A/S/D/F |
| SYM_LAYER | ⚠️ Partial | Has layout but macros are broken (SEND_STRING used directly) |
| CURSOR_LAYER | ❌ TBD | Placeholder only |
| APP_LAYER | ❌ TBD | Placeholder only |
| WIN_LAYER | ❌ TBD | Placeholder only |
| MAC_FN | ✅ Complete | RGB controls |
| WIN_BASE/WIN_FN | ✅ Complete | Windows platform |

### Critical Bug Found
The current implementation incorrectly uses `SEND_STRING()` macros directly in the keymap:
```c
// BROKEN - SEND_STRING cannot be used directly in keymap
#define KC_SYM_TILDE_SLASH SEND_STRING("~/")
// Then used as: KC_SYM_TILDE_SLASH,  // in keymap
```

**Correct approach:**
1. Define custom keycodes in an enum
2. Use custom keycodes in keymap
3. Handle in `process_record_user()` function

### QMK Patterns Required
- Custom keycodes via `enum custom_keycodes`
- `process_record_user()` for SEND_STRING macros
- `LT(layer, KC_NO)` for layer tap (latch on tap)
- Modifier combinations: `LALT(LGUI(KC_X))` for ⌥⌘X

---

## 🗂️ Task Breakdown

### 🔥 High Priority

#### 1. Fix Macro Implementation Architecture
- **Files / Areas**: `keymap.c` - lines 31-48, new enum, new process_record_user
- **Action**: 
  1. Create `enum custom_keycodes` with all custom keys
  2. Replace broken macro defines with enum values
  3. Implement `process_record_user()` to handle SEND_STRING macros
- **Reason**: Current implementation won't compile/work - SEND_STRING cannot be used directly in keymap
- **Risk**: HIGH - Fundamental architecture fix required before any other work

#### 2. Implement NAV_LAYER Selectors
- **Files / Areas**: `keymap.c` - NAV_LAYER definition (lines 61-68)
- **Action**: 
  1. Add `LT(WIN_LAYER, KC_NO)` on S key
  2. Add `LT(APP_LAYER, KC_NO)` on D key  
  3. Add `LT(CURSOR_LAYER, KC_NO)` on F key
  4. Add `LT(APP_LAYER, KC_NO)` on A key (reserved for future)
- **Reason**: NAV layer is the menu system - without selectors, no helper layers are accessible
- **Risk**: MEDIUM - Layer tap behavior may need testing for correct latch behavior

#### 3. Complete APP_LAYER Implementation
- **Files / Areas**: `keymap.c` - APP_LAYER definition, custom keycodes enum
- **Action**:
  1. Add 15 app launcher custom keycodes to enum
  2. Add macro handlers in process_record_user
  3. Map keys per spec:
     - Home row (J/K/L/;): WhatsApp, Signal, WeChat, Telegram
     - Top row (V/N/B/C/E): VS Code, Notion, BGA, Calendar, Mail
     - Bottom row (Z): ChatGPT
     - Special (Esc, `, Space): Calculator, Music, Finder
- **Reason**: Core productivity feature - quick app launching
- **Risk**: MEDIUM - Key conflict with Slack on S (selector key)

#### 4. Complete WIN_LAYER Implementation
- **Files / Areas**: `keymap.c` - WIN_LAYER definition, custom keycodes enum
- **Action**:
  1. Add window management custom keycodes to enum
  2. Add macro handlers in process_record_user
  3. Map keys per spec:
     - Arrow keys: Halves (⇧⌃⌘ + arrow)
     - F key: Maximize (⇧⌃⌘F)
     - Q/W: Top quarters (⌃⌥ + left/right)
     - A/S: Bottom quarters (⇧⌃⌥ + left/right)
     - Z/X: Split view (⌃⌥⌘ + left/right)
- **Reason**: Essential macOS window management via keyboard
- **Risk**: LOW - Standard modifier combinations

### ⚙️ Medium Priority

#### 5. Update SYM_LAYER to Use Custom Keycodes
- **Files / Areas**: `keymap.c` - SYM_LAYER definition (lines 70-143)
- **Action**:
  1. Replace direct SEND_STRING references with custom keycodes
  2. Keep existing layout structure
  3. Verify special symbol positions (F, H, J, K, L)
- **Reason**: Fix broken macro references after architecture fix
- **Risk**: LOW - Mostly mechanical replacement

#### 6. Complete CURSOR_LAYER Structure
- **Files / Areas**: `keymap.c` - CURSOR_LAYER definition (lines 145-152)
- **Action**:
  1. Add layer structure with transparent keys
  2. Add placeholder comments for TBD commands
  3. Document expected key positions for future mapping
- **Reason**: Prepare structure for future Cursor IDE integration
- **Risk**: LOW - Placeholder implementation only

#### 7. Update Encoder Configuration
- **Files / Areas**: `keymap.c` - encoder_map section (lines 197-204)
- **Action**:
  1. Add encoder maps for NAV_LAYER, SYM_LAYER, CURSOR_LAYER, APP_LAYER, WIN_LAYER
  2. Update to use zoom macros (Cmd - / Cmd +) for left encoder
  3. Keep volume for right encoder
- **Reason**: Spec requires zoom functionality on encoder
- **Risk**: LOW - Standard encoder configuration

### 🧩 Low Priority

#### 8. Add Encoder Zoom Macros
- **Files / Areas**: `keymap.c` - macro definitions
- **Action**:
  1. Define `KC_ZOOM_OUT` as `LGUI(KC_MINS)` (Cmd -)
  2. Define `KC_ZOOM_IN` as `LGUI(KC_EQL)` (Cmd =)
  3. Update encoder maps to use zoom macros
- **Reason**: Convenient zoom control during coding
- **Risk**: LOW - Simple modifier combinations

#### 9. Resolve Key Conflicts
- **Files / Areas**: `keymap.c` - APP_LAYER
- **Action**:
  1. Move Slack from S to M key (S is WIN_LAYER selector in NAV)
  2. Add Notes app to available key (spec TBD)
  3. Document resolution in comments
- **Reason**: S key conflict with WIN_LAYER selector
- **Risk**: LOW - Layout adjustment only

#### 10. Add rules.mk Features (if needed)
- **Files / Areas**: `rules.mk`
- **Action**:
  1. Verify `SEND_STRING_ENABLE` is available
  2. Add `VIA_ENABLE = yes` for VIA support
  3. Add any required features for macros
- **Reason**: SEND_STRING macros may require feature flag; VIA enables runtime configuration
- **Risk**: LOW - Standard QMK configuration

---

## 🔁 Execution Order

### Phase 1: Architecture Fix (Critical)
1. **Task 1**: Fix Macro Implementation Architecture
   - Create custom_keycodes enum
   - Implement process_record_user()
   - Dependency: None
   - Validation: Keymap compiles

### Phase 2: Core Layer Implementation
2. **Task 5**: Update SYM_LAYER to Use Custom Keycodes
   - Dependency: Task 1 complete
   - Validation: SYM layer compiles, macros work

3. **Task 2**: Implement NAV_LAYER Selectors
   - Dependency: Task 1 complete
   - Validation: Layer switching works

### Phase 3: Helper Layers
4. **Task 3**: Complete APP_LAYER Implementation
   - Dependency: Tasks 1, 2 complete
   - Validation: App launchers trigger correct shortcuts

5. **Task 4**: Complete WIN_LAYER Implementation
   - Dependency: Tasks 1, 2 complete
   - Validation: Window management shortcuts work

6. **Task 6**: Complete CURSOR_LAYER Structure
   - Dependency: Tasks 1, 2 complete
   - Validation: Layer accessible, structure ready

### Phase 4: Encoder & Polish
7. **Task 8**: Add Encoder Zoom Macros
   - Dependency: None (can be parallel with Phase 3)
   - Validation: Zoom macros defined

8. **Task 7**: Update Encoder Configuration
   - Dependency: Task 8 complete
   - Validation: Encoder maps for all layers

9. **Task 9**: Resolve Key Conflicts
   - Dependency: Task 3 complete
   - Validation: No selector conflicts

10. **Task 10**: Add rules.mk Features
    - Dependency: Full implementation complete
    - Validation: Final compile succeeds

### Validation Checkpoints
- After Phase 1: `qmk compile` succeeds
- After Phase 2: SYM layer macros work, NAV selectors work
- After Phase 3: All app launchers and window management work
- After Phase 4: Full functional test on hardware

---

## 🧪 Testing & Validation

### Required Test Types

#### Compilation Tests
- [ ] `qmk compile -kb keychron/q11/ansi_encoder -km j-custom` succeeds
- [ ] No undefined keycode references
- [ ] No syntax errors in SEND_STRING macros
- [ ] All custom keycodes in enum are handled in process_record_user

#### Functional Tests (Hardware Required)
- [ ] MAC_BASE: All letters type correctly
- [ ] NAV_LAYER: Thumb hold activates, A/S/D/F latch helper layers
- [ ] SYM_LAYER: Thumb hold activates, symbols output correctly
- [ ] SYM_LAYER macros: H (backticks), J (()), K ({}), L ([]), F (~/)
- [ ] APP_LAYER: All 15 app shortcuts trigger correctly
- [ ] WIN_LAYER: All window management shortcuts work
- [ ] CURSOR_LAYER: Layer accessible (commands TBD)
- [ ] Encoder: Rotation zooms in/out

### Edge Cases and Failure Modes
- Rapid layer switching doesn't cause stuck keys
- Holding selector key in NAV doesn't double-activate
- Multiple modifier combinations work correctly
- SEND_STRING macros complete before key release
- Layer deactivation on thumb release works consistently

### Rollback Plan
- Keep backup of working keymap.c before changes
- Use git to track changes incrementally
- Test after each phase before proceeding
- Revert to last working state if issues found

---

## 🧼 Cleanup & Quality Checks

### Refactors
- Remove unused `KC_TASK` and `KC_FLXP` defines (lines 49-50)
- Organize custom keycodes by category in enum
- Group related macros in process_record_user

### Naming & Structure
- Use consistent naming: `KC_APP_*` for apps, `KC_WIN_*` for windows, `KC_SYM_*` for symbols
- Add section comments between layer definitions
- Document each macro's purpose

### Documentation Updates
- Add header comment explaining layer architecture
- Document activation flow in comments
- Mark CURSOR_LAYER commands as TBD with expected behavior

---

## 🤔 Assumptions

| Assumption | Origin | Safety Rationale |
|------------|--------|------------------|
| SEND_STRING requires process_record_user() | QMK standard practice | This is documented QMK behavior |
| LT(layer, KC_NO) provides latch on tap | Spec design | Standard QMK layer-tap, may need testing |
| Modifier combinations work on macOS | Spec macros | Standard macOS shortcuts, documented in spec |
| Encoder map needs all layers | QMK requirement | Prevents undefined behavior |
| Slack conflict resolution (S→M) | NON-BLOCKER default | M is available and memorable for "Messages" |
| Notes app on key N works with Notion on same key | NON-BLOCKER | Different modifiers (⌥⌘N vs ⇧⌃⌘N) |
| Cursor IDE commands left as TBD | Spec explicit | Documented as incomplete, not blocking |

---

## ✅ Completion Criteria

### Objective "Done" Conditions
1. ✅ `qmk compile` succeeds with zero errors
2. ✅ All 9 layers defined (6 primary + MAC_FN + WIN_BASE + WIN_FN)
3. ✅ Custom keycodes enum contains all app, window, and symbol macros
4. ✅ `process_record_user()` handles all SEND_STRING macros
5. ✅ NAV_LAYER has working A/S/D/F selectors
6. ✅ SYM_LAYER has 5 working special macros (backticks, parens, braces, brackets, tilde-slash)
7. ✅ APP_LAYER has 15 working app launcher macros
8. ✅ WIN_LAYER has 10 working window management macros
9. ✅ Encoder maps defined for all layers with zoom functionality
10. ✅ No key conflicts between selectors and macros

### What Reviewers and CI Should Verify
- Compilation succeeds on QMK toolchain
- No warnings in compile output
- All custom keycodes have corresponding handler
- Layer indices match enum order
- Macro modifier combinations correct for macOS
- Comments accurate and helpful

---

## 📊 Confidence Declaration

**I am ≥99% confident this plan can be executed without further clarification.**

The tech spec provides comprehensive layer definitions, macro specifications, and known issues with proposed resolutions. The critical macro architecture fix is well-understood QMK practice. All TBD items (Cursor IDE commands, encoder tap dance) are explicitly documented as deferred scope.

---

## 📎 Appendix: Custom Keycodes Reference

### Required Custom Keycodes Enum
```c
enum custom_keycodes {
    // Symbol macros (SYM_LAYER)
    KC_SYM_BACKTICKS = SAFE_RANGE,
    KC_SYM_TILDE_SLASH,
    KC_SYM_PARENTHESES,
    KC_SYM_CURLY_BRACES,
    KC_SYM_SQUARE_BRACKETS,
    
    // App launchers (APP_LAYER)
    KC_APP_CHATGPT,
    KC_APP_VSCODE,
    KC_APP_CAL,
    KC_APP_MAIL,
    KC_APP_SLACK,
    KC_APP_BGA,
    KC_APP_WHATSAPP,
    KC_APP_SIGNAL,
    KC_APP_WECHAT,
    KC_APP_TELEGRAM,
    KC_APP_CALC,
    KC_APP_MUSIC,
    KC_APP_NOTION,
    KC_APP_NOTES,
    KC_APP_FINDER,
    
    // Window management (WIN_LAYER)
    KC_WIN_MAX,
    KC_WIN_LEFT,
    KC_WIN_RIGHT,
    KC_WIN_TOP,
    KC_WIN_BOTTOM,
    KC_WIN_TL,
    KC_WIN_TR,
    KC_WIN_BL,
    KC_WIN_BR,
    KC_WIN_SV_L,
    KC_WIN_SV_R,
};
```

### Modifier Reference (macOS)
| Symbol | QMK Code | macOS Key |
|--------|----------|-----------|
| ⌘ | LGUI | Command |
| ⌥ | LALT | Option |
| ⌃ | LCTL | Control |
| ⇧ | LSFT | Shift |

---

**Document Version**: 1.0  
**Created**: 2026-01-26  
**Target**: Keychron Q11 ANSI Encoder  
**Keymap**: j-custom
