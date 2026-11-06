# Choosing models, costs, provider gotchas

## Never hardcode a model

Video models ship and retire every few weeks. A skill that names "the best model" is wrong
within a month. Pick at run time:

1. Ask the provider what exists now: account / `whoami` endpoint (available video and image
   models, deprecations, balance). On an MCP server, read the generation tool descriptions too:
   providers often embed their current picking heuristic and capability table there.
2. Map each shot's needs to capabilities (table below).
3. Among models that cover the needs, prefer the **newest generation** the provider recommends
   for that need, then the **cheapest per second at the target resolution**. An older model is
   not automatically cheaper.
4. A model you haven't used gets **one cheap test take** before a plan depends on it. Log the
   result (date, model, shot type, verdict, cost) in the test log at the bottom of this file.
5. Write the chosen model, resolution, seconds and cost per shot in the brief.

## Shot needs → capability to filter on

| Shot need | Capability to require | Notes |
|---|---|---|
| Person talking to camera, English | native audio + lip-synced dialogue | ≤3 words/s; key phrase early |
| Dialogue in a language the model mispronounces | i2v with audio off, then TTS + lip-sync model | see `dialogue-and-voice.md` |
| Same person across shots | image references / identity consistency, or one locked start still reused | the still is the most reliable lever |
| Story beat with a sound cue to cut on | native audio | describe the sound in the prompt |
| Silent b-roll for the edit | i2v or t2v, audio toggle off | cheapest model that holds realism at 480p |
| Seamless loop | end-frame support | start = end frame |
| Long continuous take | longest duration range (10-15s) | long takes beat chained short clips |
| Fix one thing in an existing clip | video-to-video / edit | try before regenerating; does not fix eyelines |
| Bigger output for YouTube / web hero | video upscale | cheap; works from 480p for tiles, not for blurry stills |
| Photo-real still / composite with a logo | photo-real image model with tagged references | |
| Still with readable text | image model flagged for text rendering | still prefer compositing text in the edit |
| Music bed / SFX | music and SFX models | describe genre, instruments, BPM, structure |

## Resolution and cost rules (model-independent)

- 480p (lowest non-draft tier) for tiles, PiP, b-roll, anything not full-bleed.
- 720p when 480p reads as AI, and for website loops (from a ≥1440px still).
- 1080p for full-bleed faces in story films with dialogue, after one test take.
- 4K only on explicit request, and only on the final approved cut.
- Draft / turbo / preview modes look visibly AI: compare prompts with them, never ship them.
- Quote cost per second × duration per shot, and the plan total, before the first call.
- Budget +30% reshoot buffer on dialogue films, +10% on b-roll.

## Calibration (observed late 2026, Runway credits, for orders of magnitude only)

| Model family | Setting | Approx. cost |
|---|---|---|
| Seedance 2.5 | 480p / 720p / 1080p | ~20 / ~30 / ~68 credits per second |
| Seedance 2 | 480p 10s | ~360 credits (more than 2.5 at 480p) |
| Veo 3.1 | 720p, 8s, dialogue | ~320 credits |
| Photo-real image model (still or edit) | 2K | ~20 credits |
| Image upscale 2x | photo | ~25 credits |
| Video upscale 4x | from 480-640px | ~10 credits per clip |
| Video outpaint / expand | per second | ~28 credits/s |
| Music bed | 30-60s | ~8 credits |

Typical project totals: a 15s ad with 3 people tiles ~600-1,000 credits; a 45-60s story film
with dialogue ~1,200-3,500; a website loop ~250. Plans that blow past this usually mean too
many short clips or re-generating instead of editing.

## Generation gotchas (provider-agnostic unless noted)

- **Async everything.** Poll every 60-120s. Queues range from minutes to hours. Never
  re-submit a slow task: you pay twice.
- **Recover past settings.** Task-fetch endpoints usually return the full prompt and
  parameters: use them on recent items before remaking a shot.
- **A still's task ID can often be passed as the start frame** directly, no download/upload.
  For local files, use the provider's upload flow and copy returned URLs verbatim (signed
  tokens break if edited).
- **Start frame + reference images together** may be rejected on some models. Composite the
  start still first (set + face as references), then animate it.
- **Audio restarts from silence every take,** and take loudness varies a lot (-42 to -19 dB
  observed). Normalize per take in the edit.
- **Word budget is real.** One model filled the duration and silently dropped a phrase above
  ~3.2 words/s (43 words in 12s lost a sentence). ≤3 words/s, ≤38 words per 12s.
- **Silent takes that mention "voices" in the sound line invent gibberish speech** (sometimes a
  swear word). No-dialogue takes: audio off, or never play their audio.
- **Native non-English speech** is often mispronounced, and anglicisms inside another language
  break almost every time. Speech-to-speech keeps the errors. See `dialogue-and-voice.md`.
- **Text, UI and small logos come out as gibberish.** Large simple wordmarks as references
  survive on walls and mugs.
- **Ambitious camera moves** (POV to third person, orbits) produce ghosting, extra people,
  outfit changes. One such take burned ~680 credits with nothing usable.
- **"Cinematic film still"** can return a fake film-strip border with slate text; **"webcam
  view"** can return a laptop bezel; stray brand logos appear on cups. Fix on the still.
- **Outpaint can silently fail** by letterboxing the source with black bars, and still bill.
  Test on a 2s cut and run `cropdetect` before relying on it. Outpainting the still and
  re-animating is safer.
- **Upscaling doesn't rescue a small still.** A 720px still → 480p take → video upscale stays
  blurry. Upscale the still to ≥1440px first, then animate at 720p.
- **Music moderation:** marketing phrasing ("premium SaaS energy", "social video feel") can be
  blocked as third-party references. Describe the music, not the brand feel.
- **TTS connectors:** some only accept voices already added to the account (library voices
  return "not found"). The vendor's REST API with a local key is the fallback.

## Model test log

Add a line each time a model is tried for the first time.

```
YYYY-MM-DD | model | shot type, resolution, seconds | verdict | credits
2026-10-09 | seedance-2.5 | 720p native English dialogue, 4 takes | clean lip sync, ~30 words/10s | 30/s
2026-10-19 | seedance-2.5 | 720p 9:16 i2v talking head, 9 takes | identity held from one still; drops words >3.2 w/s | 30/s
2026-10-26 | seedance-2.5 | 720p 21:9 i2v dialogue + scream | ratio accepted, identity held, native scream usable | 30/s
2026-11-03 | seedance-2.5 | 1080p 3:4 native French talking head, 9 takes | picture excellent; anglicisms and short numerals mispronounced | 68/s
```
