---
name: ai-video-director
description: >
  Direct AI-generated video that looks filmed, not generated: real people in real places,
  believable motion, consistent faces across shots, native dialogue, and a finished edit with
  captions, sound and platform masters. Covers the whole pipeline: brief, shot-by-shot
  storyboard, locked stills, image-to-video takes, review, edit (Remotion or ffmpeg), voice,
  mastering. Model-agnostic: picks the current best model at run time (Runway, Seedance, Veo,
  Kling, etc.). Use whenever a request involves AI video, AI footage, AI actors, a video ad,
  UGC or talking-head clips, a story film with people, b-roll, or a looping hero video.
  Triggers on: AI video, generate a video, runway, seedance, veo, kling, video ad, UGC ad,
  talking head, street interview, story film, b-roll, AI actor, hero loop, storyboard.
---

# AI video director

This skill turns an idea into a finished video whose scenes look shot on a real camera, with
people who move like people. It is the method distilled from a few dozen produced films and
ads (paid social, UGC hosts, story films, product films, website loops) and the corrections
that came out of reviewing every cut.

The core belief: **AI video fails at the edges a real crew handles by reflex.** Continuity,
eyelines, props that stay put, a face that stays the same face, a voice that sounds like a
room. Models are good at pixels. You have to be the director, the script supervisor and the
editor.

## References (load on demand)

| File | Load when |
|---|---|
| `references/storyboard.md` | Planning any film: shot grammar, the storyboard table, beat sheets |
| `references/prompting.md` | Writing any still or video prompt (realism vocabulary, timed beats, style triggers, physics pins, eyelines, chaining) |
| `references/prompt-library.md` | You want a proven prompt to adapt, by shot type |
| `references/models-and-costs.md` | Choosing a model, estimating credits, provider gotchas |
| `references/dialogue-and-voice.md` | Anyone speaks on screen, VO, non-English lines, lip sync |
| `references/review-qa.md` | Reviewing takes before the edit, and QA of the master |
| `references/post-production.md` | Edit, compositing UI and text, captions, levels, encodes, platforms, loops |
| `references/compliance.md` | Any generated person, testimonial, logo, real company or real data |

Helper scripts in `scripts/` (bash + ffmpeg, no other dependencies): contact sheets, last-frame
extraction for chaining, social mastering, seamless loop export.

## The ten rules

1. **Plan on paper, pay on screen.** Nothing goes to a video model before a shot-by-shot
   storyboard exists with one still per camera setup and the person who owns the video has
   approved it. Stills cost cents, video takes cost dollars. A bad still caught at the board
   saves a hundred credits; a bad take caught in the edit wastes them.
2. **Never pay twice.** Before any generation, look for what already exists: recent tasks in
   the provider, clips on disk, task IDs in the project doc. Quote the credit total of the plan
   before the first call. If the fix can happen in the edit, it happens in the edit. Never run
   two sessions on the same shots.
