# Prompting for real scenes and motion

Two kinds of prompts: **stills** (lock the look, the face, the set) and **takes** (direct
motion and sound over a still). Write stills like a photo caption from a documentary; write
takes like a shot list for an actor.

## 1. Realism vocabulary for stills

Stack these. They are what moves an image from "AI render" to "frame grab".

- **Source framing:** "unretouched frame grab from...", "candid documentary footage",
  "raw phone footage", "laptop webcam view", "35mm film still from an indie documentary".
- **Camera body and lens:** "filmed handheld on a Sony FX3", "shot on 35mm film", "50mm",
  "smartphone front camera", "slight sensor noise", "soft film grain".
- **People:** an age, a job, an ordinary look. "Not a model, not posed, not glamorous."
  Imperfections: "visible pores", "uneven skin tone", "faint under-eye shadows", "flyaway
  strands", "a small mole", "slightly chapped lips", "light stubble", "no makeup look".
- **Wardrobe, specific and ordinary:** "navy hoodie under an unzipped tan canvas jacket",
  "grey crewneck, wired earphones". Specific beats generic.
- **Set, lived in:** "coffee cup and sticky notes", "acoustic felt panels", "cluttered side
  table", "coworkers passing out of focus behind the glass".
- **Light with a source:** "late-afternoon window light", "flat overcast daylight", "warm
  practical lamp", "direct sun through leaves". Name it, don't say "beautiful lighting".
- **Grade:** "documentary color grading", "muted realistic colours".
- **Always close with:** "No text, no logos." (plus "no readable screen content" when a
  screen is in frame).

Mood note: for paid social, sunny and pleasant (terraces, plants, sunlit streets, people
around 30) outperforms grey and moody. For story films, the light follows the story.

### Stills for identity

1. Generate the **hero still** of each character: MCU, eye level, neutral but alive
   expression, clear face, the outfit they'll wear for the whole film.
2. Every other setup = an **edit** of a still, with the hero still passed as a reference:
   "Same woman, same face, same outfit, now seen from over her colleague's shoulder at her
   desk...". A full reference still dictates framing (the model copies it); a face crop
   carries identity but loses props. Pick deliberately.
3. To place a person into a new set, composite first (image model with the set and the face
   as tagged references), check for duplicated props, then animate.
4. After any edit that adds text (name badge, sticker), check every other person in the
   frame: the edit often stamps the text on them too.

### Logos inside a scene

Only large, simple wordmarks survive. Pass the logo PNG as a tagged reference (e.g. `@logo`)
and place it where a real company would: "hand-painted large on the raw concrete wall,
slightly imperfect, partly hidden behind people", a laptop sticker, a neon sign, a mug. Never
on a phone or tablet screen (garbles at that size). In the take prompt, hold it: "the wall
logo stays perfectly static".

## 2. Take prompt skeleton (keep this order)

Early text weighs more. References and format first, style and timeline last.

```
[References: what each attached image/audio is]
[Format: ratio, duration, ONE continuous take or N shots, camera behaviour]
[Who does what, as one continuous action]
[What stays still]
[Eyeline]
[Light + texture, only if the still doesn't carry it]
[3-5 named style triggers]
Dialogue: "..."            (if anyone speaks)
[Timed beats covering every second]
Sound: [diegetic sounds in event order]. [Music decision.] Clean frame, no text overlays.
Total: Xs / 1 take / ratio
```

Keep it under ~2,000 characters; past that, instruction-following degrades. Don't describe
in words what the start still already shows; spend the characters on action.

## 3. Timed beats (the highest-leverage technique)

Unaccounted seconds get improvised, usually badly. For any shot with a person:

```
0:00-0:02 | Hook: leans toward camera, right hand lifts palm-up on the first word.
0:02-0:05 | Settles back, animated small gestures, glances at her notes.
0:05-0:08 | Looks up at the man across the table (frame left), raises an eyebrow.
0:08-0:10 | Landing: small nod, half-smile, like it should be obvious. Does NOT stand up.
```

- 2-4s per beat, no gaps, every second covered.
- Name the hand (left/right), eyeline, posture and expression in the same beat.
- Give each move a full arc: start position → movement → end position.
- Anchor gestures to specific words of the dialogue.
- Direct intent with comparisons: "shrugs like it should be obvious", "reads it twice like
  she can't believe it".
- One targeted "does NOT ..." to kill the predictable wrong action (opens the laptop, walks
  out, looks at camera).
- Be surgical on the first and last 2-3 seconds (hook and end pose). The middle can stay
  looser when you want the model to interpret.
- The last beat is a **stable end pose** if the take will be chained.

## 4. Physics pins

Models move what you mention. Mention stillness explicitly.

- "The phone lies flat on the desk and stays completely STILL; it does not slide, rotate or
  flip; the only thing that changes is its screen lighting up." (Avoid "vibrates hard": the
  model will make it crawl.)
- "Exactly one person in frame; nobody else enters." / "Exactly two people at the table."
- "Detailed hands, five fingers each, anatomically correct."
- "Background stays still" for locked-off shots; "coworkers pass out of focus" when you want
  life behind.
- "No cuts, no jumps, a single scene, not a montage" for one-take shots.
- Keep hand-prop choreography simple. Pouring, typing on a visible keyboard, handing objects
  between people: morph risk. Move complex hand work off-frame or into an insert.

