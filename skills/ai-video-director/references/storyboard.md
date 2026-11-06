# Storyboard: the gate before any video credit

A beat sheet plus "four long static takes" is not a plan. The storyboard is screen by screen:
every cut, insert, card and overlay, with the camera described the way a DP would, and an
actual image of the frame. It is the cheapest place to find out the film doesn't work.

## 1. Beat sheet first (5 minutes)

One line per beat, with seconds. The beats must add up to the target length.

```
0-2s    Hook: the viewer's situation, shown, not said
2-8s    Problem: the moment it hurts
8-20s   Turn: what changes (the product, the idea, the twist)
20-27s  Payoff: the result, on a face
27-30s  Close: brand + one action
```

Rules of thumb:
- **The hook is a person or a motion, never a logo.** Frame 0 must be a complete, readable
  frame (it becomes the poster/thumbnail on most platforms): no entrance animation on it.
- **Open on the viewer's situation** ("you run a sales team and...") rather than on the brand.
- **Ads: brand seen and heard by ~3s** (skippable placements). Organic: the brand can wait.
- **Every on-screen line stays ≥2.5s.** Fast cuts are fine; unreadable text is not.

## 2. Shot grammar (use these words in the board and in prompts)

**Shot size:** extreme wide (EWS), wide (WS), full (FS, head to toe), medium (MS, waist up),
medium close-up (MCU, chest up), close-up (CU, face), extreme close-up (ECU, eyes, hands),
insert (an object or screen), over-the-shoulder (OTS), two-shot, POV.

**Angle:** eye level (default, reads natural), low (power), high (vulnerability), profile,
three-quarter, from behind, top-down.

**Lens (feel):** 24mm (wide, environmental, slight distortion near edges), 35mm (documentary
default), 50mm (natural eye), 85mm (portrait, background melts), macro (inserts).

**Camera move:** static / locked-off, handheld (micro-sway), slow push-in, pull-out, pan,
tilt, whip pan, rack focus, crane up. Moves that generate cleanly: locked-off, handheld,
slow push-in, slow pan. Moves that break: orbits, long dollies through doors, POV that turns
into third person, fast zooms inside the generation (do punch-ins in the edit instead).

**Transitions:** hard cut, J-cut (audio of next shot leads), L-cut (audio of previous trails),
match cut (shape or motion rhymes), whip pan, cut to black, dissolve (rarely, feels dated).

## 3. The storyboard table

One row per screen. The rows add up to the film length.

| Column | What goes in it |
|---|---|
| # / TC in-out / dur | `04 / 0:08.0-0:11.5 / 3.5s` |
| Purpose | What the viewer must understand from this screen, one line |
| Size, angle, lens | `MCU, eye level, 50mm` |
| Camera | `static → slow push-in to CU over 3s` |
| Action | Second by second, eyeline included: `0-1s reads the message, 1-2s exhales, 2-3.5s looks up at her colleague (frame left)` |
| Sound | Dialogue (who, exact words), SFX, music, silence |
| Composited | Every text, caption, UI, logo added in the edit, and where |
| Transition | Into the next screen |
| Source | `i2v from still S03, model X, 720p, 6s, ~180 cr` / `edit only` / `reused take T02` |
| Frame | The generated still for that setup, same locked face |

## 4. Shot variety

Alternate sizes. A wide establishes where we are, a close-up lands the emotion, an insert
shows the detail. Don't cover a whole beat with one static medium shot. A simple pattern that
always works for a 30s story:

```
WS (where) → MCU (who) → insert (what) → CU (reaction) → two-shot (relationship) → CU (payoff)
```

Inside a single long take, variety comes from the action (someone leans in, stands, turns)
and from punch-ins done in the edit (crop 100% → 115% on a beat).

## 5. Budget lines on the board

At the bottom of the board:
- Image count (one per camera setup, no variants) and cost.
- Video takes: model, resolution, seconds, credits each, total.
- Buffer: +30% for reshoots on story films with dialogue, +10% for b-roll.
- Current balance.

Wait for an explicit go. If the plan is large, propose a cheaper variant (480p tiles, fewer
setups, reuse of existing takes) next to it.

## 6. Board delivery

Render it as one HTML page (images + table) and export to PDF/PNG, or a shared doc. The owner
should be able to approve or comment screen by screen on a phone. Keep the board in the
project folder: it becomes the edit decision list.

## 7. Segmenting films longer than one generation

Most models cap a take at 10-15s. Map the film into segments before writing prompts:
- Split at natural seams: a cut, a topic shift, a breath, a gesture reset. Never mid-sentence.
- Each segment's dialogue is a complete thought.
- Each segment ends in a **stable pose** (settled posture, hands placed, eyeline fixed) so its
  last frame can start the next segment.
- At a real cut (new angle), skip the frame handoff: the cut hides the seam, but the
  continuity block (see `prompting.md`) still applies.