3. **Low resolution by default, high resolution on purpose.** Generate at 480p (or the
   provider's lowest non-draft tier) for b-roll, tiles, PiP and anything below full-bleed.
   Go 720p/1080p for full-bleed faces, dialogue-driven story films and website heroes, after
   one test take. Draft/turbo/preview modes look visibly AI: compare prompts with them, never
   ship them.
4. **Candid documentary, never stock.** The single biggest realism lever. Handheld 35mm,
   natural mixed light, people who are not models, slightly messy sets, nobody posing, nobody
   looking at the lens unless they are a host addressing the viewer. Ban the stock tells:
   headsets on smiling call-center agents, suits in glass offices, perfect teeth, "DREAM BIG"
   neon lofts, symmetrical hero framing.
5. **Long takes beat many clips.** One continuous 8 to 15 second take per story beat reads as
   a story; fifteen 3-second clips read as a montage of stock. Chain takes so the last frame
   of take N is the first frame of take N+1. Cut where a real editor would cut.
6. **Same face, same clothes, same world.** One locked start still per character, reused or
   edited for every shot of that person. Check face, hair, outfit, props and set between every
   pair of shots. Any drift is a reshoot or a cut, never "nobody will notice".
7. **Physics is directed, not hoped for.** Objects stay still unless the prompt makes them
   move, and then say exactly how. Count the people and the hands. Avoid ambitious camera moves
   (orbits, POV turning into third person, long dolly through doors): they produce ghosting,
   duplicated people and costume changes.
8. **Every eyeline has a target in frame.** A speaker whose listener is off-frame turns to the
   lens within a second. Shoot dialogue as two-shots or with the listener's shoulder in the
   foreground, and pin the head direction for the whole take. Eyelines cannot be fixed later.
9. **Text, UI and logos are composited, never generated.** Screens in a scene are turned away
   or carry no readable content; the real UI, captions, titles and logos are added in the edit,
   tracked to the surface when they sit on one. The only in-scene mark that survives generation
   is a large simple wordmark passed as an image reference, on a wall, mug or sticker.
10. **Native voice for on-screen speakers, real-sounding voice for everyone.** A character
    whose mouth moves keeps the voice the video model gave them; dubbing a visible mouth with
    TTS sounds wrong immediately. TTS is for narrators who never appear, and for languages the
    model pronounces badly (then lip-sync it properly, see `dialogue-and-voice.md`). Voices
    should sound like the room they are in, not a studio booth.

## Workflow

### 0. Discover the toolbox (2 minutes, every project)
- Which generation provider is connected (an MCP server such as Runway, or an API key for
  fal / Replicate / a model vendor)? Call its account or `whoami` endpoint: available models,
  deprecations, credit balance.
- Which edit tool is available: Remotion (Node) for anything with UI, captions or motion
  design; ffmpeg alone for straight cuts. Check `ffmpeg -version` and whether it has libass
  (captions) or not.
- Which voice tool: the video model's native audio, ElevenLabs or another TTS, a lip-sync
  model.
- Write what you found at the top of the project doc. Never assume a model from memory.

### 1. Brief
Write `brief.md` in the project folder before spending anything:
- **Goal and placement:** ad (which network), organic social, website, sales asset. Audience.
- **Format:** ratio(s), length(s), language(s), sound-on or silent-first.
- **Beat sheet:** one line per beat with its duration. Hook in the first 2 seconds. For ads,
  the brand seen and heard by ~3 seconds.
- **Who speaks, and as whom:** a host addressing the viewer, characters in a scene, a
  narrator, nobody. This drives model choice and compliance.
- **Compliance check** from `references/compliance.md`.

### 2. Storyboard (the gate)
Follow `references/storyboard.md`. One row per screen: timecode, purpose, shot size, angle,
lens, camera move, action second by second, eyeline, sound, composited elements, transition,
source, credit cost, and **one actual still showing the framing**. Shot variety is the point:
a wide reveal, then a close-up, then an insert. Deliver the board visually (HTML page, PDF or
image grid) and wait for approval. No exceptions for "small" films.

Image budget: one still per camera setup, no variants on the board. Cards, UI inserts and
end cards are rendered as HTML mockups, not generated.

### 3. Pick models per shot
Follow `references/models-and-costs.md`: map each shot's needs (native audio, lip-synced
dialogue, identity across shots, start/end frame, duration, resolution) to capabilities, prefer
the newest model the provider recommends for that need, then the cheapest per second at the
target resolution. Any model you haven't used gets one cheap test take before the plan depends
on it. Put model, resolution, seconds and credits per shot in the brief, and the total.

### 4. Lock the stills
- Generate each character's hero still first with the realism vocabulary from
  `references/prompting.md`. Then build every other setup by **editing** that still (new angle,
  new set, new framing) with the face passed as a reference, so identity is inherited, not
  re-rolled.
- Match the still's size to the target video: a 720px still animated and upscaled never
  becomes sharp. For anything full-bleed, the still is at least 1440px wide.
- Inspect every still: fake film-strip borders or slate text, device bezels around "webcam"
  frames, stray brand logos on cups and laptops, extra fingers, a person in the background
  who shouldn't be there, wrong eyeline. Fix by editing the still. Fixing costs a few cents;
  animating a bad still costs a take.