Positive framing works better than lists of fears, with one exception: if skin looks
plasticky or game-engine, add "no 3D, no cartoon, no VFX" together with film grain / 35mm.

| Instead of | Write |
|---|---|
| no distorted hands | detailed hands, anatomically correct |
| no stiff movement | natural fluid motion, physically accurate |
| no blur | sharp focus, high detail texture |
| no captions / watermarks | clean frame, no text overlays |

## 5. Eyelines (the thing that breaks dialogue scenes)

- A speaker with no listener in frame turns to the lens within a second, whatever you write.
- Give every eyeline an **in-frame target**: two-shot, or the listener's shoulder and the
  back of their head soft in the foreground.
- Pin the head for the whole take, not just the eyes: "for the ENTIRE take his head stays
  turned three-quarters toward frame LEFT, nose pointing at her, exactly like the first frame".
- Verify the eyeline on the start still before animating. Video edits that try to redirect
  eyes afterwards produce strabismus.
- Hosts and UGC talking heads are the exception: they look at the lens on purpose. B-roll and
  story shots never do.

## 6. Style triggers (stack 3 to 5)

Models pattern-match named aesthetics far better than adjectives. One is not enough, six is
mud.

- **Formats:** UGC talking head, street interview, podcast clip, storytime, day-in-the-life
  vlog, reaction, tutorial, mockumentary confessional.
- **Look:** photorealistic, 35mm film, film grain, raw phone footage, ARRI ALEXA aesthetic,
  candid documentary, golden hour.
- **Camera:** handheld, static locked-off, tight close-up, over-the-shoulder, selfie angle,
  slow push-in.
- **Editing (for multi-shot generations):** snap cut, jump cut, whip pan between speakers,
  zoom punch on punchlines, hard cut to black.
- **Energy:** deadpan comedy, highly engaging, wise mentor, hype man, confessional.
- **Real-world anchors:** "National Geographic documentary", "Apple keynote style", "late-night
  podcast studio feel". Naming a real production aesthetic is one of the most reliable
  consistency levers (name an aesthetic, never imitate a real person).

A safe default stack for B2B / everyday-people UGC: *UGC talking head, raw phone footage,
candid documentary, 35mm film grain, talking to camera like a colleague.*

## 7. Multi-shot inside one generation

Some models (Seedance-class) can cut a montage inside one 10-15s generation. Declare it:

```
Montage, multi-shot, don't use one camera angle, photorealistic, 35mm film, grain.
[2-4 sentence summary: who, where, what arc]
Shot 1: [framing + action + camera]
Shot 2: ...
Total: 15s / 5 shots / 16:9
```

- 2-4s per shot, 6 shots in 15s is the ceiling. One setup and one action per shot.
- Repeat the identifying details in every shot line ("the woman in the rust sweater").
- Use for hype openers and montages. Story beats stay on long takes.

## 8. Continuity block (for chained takes)

Paste it **verbatim** at the top of every take of the same scene. Paraphrasing between takes
is the number one cause of drift.

```
CONTINUITY: Maya, early 30s, short dark curly hair, rust crewneck sweater, small gold hoops.
Set: small startup meeting room, whiteboard with faint marker, window light from frame right.
Style: candid documentary, handheld 35mm, film grain, natural colour.
Format: 16:9, one continuous take, no cuts.
```

Plus: the last frame of take N as the start frame of take N+1 (`scripts/last-frame.sh`), the
same sound line on every take so room tone doesn't jump, and the same voice reference if the
model accepts one.

## 9. Iterating without burning credits

1. Skeleton first: references, format, dialogue, hook beat, end beat. See what the model does
   with the middle.
2. Change one variable per iteration.
3. A shot that keeps misfiring: freeze the camera, one action, empty background, rebuild up.
4. Re-roll before re-writing: same prompt, new seed, once or twice (quote the cost).
5. Bank every accepted prompt verbatim in your prompt library.

## 10. Failure modes

| Symptom | Likely cause | Fix |
|---|---|---|
| Face drifts mid-clip or between clips | identity only in prose | locked still / face reference; continuity block verbatim |
| Plasticky skin | style stack too clean | "no 3D, no cartoon, no VFX" + film grain, 35mm |
| Stock-footage feel | adjectives instead of triggers, posed cast | named triggers, ordinary wardrobe, "not a model, not posed" |
| Lip-sync drift, dropped words | too many words for the duration | ≤3 words/s, key phrase early in the line |
| Dead or chaotic middle | gaps in the timeline | beats covering every second |
| Wrong action (opens, pours, leaves) | ambiguous prop or intent | one "does NOT ..." line |
| Prop crawls / slides / morphs | verb implied motion | explicit stillness pin |
| Speaker stares into the lens | no in-frame eyeline target | two-shot or OTS, head pinned |
| Ghosting, duplicate people | ambitious camera move | locked-off or slow push-in; do moves in the edit |
| Half the prompt ignored | >2,000 chars, key info buried | compress, move critical info up |
| Gibberish text on screens or signs | text was generated | screens turned away, composite in post |
| Fake film-strip border, slate text | "cinematic film still" phrasing | outpaint it away by editing the still |
| Laptop bezel around a "webcam" frame | "webcam view" phrasing | crop, or "full-frame feed, no device" |
| Silent take invents gibberish speech | sound prompt mentions "voices" | audio off for no-dialogue takes |
