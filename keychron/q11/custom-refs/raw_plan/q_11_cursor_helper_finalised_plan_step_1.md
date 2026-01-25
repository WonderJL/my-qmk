# Step 1 — Finalise the Plan (Keychron Q11, QMK‑first)

This document **locks the design decisions** we have reached so far.  
No key placement or code yet — only *behavioural contracts*.  
We will **not** proceed to Step 2 until you confirm this plan.

---

## 1. Core Principles (Locked)

- **QMK is the source of truth**  
  - Config lives in code, committed to GitHub
  - VIA enabled only for compatibility / inspection, not as primary config

- **Typing safety is non‑negotiable**  
  - No toggle modes that hijack letters
  - No surprises like “Q no longer types q”

- **Momentary helper > modal layer**  
  - Cursor functionality appears only when intentionally invoked
  - Releasing the thumb always returns to Base

- **One task at a time**  
  - We finalise plan → then mapping → then documentation

---

## 2. Layer Model (Locked)

### Layers
- **Layer 0 — BASE**  
  Normal typing. No Cursor behaviour.

- **Layer 1 — NAV (Thumb‑held menu)**  
  Activated by holding **Left Thumb**.

- **Layer 2 — SYM**  
  Activated by holding **Right Thumb**.

- **Layer 3 — CURSOR (Helper)**  
  Activated *indirectly* via NAV selectors. Never toggled directly.

---

## 3. Cursor Helper Activation Model (Critical)

This is the most important design decision.

### Behaviour you want

1. Hold **Left Thumb** → NAV layer is active
2. While holding thumb, **tap a selector key** (e.g. `F`)
3. Cursor helper (Layer 3) becomes active **and stays active while thumb is held**
4. You can press **multiple Cursor actions** (`J`, `K`, `;`, etc.)
5. **Release thumb** → everything exits back to BASE

### Consequences
- Cursor layer is **never toggled** (`TG` not used)
- Cursor layer is **state‑latched only while NAV is held**
- Releasing the thumb is a guaranteed escape hatch

---

## 4. Selector Keys (Locked)

- Selector keys live on the **NAV layer**
- You chose: **“selectors stay selectors”**

Meaning:
- While thumb is held:
  - `A / S / D / F` do **not type letters**
  - They act as **menu selectors**

### Current selector decision
- `F` → latch **Cursor helper (Layer 3)**
- `A / S / D` → reserved for future helpers (window manager, git, etc.)

---

## 5. Cursor Helper Responsibilities (Locked Scope)

Cursor helper is a **power overlay**, not a remap of everything.

### Priorities (in order)
1. Panels & layout control (chat / terminal / explorer)
2. Multi‑cursor & block selection
3. File navigation & command palette
4. AI accept / apply / regenerate
5. Git (minimal, later)

### Explicitly NOT goals
- Replacing normal typing
- Becoming a Vim‑style full mode
- Long‑term sticky state

---

## 6. Encoder Behaviour (Locked)

- **Rotate** → Zoom out / Zoom in (`Cmd -` / `Cmd =`)
- **Single press** → Zoom reset (`Cmd + 0`)
- **Double press** → Lock screen (`Ctrl + Cmd + Q`)

Notes:
- Rotate + single press = Phase 1
- Double press = Phase 2 (Tap Dance or small QMK logic)

---

## 7. Layout Definition (Confirmed)

- Keyboard layout macro: **`LAYOUT_91_ansi`**
- Source: `info.json` (Keychron Q11 ANSI)
- This is what we will use in `keymap.c`

---

## 8. What is NOT decided yet (by design)

- Exact physical key placements (J/K/L/; etc.)
- Exact Cursor command bindings per key
- Whether selectors beyond `F` will be used
- Git / window management extensions

All of these belong to **Step 2**.

---

## 9. Exit Criteria for Step 1

We move to **Step 2 — Final Mapping** only when you confirm:

- The helper‑layer model is correct
- Thumb‑held + selector latch behaviour matches your mental model
- No typing disruption is acceptable

Reply with one of:
- **“Step 1 approved”**  
- or a list of changes you want before approval

