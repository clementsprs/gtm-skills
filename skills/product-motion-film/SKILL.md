---
name: product-motion-film
description: Make a premium, on-brand, dynamic product motion film (Remotion, 16:9, about 40 s, no voice-over) told as ONE continuous conversation with an AI that drives the product, for example "any AI uses your product through its MCP server or API". Use when someone asks for a motion video, product film, launch film, feature video, integration demo, MCP demo or AI-assistant demo that must look professional, match a brand precisely and read on mobile. Covers reading the brand from the live site and app, the conversation structure, the copy, the product cards, the motion grammar, music, a sharp 4K render and the review loop. Not for AI-generated footage with people (use the sibling ai-video-director skill) or for slide decks. Triggers on: motion film, product film, launch video, feature video, integration demo video, MCP demo film, Remotion film, animated product demo.
---

# Premium product motion film

A recipe for ~40 s product films that look like a brand's own launch video and feel alive: UI-driven, no people, no voice-over, music and a few sound accents. It was refined over about fifteen review rounds on a real launch film, including the partner brand's own content review; every rule below started as a note that came back in review.

Code patterns: `references/remotion-patterns.md`. Brand reading: `references/brand-reading.md`. Brief format: `references/brief-template.md`.

## Inputs to collect first

1. **The brief**: one row per capability (what the user asks, what the product does, what the AI answers). If there is none, write it (`references/brief-template.md`) and get it approved before building.
2. **The brand's live surfaces**: the marketing page closest to the topic and the product app, open in a browser.
3. **Assets the user brings**: logotype (SVG), icon, background pattern, partner and channel logos (real files), licensed `woff2` fonts, avatars for fictional people (generated or licensed), and music: ask whether they have a track they like before generating one.
4. **Formats**: 16:9 first; 1:1 and 4:5 cuts only after the 16:9 is approved.

If you can't open a browser, say so and ask for screenshots. Never guess a brand's colours or type from memory.

## 1. Read the brand from the live site and app

Pull the real values with a small script in the page (`getComputedStyle` on the H1, body, primary button, a card; see `references/brand-reading.md`): heading font / weight / tracking, ink and secondary greys, accent, card radius and hairlines, the background treatment, the signature visual (for example a night-sky backdrop), and the logotype SVG. Write every value into one `theme.ts` with where and when it was read; no colour literal anywhere else.

A version built on a generic motion kit was rejected as "not premium, not in brand": build on the brand's own live system.

## 2. Structure: one continuous conversation

| Part | Length | Content |
|---|---|---|
| Hook | ~5 s | The AIs it works with as **full logos with names**, switching in one chip and ending on all their icons together; a short two-line claim (ink + grey); the product logotype slams in ("<Product> makes it work.") |
| Conversation ×4 | ~7-10 s each | The prompt rises in and types itself big in the middle → sent, slides right → status line ("Searching <product>…" + the real tool name, dots → ✓) → **the product card appears inside the thread and plays out completely** → the AI's reply streams in a message bubble |
| Finale | ~3.2 s | The brand's dark backdrop rises full frame (the only dark moment); "The full power of [logo], now in your AI."; plain URL |

