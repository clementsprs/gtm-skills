---
name: product-motion-film
description: Make a premium, on-brand, dynamic product motion film (Remotion, 16:9, 30-40 s, no voice-over) that shows a product working through a short "conversation, then execution" story, for example "an AI assistant drives your product through its API or MCP server". Use when someone asks for a motion video, product film, launch film, feature video, integration demo or AI-assistant demo that must look professional and match a brand precisely (your brand or a partner brand). Covers reading the brand from the live site and app, the story structure, a readable pace, the motion grammar, a sharp 4K render and the review loop. Not for AI-generated footage with people (use the sibling ai-video-director skill) or for slide decks. Triggers on: motion film, product film, launch video, feature video, integration demo video, MCP demo film, Remotion film, animated product demo.
---

# Premium product motion film

A recipe for 30-40 s product films that look like a brand's own launch video: UI-driven, no people, no voice-over, energetic music and a few sound accents. It was built and refined over five review rounds on a real launch film (including the partner brand's own content review); every rule below comes from a note that came back in review.

The code side lives in `references/remotion-patterns.md` (project structure, timing helpers, the motion components). The brand-reading procedure is in `references/brand-reading.md`. The brief format is in `references/brief-template.md`.

## Inputs to collect first

1. **The brief**: one row per beat (on-screen copy + what to show). If there is none, write it (step 2 below, template in `references/brief-template.md`) and get it approved before building anything.
2. **The brand's live surfaces**: the marketing page closest to the topic (for example `yourbrand.com/product/<feature>`) and the product app, both open in a browser.
3. **Duration target and formats**: 16:9 by default; 1:1 and 4:5 cuts come only after the 16:9 is approved.
4. **Assets the user brings**: logotype (SVG), icon, any background pattern, partner logos **with their wordmarks** (icon + name), licensed fonts (`woff2`), avatar images for fictional people (generated or licensed), and a licensed or generated music bed plus a few short SFX (click, pop, whoosh, chime). Ask for them; never pull fonts, logos or music you have no licence for.

If you can't open a browser, say so and ask for screenshots of the page and the app. Never guess a brand's colours or type from memory.

## 1. Read the brand from the live site and app (not from memory)

Open the page and the app and pull the real values with a small script in the page (`getComputedStyle` on the H1, body text, primary button, a card). The script and the full checklist are in `references/brand-reading.md`. You want:

- heading font, weight, letter-spacing, ink colour
- secondary text colour (site grey and app grey are often different)
- accent colour and button style, card radius, border or hairline colour
- the page's **signature visual** (for example a product window in a glass bezel on a night-sky panel, or a gradient horizon) and its **background treatment** (for example a white ground with a faint line pattern and thin frame rules)
- the logotype file (download the SVG the site serves) and any background pattern asset

