# GTM skills

Agent skills I use every day as a B2B marketing lead, made generic so any go-to-market team
can use them. Each one is a folder with a `SKILL.md` (plus references and scripts when
needed) that Claude Code, Claude.ai or any agent that reads skills can load.

They come from real work: ads and films that shipped, posts that got published, emails reps
actually sent. Every rule in them started as a correction made while reviewing the output.

## Skills

| Skill | What it does |
|---|---|
| [`ai-video-director`](skills/ai-video-director) | AI video that looks filmed, not generated: storyboard gate, locked faces, timed-beat prompts, physics and eyeline rules, native dialogue, review, edit and platform masters |
| [`product-motion-film`](skills/product-motion-film) | Premium on-brand product motion film (Remotion, ~40 s, no voice-over): one continuous conversation with an AI driving the product, cards that show real output, spring motion, mobile-sized type, feel-good music, 4K render |

## Install

**Claude Code** (all skills):
```bash
git clone https://github.com/clementsprs/gtm-skills
cp -R gtm-skills/skills/* ~/.claude/skills/
```
One skill: copy just its folder. Then ask in plain words ("make a 20s product film for our new feature",
"make a 15s video ad for...") or call it by name (`/ai-video-director`).

**Claude.ai:** zip a skill folder and upload it under Settings → Capabilities → Skills.

**Other agents:** point them at the skill's `SKILL.md`; references load on demand.

## Make them yours

These skills get better with every correction. When you reject an output, write the rule
into the skill the same day, so the next run doesn't repeat the mistake. Placeholders like
`[your product]` and `[your category]` are where your own context goes.

## License

MIT. Use them, fork them, ship with them.
