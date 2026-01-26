# Step 2 — Final Mapping Proposal (LAYOUT_91_ansi)

This document proposes the **physical key mapping** based on:
- `LAYOUT_91_ansi`
- The **approved plan (Step 1)**
- Your rule: **Left hand = NAV control, Right hand = actions**
- **Home row first** for daily / high‑frequency actions

No code yet — this is a **human‑readable, finger‑centric mapping** so you can validate comfort and logic.

---

## 1. High‑level rule (locked)

- **Left hand**
  - Holds NAV (thumb)
  - Selects helper layers (A/S/D/F)
  - Does NOT perform Cursor actions

- **Right hand**
  - Performs Cursor actions
  - Home row = highest‑frequency actions
  - Top row = secondary / setup actions

- **Cursor helper (Layer 3)** is active only when:
  - Left thumb is held **AND**
  - Selector `F` has been tapped

---

## 2. Left hand — NAV layer (control only)

### Selector row (home row)

Physical keys (left hand home row):

| Key | Behaviour on NAV |
|----|------------------|
| A | Reserved selector (future helper) |
| S | Reserved selector (future helper) |
| D | Reserved selector (future helper) |
| **F** | **Latch Cursor helper (Layer 3)** |

> These keys are **not actions**. They only choose *which helper is active* while the thumb is held.

---

## 3. Right hand — Cursor helper actions (Layer 3)

### 3.1 Home row (highest frequency — daily use)

Physical right‑hand home row: **H J K L ;**

| Key | Cursor action | Reasoning |
|----|--------------|-----------|
| **J** | Previous change | Diff / suggestion navigation (spam‑safe) |
| **K** | Next change | Diff / suggestion navigation |
| **L** | Apply in editor | Primary “commit” action |
| **;** | Accept all files | High‑impact, deliberate key |
| **H** | Focus editor | Quick escape back to code |

> These are the actions you will hit repeatedly while reviewing AI output.

---

### 3.2 Top row (setup / mode / model)

Physical right‑hand top row: **Y U I O P [ ]**

| Key | Cursor action | Notes |
|----|--------------|-------|
| **I** | Open / focus chat | Entry point to AI |
| **O** | Mode picker (Agent / Plan / Ask) | High but not spammed |
| **P** | Model picker | Explicit, intentional |
| **[** | Submit with codebase | Strong semantic grouping |
| **]** | Submit (no codebase) | Adjacent pair |
| **U** | Toggle terminal | Context switch |
| **Y** | Toggle explorer | Project navigation |

---

### 3.3 Secondary actions (optional, later)

These are **not mandatory** for v1, but fit naturally:

| Key | Action |
|----|--------|
| `'` | Discard all files |
| `,` / `.` | Cursor up / down |
| `/` | Regenerate |

We will only add these after you are comfortable with v1.

---

## 4. Behaviour walkthrough (real usage)

### Typical AI review loop
1. Hold **Left thumb** → NAV active
2. Tap **F** → Cursor helper latched
3. Right hand:
   - **I** → focus chat
   - type prompt
   - **O / P** → pick mode / model
   - **[** → submit with codebase
   - **J / K** → review changes
   - **L** → apply
   - **;** → accept all files
4. Release thumb → back to BASE typing

No toggles. No stuck layers. No typing loss.

---

## 5. What is intentionally NOT mapped

- Left‑hand Cursor actions (to avoid conflict)
- Letter keys outside right‑hand cluster
- Git actions (post‑v1)
- Window management (future helper)

---

## 6. Exit criteria for Step 2

We proceed to **Step 3 (Needs & Preferences Summary)** only if:
- This left‑control / right‑action split feels correct
- Home‑row priority makes sense
- No key feels overloaded or dangerous

Reply with one of:
- **“Step 2 approved”**
- or concrete adjustments (e.g. swap J/K, move accept‑all, etc.)

