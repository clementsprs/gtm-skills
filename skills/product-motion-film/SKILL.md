---
name: product-motion-film
description: Make a premium, on-brand product motion film (Remotion, 16:9, 20-30 s, no voice-over) that shows a product working through a short "conversation, then execution" story, for example "an AI assistant drives your product through its API or MCP server". Use when someone asks for a motion video, product film, launch film, feature video, integration demo or AI-assistant demo that must look professional and match a brand precisely (your brand or a partner brand). Covers reading the brand from the live site and app, the story structure, a readable pace, the motion grammar, a sharp 4K render and the review loop. Not for AI-generated footage with people (use the sibling ai-video-director skill) or for slide decks. Triggers on: motion film, product film, launch video, feature video, integration demo video, MCP demo film, Remotion film, animated product demo.
---

# Premium product motion film

A recipe for 20-30 s product films that look like a brand's own launch video: UI-driven, no people, no voice-over, music and a few sound accents. It was built and refined over several review rounds on a real launch film; every rule below comes from a note that came back in review.

The code side lives in `references/remotion-patterns.md` (project structure, timing helpers, the motion components). The brand-reading procedure is in `references/brand-reading.md`. The brief format is in `references/brief-template.md`.

## Inputs to collect first

1. **The brief**: one row per beat (on-screen copy + what to show). If there is none, write it (step 2 below, template in `references/brief-template.md`) and get it approved before building anything.
2. **The brand's live surfaces**: the marketing page closest to the topic (for example `yourbrand.com/product/<feature>`) and the product app, both open in a browser.
3. **Duration target and formats**: 16:9 by default; 1:1 and 4:5 cuts come only after the 16:9 is approved.
4. **Assets the user brings**: logotype (SVG), icon, any background pattern, partner logos, licensed fonts (`woff2`), avatar images for fictional people (generated or licensed), and a licensed or generated music bed plus a few short SFX (click, pop, whoosh, chime). Ask for them; never pull fonts, logos or music you have no licence for.

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
| Hook | ~4.5 s | Logos pop in one by one and stay; a two-line claim lands word by word (ink line + grey line); then the product line with the real logotype ("<Product> makes it work.") |
| Beats x3-4 | ~4.7 s each | A numbered caption on top ("01 Find relevant people"). Left: the conversation (prompt typed, sent, a tool-call row, a one-line reply). Right: **one** product card showing the result |
| Finale | ~3.5 s | The signature backdrop grows to full frame; a two-line closing line; white logotype; URL in a pill |

- **Conversation first, then execution**: the prompt is typed and sent, the tool call shimmers then ticks, a small packet travels from the chat to the product card, the card builds, then the reply streams in.
- **Lighter beats premium**: one card per beat with 3-4 rows, short prompts (under 60 characters), one-line replies. Cut features before you cut hold time. The approved version was praised as "very premium, precisely in brand, even if lighter in features and content".
- Show real tool or API names, checked against the product's actual tool list or API reference. Never invent one.
- Use fictional people and companies, and say in the brief that UI numbers are illustrative.
- Every number in on-screen copy that is a claim (prices, "24/7", "2.5x") must come from the brief or a named source. Write the source next to it in the brief.

## 3. Pace: readable at first watch

- **4.5-5 s per beat.** 3.2 s was rejected as "too fast, we can't read". Hook lines hold about 1.3 s after their last word lands. The finale holds about 1.5 s after the URL appears.
- Inside a beat (seconds from beat start): type 0-1.1, send 1.15, tool call 1.4, card 1.6, reply 2.2 (streamed at about 8 words/s), card details (variables filling, a highlight, ticks) from +1.1 to +2.9 after the card.
- When the brief's duration and readability conflict, **readability wins**. Say so and offer a cut (drop a beat) rather than speeding up.

The constants are in `references/remotion-patterns.md` ("Timeline").

## 4. Motion grammar

- Words arrive soft and settle sharp: opacity + 16 px rise + a small blur **only while moving**, staggered 0.06-0.1 s. Entrance easing `cubic-bezier(0.16,1,0.3,1)`; moves between states `cubic-bezier(0.65,0,0.35,1)`.
- One continuous slow camera push across the beats (scale 1 to 1.035). No zoom in and out per beat.
- Cards enter with a 50 px rise + scale 0.97 to 1 and leave with a 30 px lift. Never blur large surfaces.
- Chat threads grow from zero height, so a bottom-anchored chat pushes up smoothly instead of jumping.
- Mark the "insight" moment with the assistant's colour, for example a hand-drawn ellipse around the winning row plus a small "Best signal" badge.
- Sound: one music bed (fade in 0.5 s, out 2 s), soft clicks on sends, small pops on the logos, a whoosh on the two big transitions, one chime on the payoff. Keep it calm.

## 5. Quality: razor sharp

- Render **supersampled at 2x** and downscale: a 3840x2160 master (CRF 14, JPEG frames at quality 100, x264 slow), then a Lanczos downscale to 1080p (CRF 14) for review. A plain 1080p render with default JPEG frames looks soft; that was the "a bit blurry" note.
- **No CSS blur on large surfaces**, and no opacity fades on whole windows longer than about 0.35 s (they look washed out over a dark backdrop).
- **No huge `box-shadow` blurs** (more than about 100 px on big elements): Chrome draws rectangular bands. Use layered `radial-gradient`s for glows and horizons.
- Fonts are local `woff2` files loaded with `@font-face` and a bounded wait. Never fetch them from a web font service at render time. For a serif "assistant voice", any licensed text serif works.
- SVG logos with `fill="currentColor"` render black inside `<Img>`; rewrite the fill to a real colour.

## 6. Build steps

1. Scaffold a Remotion project (`npx create-video@latest`, blank template) or reuse one you already have. Structure and scripts are in `references/remotion-patterns.md`.
2. Fill `theme.ts` with the brand values from step 1, and put the user's assets in `public/` (logotype, icon, pattern, partner logos, avatars, fonts, audio).
3. Create `src/<Film>.tsx` and register it in `Root.tsx`. Write, in order: the timeline constants (hook swap, panel rise, beat starts, end), the hook copy, then the data arrays `CAPTIONS`, `PROMPTS`, `TOOLS`, `REPLIES`, then one card component per beat.
4. Check stills at each beat before any full render: `npx remotion still src/index.ts Film out/s.png --frame=<sec x 60> --scale=0.5`. Look for overlaps, text wrapping, elements cut at the panel edge, and the camera push pushing things out of frame.
5. Render the master + review, pull a 6-frame contact sheet with ffmpeg (`select` + `tile=2x3`), and zoom on one card crop to confirm sharpness.
6. Send the **1080p review** first. Make the 4K and social cuts only after approval.

## Done when

- Every caption, prompt, reply and card row can be read on a first watch at normal speed.
- Colours, type and the signature visual match the brand's live page side by side.
- A crop of a card at 1080p shows crisp text, and the backdrop has no banding.
- The brief notes the source of every claim and flags illustrative UI numbers.
- Every font, logo, image and audio file in `public/` is owned, licensed or generated, and you can say which.

## Related

- `ai-video-director`: AI-generated footage with people (actors, street interviews, brand films). Use it when the film needs humans on screen; this skill stays UI-only.
