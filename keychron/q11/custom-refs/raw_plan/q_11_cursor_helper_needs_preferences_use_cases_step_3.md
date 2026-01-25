# Step 3 — Needs, Preferences & Use Cases Summary

This document captures **why** this keyboard exists, **how** it is used daily, and **what constraints must never be violated**.  
It is intended as a long-term reference you can revisit when refining mappings, adding helpers, or refactoring QMK code.

---

## 1. Primary User Profile

- **Platform**: macOS
- **Keyboard**: Keychron Q11 (split, ANSI, encoder)
- **Firmware philosophy**: QMK-first, code-managed, GitHub-committed
- **Usage intensity**: Heavy daily use

---

## 2. Core Workflows (Why this exists)

### 2.1 AI-centric engineering workflow

You spend a large portion of time:
- Chatting with AI agents
- Asking for planning, suggestions, refactors
- Reviewing diffs and generated files
- Accepting / rejecting changes rapidly

This requires:
- Extremely fast **review → apply → iterate** loops
- Minimal cognitive overhead
- Zero mode confusion while typing

---

### 2.2 Editor & environment control

Frequent actions include:
- Switching between editor / terminal / explorer / chat panels
- Opening command palette
- Navigating diffs
- Managing multi-cursor and block selections

These actions must be:
- One-hand actionable (right hand)
- Available only when intentionally invoked

---

## 3. Design Principles (Hard Constraints)

These rules override all future ideas.

### 3.1 Typing safety

- Letters must **always type letters** on Base
- No toggle layers that hijack A–Z
- No surprise state retention

---

### 3.2 Momentary power, not modal power

- Cursor functionality is a **helper**, not a mode
- Activated only when explicitly requested
- Automatically exits on thumb release

---

### 3.3 Muscle-memory first

- Home row = highest-frequency actions
- No reach for daily operations
- Left hand controls, right hand executes

---

## 4. Layer Philosophy

### Base layer (Layer 0)

- Pure typing
- No Cursor behaviour
- No editor semantics

---

### NAV layer (Layer 1)

- Accessed by **holding Left Thumb**
- Acts as a **menu**, not an action layer
- Selector keys choose *which helper* is active

Selectors:
- A / S / D → reserved
- F → Cursor helper

---

### Cursor helper (Layer 3)

- Never toggled
- Active only while NAV thumb is held
- Provides high-power editor & AI actions
- Right hand only

---

## 5. Cursor Helper Intent

The Cursor helper exists to:

1. Navigate AI suggestions and diffs
2. Apply or accept changes safely
3. Control editor focus and panels
4. Reduce mouse usage
5. Reduce RSI through structured hand roles

It explicitly does **not**:
- Replace typing
- Become a Vim clone
- Permanently alter keyboard behaviour

---

## 6. Encoder Philosophy

Encoder is treated as a **global context tool**, not per-layer noise.

- Rotate → Zoom in / out
- Single press → Zoom reset
- Double press → Lock screen (Ctrl + Cmd + Q)

Purpose:
- Visual comfort
- Fast context control
- No accidental triggers

---

## 7. Ergonomics & RSI Considerations

- Split keyboard posture
- Clear left/right responsibility split
- Avoid chord overload
- Prefer sequential actions over complex combos

Cursor helper design reduces:
- Mouse travel
- Hand repositioning
- Mental state switching

---

## 8. Future-proofing (Intentional openness)

This setup is designed to scale:

- Additional helpers (window manager, git, system)
- Reassign selector keys without redesign
- Extend Cursor helper gradually

But:
- Only one helper at a time
- Only after mastery of current layer

---

## 9. What must be re-validated before changes

Before adding or changing anything, check:

- Does this break typing safety?
- Does this introduce a sticky mode?
- Does this overload the left hand?
- Does this increase RSI risk?

If yes → reject the change.

---

## 10. Status

- Step 1: Plan — approved
- Step 2: Mapping — approved
- **Step 3: Needs & preferences — locked**

This document is now your **ground truth** for all future Q11 iterations.
