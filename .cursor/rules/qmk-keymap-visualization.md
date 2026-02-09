# QMK Keymap Visualization Rules

## Issue Prevention: Visualization Mismatches

### Problem
When adding new keymap layers or modifying existing ones, transparent keys (`_______`) don't show meaningful labels in keymap visualizations. This causes confusion when comparing the visualization with the actual keymap code.

### Rules

1. **Use Placeholder Keycodes for Visualization**
   - When adding new actions to a layer that should be visible in visualizations, use actual keycodes (even placeholder ones) instead of `_______` (transparent)
   - Create custom keycode enums for placeholder actions with descriptive names (e.g., `KC_CURSOR_FOCUS_EDITOR`)
   - Add placeholder handlers in `process_record_user()` that return `false` until actual implementation

2. **After Keymap Changes**
   - Always regenerate visualizations after modifying keymap layers: `bash visualize.sh`
   - Verify that the visualization matches your intended keymap structure
   - Check that all non-transparent keys show meaningful labels

3. **Transparent Keys**
   - Use `_______` only when you intentionally want keys to pass through to lower layers
   - Remember: Transparent keys will show as `▽` (down arrow) in visualizations, not as the actual keycodes from lower layers
   - If you want to see what a key does in a layer, assign an actual keycode (even if it's a placeholder)

4. **Layer Structure Verification**
   - When adding actions to specific rows (e.g., home row H/J/K/L), verify:
     - The keycodes are placed at the correct positions matching MAC_BASE layout
     - Comments accurately describe what each position does
     - The visualization shows the expected labels

### Example

**❌ Bad (won't show in visualization):**
```c
// Row 3: Home row - Cursor actions
//        H: Focus editor (TBD)
_______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  // H position
```

**✅ Good (shows in visualization):**
```c
// Row 3: Home row - Cursor actions
//        H: Focus editor (TBD)
_______,  _______,  _______,  _______,  _______,  _______,  _______,  KC_CURSOR_FOCUS_EDITOR,  // H position
```

### Checklist Before Committing Keymap Changes

- [ ] All intended actions use actual keycodes (not `_______`)
- [ ] Placeholder keycodes have descriptive names
- [ ] Placeholder handlers exist in `process_record_user()`
- [ ] Visualization regenerated and verified
- [ ] Comments match actual keycode positions