Write every value into one `theme.ts` with a comment saying where and when it was read. **No colour literal anywhere else in the code.** Third-party UI shown in the film (an AI assistant's chat window, a team-chat app, a CRM) gets its own token group, transcribed from that product's public look.

Rule from review: *a film for a brand is built on that brand's live marketing system, not on a generic motion kit.* A first version built on a generic kit was rejected as "not premium, not in brand".

## 2. Story structure (the shape that works)

| Part | Length | Content |
|---|---|---|
| Hook | ~5 s | The tools involved as **full logos with names** (icon + wordmark), switching one into the next in a single slot and ending on the one the film uses; a short two-line claim (ink line + grey line); then the product line with the real logotype slamming in ("<Product> makes it work.") |
| Beats x3-4 | ~6-7.5 s each | A numbered caption on top ("01 Find relevant people"). Inside each beat: **chat** (prompt typed, sent, a tool-call row) → **the product executes to the end** (one card, camera on it) → **back to chat** (the reply streams in) |
| Finale | ~3.6 s | The signature backdrop grows to full frame; "The full power of [logo], now in your AI." with the logo inline instead of the written name; a plain URL pill |

- **Finish the execution in the product before returning to the chat.** The reply starts only once the card is done (counter landed, variables filled, highlight drawn, ticks in). Showing reply and card at once reads as abrupt back-and-forth and viewers lose the workflow. So beat length = typing + tool call + that card's execution time + the reply.
- **Every tool recognisable at a glance**: full logos with names in the hook (icons alone are not identified by everyone), the product's full logotype in each product card header, the assistant's mark + wordmark in the chat window's title bar.
- **Lighter beats premium**: one card per beat with 3-4 rows, one-line replies. Cut features before you cut hold time. An approved version was praised as "very premium, precisely in brand, even if lighter in features and content".
- **Prompts sound like a real user and carry the value**: specific, natural, and sharing one vocabulary across beats so the film reads as one thread (for example "Which buying intent signals matter most for my ICP? Find me leads matching those signals." → "Prepare a multichannel campaign personalized to each lead's buying intent signal." → "Which buying intent signals perform best?"). Long prompts are fine; the composer shows the tail while typing and the sent bubble wraps.
- **Few numbers in the copy.** Each number is one more thing to digest: keep prices and figures out of the hook ("Your new sales intern, working 24/7.", not "your $100/month sales intern"); let the numbers live inside the product cards.
- Show real tool or API names, checked against the product's actual tool list or API reference. Never invent one.
- Use fictional people and companies, and say in the brief that UI numbers are illustrative. Every claim number must come from the brief or a named source.
- **No arrow or button on the URL** in the finale: nothing is clickable in a video.

## 3. Pace: readable at first watch, dynamic in motion

- **Holds stay long; motion gets fast.** 3.2 s beats were rejected as "too fast, we can't read"; the next round asked for "more dynamic". The fix for dynamism is never shorter holds: entrances and exits become snappy springs (0.3-0.6 s) while every line of text holds as long as before.
- Inside a beat (seconds from beat start): type 0-1.45, send 1.45, tool call 1.7, card 1.9, card execution 2-4 s (set per card), reply streamed at about 9 words/s, then ~0.9 s before the next prompt. Compute the beat starts from these instead of a fixed beat length (`references/remotion-patterns.md`, "Timeline").
- When the brief's duration and readability conflict, **readability wins**. Say so and offer a cut (drop a beat) rather than speeding up.

## 4. Motion grammar: dynamic and physical

The bar was set by playful launch films where every element has physics (a good public example: Allo's "We decided to give Grok Bot a phone", Oct 2026). Take the element motion, not the mascot: the brief was "not necessarily a mascot, but dynamism in the elements displayed".

- **Springs, not eases**, for everything that arrives: Remotion `spring()` with a little overshoot (presets in `references/remotion-patterns.md`), plus a damped `kick()` for bumps and punches.
- **Words spring up** from below with a slight tilt (no blur) and **push each other**: each word's width grows from 0 as it lands, so the sentence builds and re-centres live. Old lines are **thrown up and away** word by word, never just faded.
- **Objects sit inside the sentence**: the logotype slams in big (scale ~2.2 → 1) and the line shakes once on impact; a logo slot springs between widths as brands switch, the old logo gone before the new one lands (no overlap).
- **Cards are thrown in and out**: in from bottom-right with a ~7° tilt and overshoot, out up-left with a spin; a small bump (+3 %) when the tool call's packet lands. Inside: rows slide in one by one, tags and ticks pop with a twist, bars overshoot their value, toggles snap with a squashy knob, a preview flips (rotateX) from one record to the next.
- **The camera follows the action** with soft springs between keyframes: the composer while typing, the product card while it executes, the payoff (for example a team-chat recap), the chat for the reply, wide for the finale. Max zoom about 1.07, plus small punches on send, card landing, the insight and the payoff. Captions and the ground sit outside the camera.
- Chat messages pop like messages: the user bubble from bottom-right, assistant rows from the left, inside a bottom-anchored thread.
- Mark the "insight" moment in the assistant's colour (hand-drawn ellipse + a badge that springs in).
- No whole-frame crossfades or hard cuts: one continuous space.

## 4b. Music and sound

- **Energetic from the first bar**: punchy drums, bouncy bass, a bright pluck hook, fills every 4 bars, ~128 bpm. A calm felt-piano bed was rejected ("the music should be more dynamic"); lounge, house and lo-fi don't fit either. A prompt that worked is in `references/remotion-patterns.md` ("Sound").
- **Check a generated track before using it**: print loudness per second. A first generation ignored its prompted structure and sat flat and quiet for 15 s before the drop; regenerating with "full energy from the very first second, no intro" fixed it.
- **Offset the bed** so the track's own ending lands on the end card, and look for a break that can fall on a section change.
- SFX only with a visible cause: pops on logo switches and card landings, clicks on sends, whooshes on the big moves (logo slam, panel rise, finale), one chime on the payoff.

## 5. Quality: razor sharp

- Render **supersampled at 2x** and downscale: a 3840x2160 master (CRF 14, JPEG frames at quality 100, x264 slow), then a Lanczos downscale to 1080p (CRF 14) for review. A plain 1080p render with default JPEG frames looks soft; that was the "a bit blurry" note.
- **No CSS blur on large surfaces**, and no opacity fades on whole windows longer than about 0.35 s (they look washed out over a dark backdrop).
- **No huge `box-shadow` blurs** (more than about 100 px on big elements): Chrome draws rectangular bands. Use layered `radial-gradient`s for glows and horizons.
- Fonts are local `woff2` files loaded with `@font-face` and a bounded wait. Never fetch them from a web font service at render time. For a serif "assistant voice", any licensed text serif works.
- SVG logos with `fill="currentColor"` render black inside `<Img>`; rewrite the fill to a real colour.

## 6. Build steps

1. Scaffold a Remotion project (`npx create-video@latest`, blank template) or reuse one you already have. Structure and scripts are in `references/remotion-patterns.md`.
2. Fill `theme.ts` with the brand values from step 1, and put the user's assets in `public/` (logotype, icon, pattern, partner logos, avatars, fonts, audio).
3. Create `src/<Film>.tsx` and register it in `Root.tsx`. Write, in order: the timeline constants (hook swap, panel rise, typing time, per-card execution times, reply lengths; beat starts and duration are computed), the logo list and hook copy, the data arrays `CAPTIONS`, `PROMPTS`, `TOOLS`, `REPLIES`, one card component per beat, then the camera keyframes and the sound offsets.
4. Check stills at each beat before any full render: `npx remotion still src/index.ts Film out/s.png --frame=<sec x 60> --scale=0.5`. Look for overlaps, text wrapping, elements cut at the panel edge, and the camera push pushing things out of frame.
5. Render the master + review, pull a 6-frame contact sheet with ffmpeg (`select` + `tile=2x3`), and zoom on one card crop to confirm sharpness.
6. Send the **1080p review** first. Make the 4K and social cuts only after approval.

## Done when

- Every caption, prompt, reply and card row can be read on a first watch at normal speed, and nothing arrives or leaves without motion.
- Each beat finishes in the product before the chat answers, and every tool on screen is identifiable by its logo.
- Colours, type and the signature visual match the brand's live page side by side.
- A crop of a card at 1080p shows crisp text, and the backdrop has no banding.
- The brief notes the source of every claim and flags illustrative UI numbers.
- Every font, logo, image and audio file in `public/` is owned, licensed or generated, and you can say which.

## Related

- `ai-video-director`: AI-generated footage with people (actors, street interviews, brand films). Use it when the film needs humans on screen; this skill stays UI-only.