- **No interstitials, no title cards, no captions at the top.** One discussion shows the capabilities. **Each new prompt is the transition**: the thread scrolls, and the new message rising in pushes the previous exchange up. Inside a step the camera goes prompt → product card → reply.
- **One thing in focus at a time.** No split screen with the chat on one side and the product on the other ("too much info on the screen").
- **Light ground throughout.** The product's results live in the conversation as cards; a dark panel rising mid-film felt like a jarring cut. Dark is for the end card.
- **AI-neutral when the product works with any AI** (an MCP server, a public API): no single assistant's logo, typeface or colour in the chat. Header = a "<Product> MCP" chip + "works with" + the AI icons; replies in the product's body font with a product-colour tail on the words still arriving.
- **The AI talks in message bubbles** (white, left, opposite the user's grey bubble). Bare reply text reads as a caption, "not part of the conversation". No avatar needed.
- **Finish the execution before the reply**: the reply starts only when the card is done. Step length = typing + status + the card's own execution time + the reply.
- **Mobile sizes**: prompt ~62 px, status ~44 px, reply ~58 px on a 1920 × 1080 canvas; product cards scaled ~1.2-1.4× (per card, so the tallest still clears the header).

- **Agent-led variant** (the product IS the AI agent): same grammar with roles flipped. The agent writes first (white bubbles, its mark + wordmark in the header), the user decides (grey bubbles, a voice note with a live waveform and transcript). **Show the device, don't write it**: a phone moment opens on a lock screen with the agent's push notification that drops in, then a tap and the banner expands to the full frame like an app opening, and the conversation is inside it; the app icon is the agent's face on a white tile. **The device shows in the width**: phone moments sit inside a phone frame (narrow column, the notification opens into it), laptop moments use the full width; the frame springs open between them and **the whole history reflows** to the new width (lay the thread out twice, phone and laptop, and blend positions and sizes with the frame), so the conversation never disappears. Name the device once ("On your laptop"), later dividers show only the time. Never cut the proof scene (a customer story, a reference) just to hit a length: it came back on request. In an agent-led film the agent's small mark sits beside each of its messages (unlike AI-neutral MCP films). A day across devices becomes a header context chip that flips ("On your phone · 8:42 AM" → "On your laptop") plus time dividers in the thread, never device frames. Build it as an item list (agent / user / voice / card / divider, each with a reading duration) and compute starts, layout and the scroll camera from it.

- **Proactive-agent variant (preferred for external)**: when the point is that the agent works for you, don't show a chat at all. The agent PUSHES (a header line in its voice + a card) and the user only taps **Accept** or **Skip** (press + ripple, then an "Accepted" chip; per-row Skip / Accept when the agent pushes a list). A user typing instructions ("cut the intro and send it") reads as a plain LLM chat. Open external cuts with energy: a storm of real-app notifications piling up and shaking, flung away, then "Too many threads." and the agent's mark slamming in.

## 3. Copy

- **Prompts sound like one person continuing a conversation**: continuity comes from references to what came before ("for them", "these signals", "run this"), with at most one light reaction. Never a praise word on every prompt.
- **Specific and carrying the value**, with one shared vocabulary across steps (for example "buying intent signals" in every prompt).
- **Few numbers**: none in the hook (no price); numbers live inside the cards. Claim numbers have a source in the brief; UI numbers are flagged illustrative; people and companies are fictional.
- **Real tool or API names** on the status line, checked against the product's actual tool list. Never invent one.
- **Logos replace names**: the logotype inside the closing line; a logotype + word lockup keeps its word space. No arrow or button on a URL: nothing is clickable in a video.

## 4. Product cards: show what the AI actually did

- One card per step, 3-4 rows, the product's full logotype in the header.
- **Qualitative, AI-era output, not plumbing**: no `{{firstName}}` merge tags ("not qualitative enough for the AI era"). Show a real message written live for one record, the phrase drawn from its data highlighted with a marker sweep, and a one-line angle.
- **Workflows are flows with conditional branches** (step with its actual words → "Wait 3 days" → "Not opened" → email / "Opened, no reply" → voice message with a live waveform), not a row of day icons. The card grows downward as the flow draws: never an empty block.
- **Real channel logos** (LinkedIn, Gmail…) make it authentic.
- **Status lists are modern run logs**: thin rail that fills, dots pending → spinning ring → filled check in the brand colour, a result line per step, a small duration. Boxed icon squares with green checks read "old school".
- **A state change is its own moment**: a toggle waits for the card to land, then the track fades in, the knob squashes, a pulse ring spreads, an "Active" label pops, and only then does the run start.
- **Cut UI that doesn't belong to the action shown** (a team-chat recap card on a scheduling step "doesn't make sense").

## 5. Motion grammar: dynamic in the elements, readable in the holds

The bar: playful launch films where every element has physics (a public example: Allo's "We decided to give Grok Bot a phone", Oct 2026; no mascot needed) and AI assistants' own launch films (frameless conversation, big type).

- **Springs, not eases** for everything that arrives (`spring()` with overshoot; presets and a damped `kick()` in the patterns file).
- **Words spring up** with a slight tilt and **push each other** as a line builds; old lines are thrown away, never just faded. The logotype slams in and the line shakes once.
- **Thread camera**: lay the thread out from text-length estimates and scroll it with soft springs between focus points (new prompt centred → card centred → reply in view), small punches on send and card landing. The header sits on a white fade so scrolled content slides under it.
- **Cards land with a spring** (slight tilt, a small bump when the tool call lands); rows slide in, tags and ticks pop, bars overshoot, previews flip.
- **Holds stay long, motion gets fast**: 3.2 s steps were "too fast, we can't read". Dynamism comes from snappy entrances (0.3-0.6 s), never from shorter holds. Reply at ~9 words/s, ~1 s before the next prompt. When duration and readability conflict, readability wins: offer to drop a step.
- No hard cuts, no whole-frame crossfades: one continuous space.

## 6. Music and sound

- **Feel-good, bouncy, modern**: ~115-122 bpm, crisp snappy drums without a club kick, bouncy bass, plucks / guitar / marimba, claps and snaps. Rejected in review: a calm piano bed ("more dynamic"), four-on-the-floor electro-pop ("too nightclub"), anything retro ("not old school").
- **A picked track that's too short** (stock grooves are often ~25 s): repeat whole 4-bar blocks of its full section on bar boundaries, start it after its intro so the film opens at full energy, keep its real ending on the last frame. Never time-stretch a picked track. Recipe in the patterns file ("Sound").
- **Generating one**: request the film's exact length and check loudness per second before building on it; models ignore prompted structure (one take sat quiet for 15 s before its drop). A prompt that worked is in the patterns file.
- SFX only with a visible cause (pops on logo switches and card landings, clicks on sends, soft whooshes as prompts rise in and on the finale, a chime when the last step ticks). Mix to about -14 LUFS.

## 7. Quality: razor sharp

- Master **supersampled 2x** (`--scale=2`, CRF 14, JPEG 100, x264 slow); review rounds can use a straight 1080p render.
- No CSS blur on large surfaces; no huge `box-shadow` blurs (Chrome bands them, use radial gradients); local `woff2` fonts with a bounded wait; SVGs with `fill="currentColor"` render black inside `<Img>`, rewrite the fill.
- Picture-only change: render once `--muted`, render each audio mix as WAV and mux. Audio-only change: re-mux onto the existing picture.

## 8. Build and review loop

1. Scaffold a Remotion project (structure in the patterns file), fill `theme.ts`, put the user's assets in `public/`.
2. Write the film in this order: logo list + hook copy, `PROMPTS`, `TOOLS`, `STATUSES`, `REPLIES`, one card component per step with its height and scale, then the timeline constants (starts and duration are computed), then the music offset.
3. Stills at every step before any full render (`npx remotion still … --frame=<sec × 60> --scale=0.5`), as a contact sheet: overlaps, wrapping, cards under the header, empty blocks, leftover single-assistant branding.
4. Send the 1080p review first; 4K and social cuts only after approval. Write every correction back into this skill the same day.

**Card heights are measured, not guessed**: the thread layout reserves each card's height, and an underestimate makes the next message slide under the card (a recap card reserved at 452 px rendered at ~530 and overlapped). Sum the real parts (header + body padding + rows × row height), then check a still of every card's final state against the item after it before the full render.

## Done when

- It reads as one conversation with an AI, one thing in focus at a time, every line readable on a phone at first watch.
- Each step finishes in the product before the AI answers; every product card shows real, qualitative output with real channel logos.
- Nothing arrives or leaves without motion; nothing dark before the end card.
- Colours, type and logos match the brand's live page; a 1080p crop is crisp; the music opens at full energy and ends on the last frame.
- Every font, logo, image and audio file is owned, licensed or generated, and you can say which.

## Rejected in review (don't repeat)

Generic motion kit · 3.2 s steps · calm piano bed · four-on-the-floor club beat · split-screen chat + product · captions pinned at the top · full-frame interstitial title cards · a dark panel mid-film · one assistant's branding in a works-with-any-AI film · merge tags · a row of day icons for a workflow · boxed icons + green checks · bare reply text · an AI avatar · a praise word on every prompt · off-topic UI · a glued logotype + word · a price in the hook · an arrow on a URL.

## Related

- `ai-video-director`: AI-generated footage with people. Use it when the film needs humans on screen; this skill stays UI-only.
