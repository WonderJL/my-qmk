# Layer Logic Check - TG() Toggle Analysis

## Question
Are there any layers activated by `TG()` that have no way back to the base layer (MAC_BASE / Layer 0)?

## TG() Usages Found

### 1. TG(WIN_LAYER) - Layer 5
- **Activation**: NAV_LAYER → Q key (Line 175)
- **Return Path**: 
  - WIN_LAYER has `MO(NAV_LAYER)` on left space (Line 324)
  - NAV_LAYER has `TG(WIN_LAYER)` again on Q key (Line 175) - can toggle off
  - **BUT**: NAV_LAYER is momentary (MO), so releasing thumb returns to... what layer?
- **Status**: ⚠️ **POTENTIAL ISSUE**

### 2. TG(MAC_FN) - Layer 6
- **Activation**: NAV_LAYER → W key (Line 175)
- **Return Path**: 
  - MAC_FN has `MO(NAV_LAYER)` on left space (Line 335)
  - NAV_LAYER has `TG(MAC_FN)` again on W key (Line 175) - can toggle off
- **Status**: ⚠️ **POTENTIAL ISSUE**

### 3. TG(WIN_BASE) - Layer 7
- **Activation**: NAV_LAYER → E key (Line 175)
- **Return Path**: 
  - WIN_BASE has `MO(NAV_LAYER)` on left space (Line 346)
  - NAV_LAYER has `TG(WIN_BASE)` again on E key (Line 175) - can toggle off
- **Status**: ⚠️ **POTENTIAL ISSUE**

### 4. TG(WIN_FN) - Layer 8
- **Activation**: NAV_LAYER → R key (Line 175)
- **Return Path**: 
  - WIN_FN has `MO(NAV_LAYER)` on left space (Line 357)
  - NAV_LAYER has `TG(WIN_FN)` again on R key (Line 175) - can toggle off
- **Status**: ⚠️ **POTENTIAL ISSUE**

### 5. TG(NUMPAD_LAYER) - Layer 10
- **Activation**: NAV_LAYER → H key (Line 186)
- **Return Path**: 
  - NUMPAD_LAYER has `MO(NAV_LAYER)` on left space (Line 391)
  - NAV_LAYER has `TG(NUMPAD_LAYER)` again on H key (Line 186) - can toggle off
- **Status**: ⚠️ **POTENTIAL ISSUE**

## The Problem

**All TG() layers can access NAV_LAYER, but NAV_LAYER itself is momentary (MO).**

When you:
1. Toggle a layer ON (e.g., `TG(WIN_BASE)`)
2. Hold left space to access NAV_LAYER
3. Toggle the layer OFF (e.g., press E again)
4. Release left space (NAV_LAYER deactivates)

**Question**: Where do you return to?

### QMK Behavior
- When a TG() layer is toggled OFF, QMK returns to the **highest active layer**.
- If NAV_LAYER is momentary and you're holding it, releasing it will return to the previously active layer.
- **BUT**: If you toggle OFF a TG() layer while holding NAV_LAYER, and then release NAV_LAYER, you should return to MAC_BASE (Layer 0).

## Analysis

### Scenario 1: Toggle WIN_BASE ON from MAC_BASE
1. MAC_BASE (Layer 0) → Hold left thumb → NAV_LAYER (Layer 1)
2. Press E → `TG(WIN_BASE)` → WIN_BASE (Layer 7) is now active
3. Release left thumb → NAV_LAYER deactivates → Should return to WIN_BASE (Layer 7) ✅

### Scenario 2: Toggle WIN_BASE OFF from WIN_BASE
1. WIN_BASE (Layer 7) → Hold left space → NAV_LAYER (Layer 1) activates
2. Press E → `TG(WIN_BASE)` → WIN_BASE (Layer 7) is toggled OFF
3. Release left space → NAV_LAYER deactivates → Should return to MAC_BASE (Layer 0) ✅

### Scenario 3: Multiple TG() layers active
If multiple TG() layers are active (e.g., WIN_BASE + MAC_FN), QMK uses the highest layer number.

## Conclusion

**All TG() layers have a return path**, but the path requires:
1. Accessing NAV_LAYER (via left space/thumb)
2. Toggling the layer OFF (pressing the same key again)
3. Releasing NAV_LAYER

**However**, there's a potential UX issue:
- If a user toggles WIN_BASE ON and forgets how to toggle it off, they're stuck in WIN_BASE
- They need to remember: Hold left space → Press E → Release left space

## Recommendation

Consider adding a direct way to return to MAC_BASE from toggle layers, such as:
- A dedicated key in each TG() layer that goes directly to MAC_BASE
- Or a `TO(MAC_BASE)` key in NAV_LAYER that forces return to base
