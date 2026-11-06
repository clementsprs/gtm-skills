# AI video director

An agent skill (Claude Code, Claude.ai, or any agent that reads `SKILL.md`) for making AI
video that looks **filmed, not generated**: real people in real places, believable motion,
the same face from shot to shot, native dialogue, and a finished edit with captions, sound and
platform masters.

It comes from producing a few dozen AI films and ads in 2026 (paid social, UGC host ads, story
films with dialogue, product films, website hero loops) and writing down every correction
made while reviewing the cuts.

## What's inside

```
ai-video-director/
├── SKILL.md                       the ten rules + the 8-step workflow
├── references/
│   ├── storyboard.md              shot grammar, the storyboard gate, segmenting long films
│   ├── prompting.md               realism vocabulary, take skeleton, timed beats, physics pins,
│   │                              eyelines, style triggers, continuity blocks, failure modes
│   ├── prompt-library.md          prompts that shipped, by shot type
│   ├── models-and-costs.md        pick models at run time, cost calibration, provider gotchas
│   ├── dialogue-and-voice.md      native audio vs TTS, word budgets, lip sync, other languages
│   ├── review-qa.md               contact sheets, reject criteria, fix ladder, master QA
│   ├── post-production.md         edit rules, UI compositing, captions, sound, masters, platforms
│   └── compliance.md              synthetic people, testimonials, AI labels, logos, data
└── scripts/                       bash + ffmpeg only
    ├── contact-sheet.sh           review grid of a take
    ├── last-frame.sh              chain takes: last frame → next start frame
    ├── master-social.sh           bt709 tags, -14 LUFS, faststart
    └── loop-web.sh                seamless website loop → mp4 + webm + poster
```

## The ten rules (short version)

1. Plan on paper, pay on screen: storyboard with one still per setup, approved, before any
   video credit.
2. Never pay twice: reuse, quote the plan's cost first, fix in the edit when you can.
3. Low resolution by default, high resolution on purpose.
4. Candid documentary, never stock.
5. Long takes beat many clips; chain them by last frame.
6. Same face, same clothes, same world: one locked still per character.
7. Physics is directed: pin every prop, count people and hands, no fancy camera moves.
8. Every eyeline has a target in frame.
9. Text, UI and logos are composited, never generated.
10. Native voice for on-screen speakers; TTS only for narrators and lip-synced translations.

## Install

**Claude Code**
```bash
git clone https://github.com/clementsprs/gtm-skills
cp -R gtm-skills/skills/ai-video-director ~/.claude/skills/
```
Then ask for a video ("make a 15s UGC ad for...") or type `/ai-video-director`.

**Claude.ai:** zip the folder and upload it under Settings → Capabilities → Skills.

**Other agents:** point them at `SKILL.md`; references are loaded on demand.

## What you need

- A video/image generation provider: Runway (MCP server works well with Claude), or API
  access to fal, Replicate, or model vendors directly. The skill picks the model at run time,
  so it doesn't go stale when new models ship.
- `ffmpeg` (with libx264, libvpx-vp9).
- Optional: Remotion (Node) for edits with UI and motion graphics, ElevenLabs or another TTS,
  a lip-sync model, whisper.cpp for word-level captions and QA.

## Make it yours

The skill gets better with every correction. When a reviewer says "this looks like stock" or
"the voice sounds like a call box", add the rule to `SKILL.md` and the shipped prompt to
`references/prompt-library.md` the same day. Log every new model in the test log at the
bottom of `references/models-and-costs.md`.

## License

MIT (see the repo root). Use it, fork it, ship videos with it.
