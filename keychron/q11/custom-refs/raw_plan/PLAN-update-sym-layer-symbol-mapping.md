# PLAN: Update SYM Layer Symbol Mapping for Keychron Q11

## 🧠 Problem Understanding

### Task
Update the **SYM Layer (Layer 2)** in the existing QMK keymap plan with:
1. **Special macros on home row** for common coding patterns:
   - Six backticks macro: ` ```\n``` ` (with cursor positioned after newline, in middle)
   - Tilde-slash: `~/`
   - Square brackets: `[]` (with cursor in middle)
   - Parentheses: `()` (with cursor in middle)
   - Curly braces: `{}` (with cursor in middle)
2. **Standard ANSI layout preserved**: Keep symbols in their standard ANSI positions
3. **Direct symbol access**: When SYM layer is active, keys output their shifted versions directly (no shift key needed)
4. **Tap dance for dual-symbol keys**: Keys with two symbols (e.g., `| \`) use tap dance:
   - Single tap = unshifted symbol (e.g., `\`)
   - Double tap = shifted symbol (e.g., `|`)

### Scope
- **Update Task 5** in existing plan: Replace TBD symbol mappings with complete specification
- **Add Task 2.5**: Define special macro keycodes for bracket/parentheses/braces/backticks
- **Home row special macros**: Place 5 special macros on home row keys
- **Standard ANSI symbol layout**: Keep symbols in standard positions, output shifted versions directly
- **Tap dance implementation**: Implement tap dance for dual-symbol keys (single tap = unshifted, double tap = shifted)
- **QMK macro implementation**: All special macros using QMK's string sending capabilities

### Non-Goals
- Changes to other layers (BASE, NAV, CURSOR, APP, WIN)
- Windows-specific symbol variations
- VIA configuration updates

### Constraints
- **Keyboard**: Keychron Q11 ANSI with encoder (91 keys, split design)
- **Layout**: `LAYOUT_91_ansi` (from `info.json`)
- **Firmware**: QMK (code-managed)
- **Platform**: macOS primary
- **Design principles**:
  - Typing safety: letters always type letters on BASE
  - Momentary power: SYM layer activates only when right thumb held
  - Home row priority: highest-frequency symbols on home row
  - Both hands: left for less frequent, right for frequent

## 🎯 Objectives

### Success Criteria
1. **Special Macros on Home Row**: All 5 special macros (backticks, ~/, [], (), {}) placed on home row keys
2. **Standard ANSI Layout**: All symbols remain in their standard ANSI positions
3. **Direct Symbol Access**: When SYM layer active, keys output shifted symbols directly (no shift needed)
4. **Tap Dance Implementation**: Dual-symbol keys use tap dance (single tap = unshifted, double tap = shifted)
5. **Cursor Positioning**: Special macros position cursor correctly (in middle of brackets/parentheses/braces)
6. **QMK Implementation**: All macros and tap dance use proper QMK syntax and compile successfully

### Quality Expectations
- **Correctness**: All symbols output correctly when SYM layer is active
- **Ergonomics**: Special macros on easily reachable home row keys
- **Familiarity**: Standard ANSI layout preserved for muscle memory
- **Maintainability**: Clear code structure, well-commented
- **Usability**: Special macros work correctly with cursor positioning, tap dance works reliably

## 🧩 System / Codebase Context

### Existing Plan Context
- **File**: `keychron/q11/custom-refs/raw_plan/PLAN-add-app-layer-and-win-layer-to-qmk-keymap-for-keyc-v2.md`
- **Task 5**: Currently has TBD placeholder for SYM layer symbol mappings
- **Layer Structure**: SYM layer is Layer 2, activated by Right Thumb hold (`MO(SYM_LAYER)`)
- **Design Pattern**: Follows same structure as other layers in the plan

### Symbol Frequency List (User Provided)

**Most frequently used symbols (high use):**
1. `,` (comma)
2. `.` (period / full stop)
3. `-` (hyphen/minus)
4. `"` (double quote)
5. `_` (underscore)
6. `'` (single quote / apostrophe)
7. `)` (right parenthesis)
8. `(` (left parenthesis)
9. `;` (semicolon)
10. `=` (equals)
11. `:` (colon)
12. `/` (slash)
13. `:` (colon) - duplicate, already listed

**Moderate frequency symbols:**
14. `?` (question mark)
15. `*` (asterisk)
16. `+` (plus)
17. `<` (less than)
18. `>` (greater than)
19. `[` (left bracket)
20. `]` (right bracket)
21. `{` (left brace)
22. `}` (right brace)
23. `@` (at sign)
24. `|` (vertical bar)
25. `~` (tilde)

**Less frequently used symbols (low use):**
26. `%` (percent)
27. `#` (hash/pound)
28. `^` (caret / circumflex)
29. `&` (ampersand)
30. `\` (backslash)

### Special Macros Required

1. **Six Backticks Macro**: Output ` ```\n``` ` with cursor positioned after the newline (in the middle)
2. **Tilde-Slash**: Output `~/`
3. **Square Brackets**: Output `[]` with cursor positioned in middle (between brackets)
4. **Parentheses**: Output `()` with cursor positioned in middle (between parentheses)
5. **Curly Braces**: Output `{}` with cursor positioned in middle (between braces)

### QMK Keycode Reference

Standard QMK keycodes for symbols:
- `KC_COMM` = comma (`,`)
- `KC_DOT` = period (`.`)
- `KC_MINS` = hyphen/minus (`-`)
- `KC_QUOT` = single quote (`'`)
- `KC_DQUO` = double quote (`"`) - may need `LSFT(KC_QUOT)` on macOS
- `KC_UNDS` = underscore (`_`) - `LSFT(KC_MINS)`
- `KC_LPRN` = left parenthesis (`(`) - `LSFT(KC_9)`
- `KC_RPRN` = right parenthesis (`)`) - `LSFT(KC_0)`
- `KC_SCLN` = semicolon (`;`)
- `KC_EQL` = equals (`=`)
- `KC_COLN` = colon (`:`) - `LSFT(KC_SCLN)`
- `KC_SLSH` = slash (`/`)
- `KC_QUES` = question mark (`?`) - `LSFT(KC_SLSH)`
- `KC_ASTR` = asterisk (`*`) - `LSFT(KC_8)`
- `KC_PLUS` = plus (`+`) - `LSFT(KC_EQL)`
- `KC_LT` = less than (`<`) - `LSFT(KC_COMM)`
- `KC_GT` = greater than (`>`) - `LSFT(KC_DOT)`
- `KC_LBRC` = left bracket (`[`)
- `KC_RBRC` = right bracket (`]`)
- `KC_LCBR` = left brace (`{`) - `LSFT(KC_LBRC)`
- `KC_RCBR` = right brace (`}`) - `LSFT(KC_RBRC)`
- `KC_AT` = at sign (`@`) - `LSFT(KC_2)`
- `KC_PIPE` = vertical bar (`|`) - `LSFT(KC_BSLS)`
- `KC_TILD` = tilde (`~`) - `LSFT(KC_GRV)`
- `KC_PERC` = percent (`%`) - `LSFT(KC_5)`
- `KC_HASH` = hash/pound (`#`) - `LSFT(KC_3)`
- `KC_CIRC` = caret (`^`) - `LSFT(KC_6)`
- `KC_AMPR` = ampersand (`&`) - `LSFT(KC_7)`
- `KC_BSLS` = backslash (`\`)

### QMK String Sending for Special Macros

For special macros that need to output strings and position cursor:
- Use `SEND_STRING()` macro for simple string output
- For cursor positioning, use `SEND_STRING()` followed by left arrow key
- Example: `SEND_STRING("[]" SS_TAP(X_LEFT))` outputs `[]` and moves cursor left (into middle)

### QMK Tap Dance for Dual-Symbol Keys

For keys that have two symbols (unshifted and shifted):
- Use QMK's tap dance feature
- Single tap outputs unshifted symbol (e.g., `\` for backslash key)
- Double tap outputs shifted symbol (e.g., `|` for backslash key)
- Example: `TD(TD_BACKSLASH_PIPE)` where:
  - Single tap = `KC_BSLS` (backslash)
  - Double tap = `KC_PIPE` (vertical bar)

### Layout Structure (LAYOUT_91_ansi)

From existing plan and default keymap:
- **Row 0**: Function keys, media, etc. (17 keys)
- **Row 1**: Numbers and symbols (16 keys)
- **Row 2**: QWERTY top row (16 keys)
- **Row 3**: QWERTY home row (15 keys)
- **Row 4**: QWERTY bottom row (14 keys)
- **Row 5**: Modifiers and thumb keys (13 keys)

**Home Row (Row 3)**: `A S D F G H J K L ; '`
**Top Row (Row 2)**: `Q W E R T Y U I O P [ ] \`
**Bottom Row (Row 4)**: `Z X C V B N M , . /`

## 🗂️ Task Breakdown

### 🔥 High Priority

#### Task 1: Define Special Macro Keycodes
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Add special macro definitions after Task 2 (existing macro definitions)
  ```c
  // ============================================
  // Special Symbol Macros (String Output)
  // ============================================
  // Six backticks: ```\n``` with cursor in middle
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
- **Reason**: Foundation for special symbol macros
- **Risk**: Medium - need to verify SS_TAP syntax and cursor positioning works correctly

#### Task 2: Define Tap Dance for Dual-Symbol Keys
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Define tap dance actions for keys with two symbols
  ```c
  // ============================================
  // Tap Dance Definitions
  // ============================================
  // Tap dance states
  typedef enum {
      TD_NONE,
      TD_SINGLE_TAP,
      TD_SINGLE_HOLD,
      TD_DOUBLE_TAP
  } td_state_t;
  
  // Backslash/Pipe key: \ (single tap) | | (double tap)
  void backslash_pipe_finished(tap_dance_state_t *state, void *user_data) {
      if (state->count == 1) {
          if (!state->pressed) {
              // Single tap: backslash
              tap_code(KC_BSLS);
          }
      } else if (state->count == 2) {
          // Double tap: pipe
          tap_code(KC_PIPE);
      }
  }
  
  void backslash_pipe_reset(tap_dance_state_t *state, void *user_data) {
      if (state->count >= 2) {
          reset_tap_dance(state);
      }
  }
  
  // Define tap dance actions
  qk_tap_dance_action_t tap_dance_actions[] = {
      [TD_BACKSLASH_PIPE] = ACTION_TAP_DANCE_FN_ADVANCED(NULL, backslash_pipe_finished, backslash_pipe_reset),
      // Add more tap dance actions for other dual-symbol keys as needed
  };
  ```
- **Reason**: Enable single tap = unshifted, double tap = shifted for dual-symbol keys
- **Risk**: Medium - tap dance implementation requires testing

#### Task 3: Map Special Macros to Home Row
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Place 5 special macros on home row keys
  - **Right hand home row**:
    - `H` → `KC_SYM_BACKTICKS` (six backticks macro)
    - `J` → `KC_SYM_PARENTHESES` (() macro)
    - `K` → `KC_SYM_CURLY_BRACES` ({} macro)
    - `L` → `KC_SYM_SQUARE_BRACKETS` ([] macro)
  - **Left hand home row**:
    - `F` → `KC_SYM_TILDE_SLASH` (~/ macro)
  - **Note**: `;` key remains for standard ANSI output (`:` colon) to avoid conflict
- **Reason**: Home row priority for special macros (most frequently used), avoid conflict with `;` → `:` output
- **Risk**: Low - standard macro assignment

#### Task 4: Implement Standard ANSI Symbol Layout with Direct Access
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Map symbols to their standard ANSI positions, output shifted versions directly
  - **Row 1 (Number row)**: Output shifted symbols directly
    - `1` → `!` (exclamation) - `KC_EXLM`
    - `2` → `@` (at sign) - `KC_AT`
    - `3` → `#` (hash) - `KC_HASH`
    - `4` → `$` (dollar) - `KC_DLR`
    - `5` → `%` (percent) - `KC_PERC`
    - `6` → `^` (caret) - `KC_CIRC`
    - `7` → `&` (ampersand) - `KC_AMPR`
    - `8` → `*` (asterisk) - `KC_ASTR`
    - `9` → `(` (left parenthesis) - `KC_LPRN`
    - `0` → `)` (right parenthesis) - `KC_RPRN`
    - `-` → `_` (underscore) - `KC_UNDS`
    - `=` → `+` (plus) - `KC_PLUS`
  - **Other rows**: Keep standard positions, output shifted versions
    - `[` → `{` (left brace) - `KC_LCBR`
    - `]` → `}` (right brace) - `KC_RCBR`
    - `\` → Use tap dance: `\` (single tap) or `|` (double tap)
    - `;` → `:` (colon) - `KC_COLN`
    - `'` → `"` (double quote) - `KC_DQUO`
    - `,` → `<` (less than) - `KC_LT`
    - `.` → `>` (greater than) - `KC_GT`
    - `/` → `?` (question mark) - `KC_QUES`
    - `` ` `` → `~` (tilde) - `KC_TILD`
- **Reason**: Preserve standard ANSI layout for muscle memory, direct symbol access
- **Risk**: Low - standard QMK keycode mapping

#### Task 5: Update SYM Layer Implementation (Replace Task 5 in Existing Plan)
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Replace TBD placeholder with complete SYM layer definition
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
                  TD(TD_BACKSLASH_PIPE),  // \: Tap dance (\ single tap, | double tap)
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
                  // Space: Transparent
                  // Right hand: Thumb Cmd Ctrl
                  MO(SYM_LAYER),            // Right thumb: Keep MO(SYM_LAYER) to maintain activation
                  _______,  _______,  // Right modifiers: Transparent
                  _______,  _______,  _______,  // Arrow keys: Transparent
  ),
  ```
- **Key Points**:
  - Activated by Right Thumb hold (`MO(SYM_LAYER)`)
  - **Home row (right hand)**: Special macros (H/J/K/L) for most common coding patterns
    - `H` → Six backticks macro
    - `J` → Parentheses () macro
    - `K` → Curly braces {} macro
    - `L` → Square brackets [] macro
  - **Home row (left hand)**: Special macro (F) for ~/ macro
  - **Home row (right hand)**: `;` outputs `:` (colon) - standard ANSI, no conflict
  - **Number row**: Outputs shifted symbols directly (1→!, 2→@, etc.)
  - **Standard ANSI positions**: Symbols stay in familiar positions
  - **Tap dance**: Backslash key uses tap dance (\ single tap, | double tap)
  - **Letters remain transparent**: Typing safety maintained
- **Reason**: Complete SYM layer implementation with standard ANSI layout and special macros on home row, avoiding conflicts
- **Risk**: Medium - need to verify special macro syntax, cursor positioning, and tap dance implementation

### ⚙️ Medium Priority

#### Task 6: Verify Special Macro Syntax
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Test and verify special macro implementations
  - Verify `SEND_STRING()` syntax is correct
  - Verify `SS_TAP(X_LEFT)` works for cursor positioning
  - Verify `SS_TAP(X_ENTER)` works for newline in backticks macro
  - Test on macOS to ensure cursor positioning works correctly
- **Reason**: Ensure special macros function correctly
- **Risk**: Medium - cursor positioning may need adjustment based on OS behavior

#### Task 7: Add Comments and Documentation
- **Files**: `keychron/q11/ansi_encoder/keymaps/j-custom/keymap.c`
- **Action**: Add comprehensive comments
  - Document symbol frequency numbers
  - Explain special macro behavior
  - Add usage examples
  - Document key placement rationale
- **Reason**: Maintainability and future reference
- **Risk**: None

### 🧩 Low Priority

#### Task 8: Create Symbol Mapping Reference Document
- **Files**: Create `keychron/q11/custom-refs/sym-layer-mapping.md`
- **Action**: Document complete symbol mapping
  - List all 30 symbols with their key positions
  - Document special macros
  - Include frequency rankings
  - Add visual layout diagram
- **Reason**: Reference documentation
- **Risk**: None

## 🔁 Execution Order

### Phase 1: Macro Definitions (Task 1)
1. Add special macro keycode definitions to keymap.c
2. Verify syntax compiles

### Phase 2: Tap Dance and Special Macros (Tasks 2, 3)
1. Implement tap dance for dual-symbol keys (backslash/pipe)
2. Map special macros to home row keys (right hand)

### Phase 3: Layer Implementation (Tasks 4, 5)
1. Implement standard ANSI symbol layout with direct access (no shift needed)
2. Replace TBD placeholder in SYM layer
3. Implement complete LAYOUT_91_ansi definition
4. Verify special macros are on home row
5. Verify tap dance works correctly

### Phase 4: Testing & Verification (Task 6)
1. Compile keymap to check for syntax errors
2. Test special macros (may need hardware testing)
3. Verify cursor positioning works correctly
4. Adjust macros if needed

### Phase 5: Documentation (Tasks 7, 8)
1. Add inline comments to keymap.c
2. Create reference documentation
3. Update existing plan document

## 🧪 Testing & Validation

### Required Test Types

#### Compilation Tests
- [ ] Keymap compiles without errors
- [ ] No undefined keycode references
- [ ] All macros properly defined
- [ ] No syntax errors in SEND_STRING macros

#### Functional Tests (Hardware Required)
- [ ] SYM layer activates with right thumb hold
- [ ] Number row outputs shifted symbols directly (1→!, 2→@, etc.)
- [ ] Standard ANSI symbol positions work correctly:
  - [ ] `[` outputs `{`
  - [ ] `]` outputs `}`
  - [ ] `;` outputs `:`
  - [ ] `'` outputs `"`
  - [ ] `,` outputs `<`
  - [ ] `.` outputs `>`
  - [ ] `/` outputs `?`
  - [ ] `` ` `` outputs `~`
- [ ] Tap dance works correctly:
  - [ ] Single tap on `\` outputs `\`
  - [ ] Double tap on `\` outputs `|`
- [ ] Special macros output correct strings:
  - [ ] Six backticks: cursor in middle (after newline)
  - [ ] Square brackets: cursor between brackets
  - [ ] Parentheses: cursor between parentheses
  - [ ] Curly braces: cursor between braces
  - [ ] Tilde-slash outputs correctly
- [ ] Layer deactivates on thumb release

#### Ergonomic Tests
- [ ] Special macros on home row are easily reachable (H/J/K/L on right, F on left)
- [ ] Standard ANSI layout feels familiar (muscle memory)
- [ ] No awkward hand positions required
- [ ] Tap dance timing feels natural
- [ ] No conflicts between special macros and standard symbol outputs

### Edge Cases
- [ ] Rapid thumb press/release doesn't cause stuck symbols
- [ ] Special macros work in different applications (text editor, terminal, etc.)
- [ ] Cursor positioning works across different text contexts
- [ ] Tap dance doesn't interfere with normal typing
- [ ] No conflicts with BASE layer typing
- [ ] Letters still type correctly when SYM layer is active (transparent keys)

### Failure Modes
- **Macro doesn't output**: Check SEND_STRING syntax
- **Cursor positioning wrong**: Adjust SS_TAP(X_LEFT) count
- **Symbol outputs wrong character**: Verify keycode mapping (check if shifted version is correct)
- **Tap dance not working**: Verify tap dance implementation and timing
- **Layer stuck active**: Verify thumb release logic
- **Letters typing symbols**: Check that letter keys are transparent on SYM layer

### Rollback Plan
- Git commit before changes: `git commit -m "Backup before SYM layer update"`
- If issues: `git checkout HEAD -- keymap.c` and reflash

## 🧼 Cleanup & Quality Checks

### Code Quality
- [ ] Consistent naming: `KC_SYM_*` for special macros
- [ ] Tap dance actions properly defined and documented
- [ ] Comments explain special macro behavior
- [ ] Comments explain tap dance behavior (single tap vs double tap)
- [ ] Standard ANSI layout clearly documented
- [ ] Special macros well-documented

### Structure
- [ ] Special macros defined before keymap
- [ ] SYM layer follows same structure as other layers
- [ ] Consistent indentation (4 spaces)
- [ ] Clear section separators with comments

### Documentation
- [ ] Symbol frequency numbers documented in comments
- [ ] Special macro behavior explained
- [ ] Key placement rationale documented
- [ ] Usage examples provided

## 🤔 Assumptions

### Explicit Assumptions

1. **QMK SEND_STRING Syntax**: Using `SEND_STRING()` with `SS_TAP()` for cursor positioning
   - **Source**: QMK documentation
   - **Safety**: Standard QMK pattern, may need testing

2. **Cursor Positioning**: `SS_TAP(X_LEFT)` moves cursor left by one character
   - **Source**: QMK documentation
   - **Safety**: Standard behavior, may need adjustment based on OS

3. **Newline in Backticks**: `SS_TAP(X_ENTER)` creates newline
   - **Source**: QMK documentation
   - **Safety**: Standard behavior

4. **Double Quote Keycode**: Using `KC_DQUO` or `LSFT(KC_QUOT)` depending on macOS layout
   - **Source**: QMK keycode reference
   - **Safety**: May need testing to verify correct output

5. **Symbol Frequency**: User-provided frequency list is accurate for their use case
   - **Source**: User input
   - **Safety**: User knows their usage patterns

6. **Standard ANSI Layout**: Symbols stay in their standard positions for muscle memory
   - **Source**: User preference
   - **Safety**: Preserves familiar layout

7. **Tap Dance Timing**: Standard QMK tap dance timing (200ms default)
   - **Source**: QMK documentation
   - **Safety**: May need adjustment based on user preference

### NON-BLOCKER Defaults Used

- **Special Macro Keys**: Assigned to right-hand home row (H/J/K/L/;) for easy access
- **Letter Keys**: Remain transparent on SYM layer (typing safety)
- **Transparent Keys**: Row 0, letter keys, and modifier keys remain transparent
- **Tap Dance Timing**: Using default QMK timing (may need adjustment)

## ✅ Completion Criteria

### Objective "Done" Conditions

1. **Special Macros on Home Row**
   - [ ] All 5 special macros placed on home row (H/J/K/L on right hand, F on left hand)
   - [ ] `H` → Six backticks macro outputs ` ```\n``` ` with cursor in middle
   - [ ] `F` → Tilde-slash macro outputs `~/`
   - [ ] `J` → Parentheses macro outputs `()` with cursor in middle
   - [ ] `K` → Curly braces macro outputs `{}` with cursor in middle
   - [ ] `L` → Square brackets macro outputs `[]` with cursor in middle
   - [ ] `;` key outputs `:` (colon) - no conflict with special macros

2. **Standard ANSI Layout Preserved**
   - [ ] All symbols remain in their standard ANSI positions
   - [ ] Number row outputs shifted symbols directly (no shift needed)
   - [ ] Standard symbol keys output shifted versions directly
   - [ ] Letters remain transparent (typing safety maintained)

3. **Tap Dance Implementation**
   - [ ] Backslash key uses tap dance
   - [ ] Single tap outputs `\` (backslash)
   - [ ] Double tap outputs `|` (pipe)
   - [ ] Tap dance timing feels natural

4. **Code Quality**
   - [ ] Keymap compiles without errors
   - [ ] All macros properly defined
   - [ ] Well-commented and documented
   - [ ] Follows QMK conventions

5. **Testing Complete**
   - [ ] Compilation successful
   - [ ] All symbols tested (hardware testing)
   - [ ] Special macros tested and working
   - [ ] Cursor positioning verified

### Reviewer Verification

- Code review: Check macro definitions, symbol mappings, layer structure
- Manual testing: Verify each symbol outputs correctly
- Ergonomic review: Check key placements make sense
- Documentation review: Verify completeness

### CI/CD Verification

- QMK compile: `qmk compile -kb keychron/q11/ansi_encoder -km j-custom`
- No warnings or errors
- All macros compile successfully

## 📊 Confidence Declaration

**I am ≥99% confident this plan can be executed to update the SYM layer with standard ANSI layout and special macros on home row.**

### Confidence Factors

✅ **Clear Requirements**: User provided detailed requirements for special macros and standard ANSI layout
✅ **Existing Pattern**: Can follow existing layer structure from plan
✅ **QMK Capability**: Standard ANSI symbols can be mapped using QMK keycodes
✅ **Special Macros**: QMK supports SEND_STRING for special macros
✅ **Tap Dance**: QMK supports tap dance for dual-symbol keys
✅ **Standard Layout**: Preserving ANSI layout maintains muscle memory

### Remaining Uncertainties (Non-Blocking)

- **Cursor Positioning**: May need fine-tuning based on OS behavior (macOS-specific)
- **Tap Dance Timing**: May need adjustment based on user preference (default 200ms)
- **Special Macro Testing**: Requires hardware testing to verify cursor positioning works correctly
- **Symbol Keycodes**: May need to verify correct shifted keycodes for macOS layout

### Next Steps

1. **Review this plan** - Verify special macro placement and standard ANSI layout approach
2. **Approve to proceed** - Update existing plan document with SYM layer details
3. **Implementation** - Add special macros, tap dance, and complete SYM layer in keymap.c
4. **Testing** - Compile and test on hardware
5. **Iteration** - Adjust cursor positioning and tap dance timing if needed based on testing
6. **Documentation** - Update reference documents

---

**Plan Generated**: 2026-01-26  
**Version**: v2 (SYM Layer - Standard ANSI Layout with Home Row Special Macros)  
**Target Keyboard**: Keychron Q11 ANSI Encoder  
**Firmware**: QMK  
**Platform**: macOS  
**Updates**: Task 5 in existing plan document  
**Key Changes from v1**: 
- Special macros moved to home row (right hand)
- Standard ANSI layout preserved (symbols in familiar positions)
- Direct symbol access (no shift needed when SYM layer active)
- Tap dance for dual-symbol keys (single tap = unshifted, double tap = shifted)
