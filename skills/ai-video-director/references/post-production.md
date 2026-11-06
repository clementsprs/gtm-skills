# Post-production: edit, compositing, captions, sound, masters, platforms

## Choose the edit tool

- **ffmpeg alone:** a straight cut of native-audio takes with burned captions (UGC host ads,
  simple stitches).
- **Remotion (React, frame-based):** anything with product UI, motion graphics, word-level
  captions, multiple ratios or languages from one source. Every animation is a pure function
  of the frame, so renders are deterministic and variants are props.
- A traditional NLE (Premiere, Resolve, CapCut) is fine for a human finishing pass; the rules
  below still apply.

## Editing rules that make AI footage feel shot

- **Cut on action or on sound.** A gong hit, a door, a head turn, a laugh. Native-audio takes
  give you sync points: ask for them in the prompt.
- **J and L cuts** between dialogue takes hide the seam of audio restarting from silence.
- **Do camera energy in the edit, not the generation:** held punch-in jump zooms on faces
  (100% → 112-118% on a beat, with a tiny overshoot), zoom-through blur transitions, an impulse
  shake on a hit. Generation stays locked-off or slow push-in, where it's clean.
- **Scene push-ins 0.99 → 1.00 scale,** never above 1.0 on generated footage (upscaled pixels
  show).
- **People full-bleed on hook, payoff and close;** product or UI in the middle, with the
  person as PiP or a call tile.
- **One big on-screen element per beat** for mobile.
- If a generated push-in crops a logo or a hand, play the clip at 0.75-0.8x or crop in the
  edit.
- One intentional cut to black per film, at most, where the story needs a breath.

## Product UI and text in the scene

- **Never generate UI.** Rebuild the real interface as a measured replica (read computed styles
  from the live product, or trace a screenshot at 1:1), with fictional data.
- **Animate the feature arriving** (a field fills, a row appears), not a Ken Burns over a
  screenshot: 1px borders shimmer when scaled slowly.
- Floating screens: fast spring in, then hold still.
- **UI on a filmed screen (laptop, phone, monitor):**
  1. Track the screen's four corners per frame (optical flow + homography; extrapolate corners
     that leave frame rather than snapping to the frame edge). For flat coloured surfaces a
     colour mask → convex hull → quad works.
  2. Pin the UI with a perspective transform (CSS `matrix3d` in Remotion, or `perspective`
     filter in ffmpeg).
  3. Multiply the plate's own screen light over it (wide-blurred local-max envelope) so it
     glows like the screen did.
  4. Put occluders back on top (fingers, a head passing in front: mask of non-screen pixels
     inside the quad).
  A flat, crisp UI on a filmed screen reads as a sticker.
- **Text on a surface** (a sign, a sticker): same four-corner track, centred, multiply blend,
  slight blur to match the plate's softness.
- **Printed gibberish on a flat prop:** detect its colour region per frame, repaint the interior
  from its own colour, keep a 2px rim. Free, vs. paying for a video edit.

## Captions

- Silent-first platforms (LinkedIn, Meta feeds) need burned captions. Word-accurate always.
- Timings: Whisper-class model with word timestamps; rebuild cues from words; min ~1.2s per
  cue; ≥2.5s for any line the viewer must read in an ad.
- Hand-correct brand words, then re-transcribe the master as QA.
- Burn captions before fades.
- Styles:
  - **Ads, short-form energy:** word-pop captions (each word scales in on its timestamp), the
    key line in a tilted colour box.
  - **Story films where characters talk:** classic white subtitles at the bottom, two lines
    max. Pop captions over dialogue scenes look like a meme.
- **If your ffmpeg has no libass/freetype:** render each caption as a transparent PNG
  (headless Chrome screenshot of an HTML snippet, `text-wrap: balance`, a semi-opaque box) and
  overlay with `enable='between(t,a,b)'`.
- Safe zones: keep copy clear of platform UI. 9:16 Shorts/Reels: nothing in the bottom ~25%
  or right ~15%. 16:9 YouTube: ≥170px from the bottom at 1080p.
- Legibility at feed size (~360px wide): body text ≥40px and headlines ≥64px at 1080 width.

## Sound

- **Native-audio takes:** normalize each take individually (they vary by 20 dB), then mix.
  A build that must rise lives inside one take.
- **Music:** name BPM and the drop second when generating, cut on the drop. Under VO, ask for
  even dynamics.
- **Ambience bed** under UGC and dialogue so cuts don't drop to digital silence.
- Levels for a narrated web film: voice -16 LUFS, music -32 to -34 LUFS (normalized
  separately), `amix normalize=0`, no sidechain needed.
- Social/ad masters: `loudnorm=I=-14:TP=-1.5:LRA=11`. Raw renders at -25 LUFS sound silent in
  a feed.
- Never let audio cut on the last frame: 0.3-0.5s fade out.

## Mastering (every deliverable)

```bash
scripts/master-social.sh in.mp4 out.mp4
```

Which does:

```bash
ffmpeg -i in.mp4 -vf format=yuv420p -c:v libx264 -preset slow -crf 17 \
  -colorspace bt709 -color_primaries bt709 -color_trc bt709 -color_range tv \
  -af loudnorm=I=-14:TP=-1.5:LRA=11 -c:a aac -b:a 192k -ar 48000 -movflags +faststart tmp.mp4
ffmpeg -i tmp.mp4 -c copy \
  -bsf:v h264_metadata=colour_primaries=1:transfer_characteristics=1:matrix_coefficients=1:video_full_range_flag=0 \
  -movflags +faststart out.mp4
```

Why: many renderers output full-range or bt470bg-tagged video; social platforms then shift the
colours. Explicit bt709 / tv range tags fix it.

**Never pipe a render into another command in a script** (`render | tail && ffmpeg`): the pipe
returns the last command's status and you remux a stale file. Use `set -euo pipefail`, no
pipes, then check the output's modification time and duration.

Remotion tips: `--concurrency=2 --timeout=180000` on laptops; if fonts stall on late frames,
render in chunks and join with `ffmpeg -f concat -c copy`.

## Website hero loops

```bash
scripts/loop-web.sh take.mp4 hero        # → hero.mp4, hero.webm, hero-poster.jpg
```

- Start = end frame at generation, plus a 0.5s crossfade at the loop point in post.
- 1080 x264 crf 23 + VP9 crf 36, no audio track, target ~150-400 KB.
- Poster = the exported loop's frame 0 (the script writes it), shown first; lazy-load the
  video after it.
- New filename per version (CDNs cache aggressively).

## Platforms

| Platform | Ratio | Notes |
|---|---|---|
| LinkedIn feed | 1:1 or 4:5 | silent-first, captions always, off-white or full-bleed people, CTA in the platform button not burned in |
| Meta feeds / Reels | 4:5, 9:16 | person in frame 0, captions, keep the bottom quarter clear on 9:16 |
| YouTube in-stream / Demand Gen | 16:9 + 9:16 | brand seen and spoken by 2-4s, VO helps, upscale 480p tiles 4x |
| TikTok / Shorts | 9:16 | native-feeling UGC, captions in safe zone, hook in 1s |
| Website | 16:9 or custom | loops, no audio, poster first |

Ads generally can't swap a video in place: create a new ad and pause the old one.

## Chaining takes

```bash
scripts/last-frame.sh take03.mp4          # → take03.last.png, start frame for take04
```

Upload that PNG as the next take's start frame. At a real cut you can skip it; the continuity
block in the prompt still applies.
