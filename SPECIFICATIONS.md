# The Message — Technical Specifications

## Overview

Short experimental narrative game built in Lua with LÖVE 2D. Inspired by the Sandia National Laboratories 1993 nuclear waste warning message. The player walks right through a landscape, arranging unknown symbols at campfires, accumulating visual decay until reaching a dark, silent center.

**Runtime:** 5-10 minutes
**Engine:** LÖVE 2D (Lua)
**Core thesis:** "Go right but it's wrong"

---

## Structure

### 5 Campfires

Each campfire maps to a condensed line of the Sandia warning:

| Campfire | Thematic Line | Symbol Count | Shader Effect |
|----------|--------------|--------------|---------------|
| 1 | "Pay attention, this matters" | 3 | Hue shift |
| 2 | "This place is bad" | 3 | Vignette darkening |
| 3 | "The danger is here and persistent" | 4 | Saturation drain |
| 4 | "The danger is to the body" | 4 | Chromatic aberration |
| 5 | "Disturb this place and it's unleashed" | 5 | Screen wobble |

Warning text is **never displayed**. Thematic lines are structural reference only.

### Campfire Spacing

Fibonacci sequence: 1, 1, 2, 3, 5 (in base distance units, tuned during implementation).

---

## Game States

Four states, one-directional flow:

```
walking → campfire → transition → walking → ... → center
```

### walking
- Player moves right (fast, ~100px/sec) or left (slow, ~50px/sec)
- Shaders active, world scrolling
- Campfire triggers state change on proximity

### campfire
- Movement disabled
- Symbol arrangement UI displayed (horizontal row, centered)
- Swap interaction: click symbol A, click symbol B, they swap
- Visual highlight on selected symbol
- Enter key confirms arrangement

### transition
- Brief pause after confirmation
- New shader parameter applied
- Auto-advances to walking after short timer

### center
- Screen fades to darkness
- All inputs dead (no movement, no interaction)
- Audio sequence plays (see Audio section)
- Game stays here indefinitely — player must quit

---

## Movement

- **Right:** Fast (~100px/sec), default direction
- **Left:** Slow (~50px/sec), mechanical resistance
- No escape ending — left only delays, never exits
- No jumping, no vertical movement
- The only ending is the center

---

## Symbol System

### Pool
- 20-25 occult/mystical symbols (tarot, rune, sigil inspired)
- No labels, no meaning communicated to player
- Art style TBD (hand drawn or generated)

### Per-Campfire Assignment
- **Pre-authored** for MVP (fixed symbol sets per campfire)
- Randomization added later (shuffle pool and deal)

### Data Structure

```lua
campfires = {
    {symbols = {1, 2, 3},          effect = 1},
    {symbols = {5, 8, 11},         effect = 2},
    {symbols = {3, 7, 10, 14},     effect = 3},
    {symbols = {2, 6, 9, 12},      effect = 4},
    {symbols = {4, 8, 13, 15, 1},  effect = 5},
}
```

### Interaction Flow

```
symbols appear →
click symbol A (highlight) →
click symbol B →
A and B swap →
repeat as desired →
press Enter →
shader params update →
transition state
```

### Symbol → Shader Mapping

First symbol's index in pool / total symbol count = float between 0 and 1. Fed to the corresponding campfire's shader uniform.

```lua
progress.shaderParams[campfireIndex] = campfire.symbols[1] / totalSymbols
```

---

## Shader System

### Architecture
- **One uber-shader** with 5 float uniforms
- All effects in a single post-processing pass
- Draw world to canvas, apply shader to canvas

### Pipeline

```lua
-- Each frame:
-- 1. Draw everything to canvas
-- 2. Apply uber-shader with current params
-- 3. Draw canvas to screen
```

### Effects (in order of addition)

| Campfire | Effect | Difficulty | Description |
|----------|--------|-----------|-------------|
| 1 | Hue shift | Easy | Rotate pixel colors. Subtle → deeply wrong. |
| 2 | Vignette darkening | Easy | Darken screen edges. Claustrophobia. |
| 3 | Saturation drain | Easy | Pull toward grayscale. Lifeless. |
| 4 | Chromatic aberration | Moderate | Split RGB channels. Broken/sick. |
| 5 | Screen wobble | Moderate | Sine-based position offset. Unstable. |