### 5. Animate
- Default to **image-to-video from the locked still.** Text-to-video only for generic b-roll
  with no identity to hold.
- Write the prompt with the skeleton and timed beats from `references/prompting.md`. Cover
  every second. Pin every prop. Give every eyeline a target.
- Silent b-roll for the edit: audio off. Talking or story shots: native audio on, sound
  described in the prompt. Audio restarts from silence on every take, so any build-up must
  live inside one take.
- Seamless loops: start frame = end frame = the same still, "returns exactly to the starting
  pose", locked-off camera.
- Generations are async. Poll every 60 to 120 seconds. Queues can take hours; never
  re-submit a slow task (you pay twice).

### 6. Review every take
Follow `references/review-qa.md`: contact sheet at 1 fps, face scrub at 4 fps on speaking
takes, listen to every line, transcribe it. Reject for identity drift, extra people or
fingers, moving props, set changes, lens stares, garbled marks, mispronounced words, voice
changes between takes of the same character. Log verdict + task ID for every take so nobody
regenerates a take that was already judged.

### 7. Edit, voice, master
Follow `references/post-production.md`. Remotion when there is UI, captions or motion
design; ffmpeg for a plain cut. Composite all text and UI. Captions burned for silent-first
platforms. Master every deliverable (colour tags, loudness, faststart). Raw renders shift
colour on social platforms and sound quiet in a feed.

### 8. Deliver and log
- Review cut first (1080p or lower, a link the owner can watch on a phone). Final masters
  only after approval.
- Paste every output path. Record in the project doc: task IDs used, credits spent, versions,
  every correction the reviewer made.
- Every correction becomes a rule: add it to this skill (or your fork's taste notes) the same
  day, so the next film doesn't repeat it.

## Formats and their recipes

| Format | Shape | Key choices |
|---|---|---|
| UGC / street host ad, 9:16, 15-25s | 1-2 native-dialogue takes of a host talking to camera, cut with ffmpeg, burned captions | Host addresses the viewer, never a fake customer testimonial. ≤3 words/s. Street ambience bed |
| Story film, 30-60s | 4-6 chained 8-15s takes, two-shots for dialogue, one intentional cut to black at most | 720/1080p, native audio, storyboard approved, continuity block verbatim on every take |
| Feature / product ad, 15s | Person full-bleed on hook and close, product UI composited in the middle, punch-in zooms, word-pop captions | 480p people tiles (upscale for YouTube), UI rebuilt from the real product |
| Narrated product film | No generated people or a few b-roll tiles; real UI animated; TTS narrator | VO line ≤2/3 of its beat slot, music under at -18 dB relative |
| Podcast / yapper clip | Two speakers, multi-shot inside one generation or two-shots | Name the podcast aesthetic, whip pans, zoom punch on punchlines |
| Website hero loop, 5-8s | One locked-off take, start = end frame | ≥1440px still, 720p take, WebM + MP4 under ~400 KB, poster = frame 0 |
| Retargeting / customer film | Real customer logo hand-painted on a wall via image reference, candid team scenes | Written customer approval before launch |

## What "looks real" comes down to (quick checklist)

- [ ] Camera has a body: handheld sway, a lens (24/35/50/85mm), a sensor (35mm film, phone, webcam)
- [ ] Light has a source: window, practical lamp, overcast street, sun through leaves
- [ ] Skin has texture: pores, uneven tone, flyaways, no makeup look
- [ ] Wardrobe is ordinary and specific: "navy hoodie under an unzipped tan canvas jacket"
- [ ] Set is lived in: cups, cables, sticky notes, a plant, people passing out of focus
- [ ] Action is continuous and motivated, with a beginning and an end pose
- [ ] Eyeline goes somewhere in the scene
- [ ] Props behave: still unless told, never crawling, sliding or morphing
- [ ] Sound has a room: room tone, traffic, murmur, mic character
- [ ] Nothing readable was generated: screens turned away, text added in the edit