### Stacking Behavior
- Effects persist once added — parameters never reset
- Earlier effects may intensify slightly at later campfires (TBD during tuning)
- By campfire 5: shifted colors + dark edges + desaturated + split channels + wobbly geometry

### Uniform Structure

```lua
progress = {
    campfireIndex = 1,
    shaderParams = {0, 0, 0, 0, 0}
}
```

---

## Environment

### Background Spikes
- Purely visual (no collision)
- Increase in density and proximity toward center
- Early: distant, barely visible
- Late: dominating screen

### Campfire Dimming
- Campfires get progressively darker/dimmer toward center
- Reinforces environmental decay

---

## Center Ending

### Visual
- Screen gradually fades to black (not instant cut)
- Shaders stop mattering — nothing to render

### Audio (Three Phases)

| Phase | Duration | Description |
|-------|----------|-------------|
| 1 | ~5-8 sec | Heartbeat only. Player orienting in darkness. |
| 2 | ~10-15 sec | Geiger counter fades in under heartbeat. Both coexist. Dread lives here. |
| 3 | Indefinite | Heartbeat fades to quiet (not slowing, just quieter). Geiger counter alone. |

### Design Intent
- Player should feel like they lost control or "lost the plot"
- Not sure if they lost the game
- No game over screen, no credits, no title return
- Game stays on black with Geiger counter indefinitely
- Player must close the game themselves

### Inputs
- All inputs dead. No response to any key press.

---

## Audio

| Asset | Type | Source |
|-------|------|--------|
| Heartbeat | Loop/fadeable | TBD (record, synthesize, or CC asset) |
| Geiger counter | Loop | TBD |
| Ambient tone | Optional background | TBD |
| UI feedback | Minimal (symbol click/swap) | TBD |

---

## Art Assets

| Asset | Description | Priority |
|-------|-------------|----------|
| Player character | Simple sprite or rectangle | MVP |
| Campfire | Simple sprite or placeholder | MVP |
| 20-25 symbols | Occult/mystical icons | MVP (biggest art task) |
| Background spikes | Simple shapes, scalable | MVP |

---

## Input

| Input | Action |
|-------|--------|
| Right arrow / D | Move right (fast) |
| Left arrow / A | Move left (slow) |
| Mouse click | Select/swap symbols at campfire |
| Enter | Confirm symbol arrangement |

---

## Scope Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Campfire count | 5 (not 9) | Buildable in 2 weeks, full thematic arc preserved |
| Symbol counts | 3, 3, 4, 4, 5 | Gentle ramp, drag UI stays manageable |
| Interaction | Swap (not drag-and-drop) | Simpler to build, less fiddly UX |
| Escape ending | Cut | One ending only. Left delays, never exits. Thematically honest. |
| Shader approach | One uber-shader | No render-to-texture chaining, simpler pipeline |
| Symbol assignment | Pre-authored for MVP | Consistent testing, randomization added later |
| Save system | None | 5-10 minute runtime, no need |
| Escape prompt | None | Game never directly addresses player. Silence is consistent. |

---

## Implementation Priority

### Week 1: Vertical Slice
1. Player movement (right fast, left slow)
2. Camera follow
3. Campfire placement (2 test campfires)
4. Campfire interaction state (swap UI, Enter to confirm)
5. Basic uber-shader (hue shift only)
6. Symbol → shader parameter mapping
7. State transitions working end to end

### Week 2: Complete & Polish
1. Expand to 5 campfires with Fibonacci spacing
2. All 5 shader effects in uber-shader
3. Shader stacking and tuning
4. Background spikes (progressive density)
5. Campfire dimming
6. Center ending (darkness, heartbeat, Geiger counter, dead inputs)
7. Symbol art (20-25 icons)
8. Audio integration
9. Pacing and balance pass

---

## Open Questions (Solve During Development)

- Base distance unit for Fibonacci spacing
- Exact movement speeds (test for pacing)
- Shader intensity curves (linear? exponential?)
- Symbol art style and creation method
- Audio sourcing (record, synthesize, Creative Commons)
- Whether earlier shader effects intensify at later campfires
- Environmental detail level (how much before unreadable)
- Transition state duration
