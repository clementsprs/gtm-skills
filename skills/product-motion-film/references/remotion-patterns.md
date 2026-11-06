# Remotion patterns for product motion films

Everything here is a pattern, not a drop-in library. The snippets are short and generic: adapt names, sizes and tokens to your film. Time is handled in **seconds**, derived from the frame, so the whole timeline reads like the brief.

## Project structure

```
my-film/
  package.json
  remotion.config.ts
  tsconfig.json
  public/
    brand/       logotype.svg, logotype-white.svg, icon.svg, pattern.png   (bring your own)
    logos/       partner logos (SVG, with permission)
    avatars/     fictional people (generated or licensed images)
    fonts/       your licensed woff2 files
    audio/       bed.mp3, click.mp3, pop.mp3, whoosh.mp3, chime.mp3     (licensed or generated)
  src/
    index.ts     registerRoot(RemotionRoot)
    Root.tsx     <Composition> entries
    theme.ts     every colour, font stack and canvas constant (see brand-reading.md)
    fonts.ts     @font-face + bounded wait
    kit.ts(x)    timing helpers + shared motion components
    <Film>.tsx   one film: timeline constants, copy arrays, scene components
```

Nothing in `public/` ships with this skill. Bring your own fonts and brand assets, and use music and SFX you have a licence for or have generated.

### package.json scripts

```json
{
  "scripts": {
    "studio": "remotion studio src/index.ts",
    "still": "remotion still src/index.ts Film out/still.png --scale=0.5",
    "master": "remotion render src/index.ts Film out/master-4k.mp4 --scale=2 --codec=h264 --crf=14 --jpeg-quality=100 --x264-preset=slow",
    "review": "ffmpeg -y -i out/master-4k.mp4 -vf scale=1920:1080:flags=lanczos -c:v libx264 -preset slow -crf 14 -pix_fmt yuv420p -c:a copy -movflags +faststart out/review-1080p.mp4"
  }
}
```

The composition is authored at 1920x1080; `--scale=2` renders it at 3840x2160. The review file is a Lanczos downscale of that master, which is visibly crisper than a native 1080p render.

### remotion.config.ts

```ts
import { Config } from '@remotion/cli/config';

Config.setVideoImageFormat('jpeg');
Config.setOverwriteOutput(true);
Config.setConcurrency(4);
// long 4K renders: give slow frames room before timing out
Config.setDelayRenderTimeoutInMilliseconds(180000);
```

### Root.tsx

```tsx
import React from 'react';
import { Composition } from 'remotion';
import { FPS, W, H } from './theme';
import { Film, FILM_FRAMES } from './Film';

export const RemotionRoot: React.FC = () => (
  <Composition id="Film" component={Film} durationInFrames={FILM_FRAMES} fps={FPS} width={W} height={H} />
);
```

60 fps makes the slow camera push and small text moves look smoother than 30 fps; the cost is render time.

## Local fonts with a bounded wait

Load fonts from `public/fonts` with plain `@font-face`, and hold the render until they are ready, but never forever: on long renders a font promise can occasionally never settle, and an unbounded `delayRender` then kills the whole render. Call the hook from the composition, not at module load (the bundle is also evaluated in a page that never renders frames, and a module-level `delayRender` there times out).

```tsx
import { useEffect, useState } from 'react';
import { continueRender, delayRender, staticFile } from 'remotion';

const faces = [
  { family: 'Display', weight: '600', file: 'display-600.woff2' },
  { family: 'Body', weight: '400', file: 'body-400.woff2' },
  { family: 'Body', weight: '500', file: 'body-500.woff2' },
  { family: 'Mono', weight: '500', file: 'mono-500.woff2' },
];

if (typeof document !== 'undefined') {
  const style = document.createElement('style');
  style.textContent = faces
    .map((f) => `@font-face{font-family:'${f.family}';font-weight:${f.weight};font-display:block;src:url('${staticFile(`fonts/${f.file}`)}') format('woff2');}`)
    .join('\n');
  document.head.appendChild(style);
}

export const useFonts = () => {
  const [handle] = useState(() => delayRender('fonts', { timeoutInMilliseconds: 30000 }));
  useEffect(() => {
    Promise.race([
      Promise.all(faces.map((f) => document.fonts.load(`${f.weight} 16px '${f.family}'`))),
      new Promise((r) => setTimeout(r, 8000)),
    ]).finally(() => continueRender(handle));
  }, [handle]);
};
```

## Timing helpers

```ts
import { Easing, interpolate, useCurrentFrame } from 'remotion';
import { FPS } from './theme';

export const clamp = { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' } as const;
export const EASE = Easing.bezier(0.16, 1, 0.3, 1);       // entrances: fast start, soft landing
export const INOUT = Easing.bezier(0.65, 0, 0.35, 1);     // moves between two states
export const SOFTPOP = Easing.bezier(0.3, 1.35, 0.5, 1);  // small overshoot for logos, ticks, badges

// 0 → 1 between `at` and `at + dur` seconds
export const tw = (t: number, at: number, dur: number, easing = EASE) =>
  interpolate(t, [at, at + dur], [0, 1], { ...clamp, easing });

export const mix = (a: number, b: number, k: number) => a + (b - a) * k;

// current time in seconds
export const useT = () => useCurrentFrame() / FPS;

// deterministic pseudo-random (never Math.random in a render: every frame must be reproducible)
export const rnd = (i: number, seed: number) => {
  const x = Math.sin(i * 12.9898 + seed * 78.233) * 43758.5453;
  return x - Math.floor(x);
};
```

### Springs (the dynamic layer)

Everything that arrives uses a spring with a little overshoot; bumps and punches use a damped kick.

```ts
import { spring } from 'remotion';

type Cfg = { damping: number; stiffness: number; mass: number };
export const BOUNCY: Cfg = { damping: 11, stiffness: 160, mass: 0.9 }; // ~12 % overshoot: words, cards, ticks
export const SNAP: Cfg = { damping: 15, stiffness: 260, mass: 0.7 };   // lands fast: logo slams, toggles
export const SOFT: Cfg = { damping: 20, stiffness: 120, mass: 1 };     // barely overshoots: big surfaces

// 0 → 1 (with overshoot) from `at` seconds
export const sp = (t: number, at: number, cfg: Cfg = BOUNCY) =>
  t < at ? 0 : spring({ frame: (t - at) * FPS, fps: FPS, config: cfg });

// 0 → +1 → settles at 0: bumps on impact, camera punches, squash on landing
export const kick = (t: number, at: number, dur = 0.5) => {
  if (t < at || t > at + dur) return 0;
  const u = (t - at) / dur;
  return Math.sin(u * Math.PI * 2.2) * Math.exp(-u * 4.2);
};
```

Never pass `Infinity` as a time to `interpolate` (it throws): use a large number such as `1e6` for "never".

## Timeline: one conversation, computed from what each step needs

Each step is: the prompt rises in and types → sent → status line → the product card plays out inside the thread → the reply. Starts are computed from typing time, each card's own execution time and the reply length.

```ts
const SWAP = 3.5;                         // hook line A → product line
const HOOK_OUT = 5.0;                     // the hook leaves, the conversation starts
const TYPE = [1.8, 1.9, 1.2, 1.05];       // prompt typing, by prompt length
const STATUS = 0.9;                       // "Searching <product>…" before the card
const EXEC = [2.1, 4.4, 2.3, 3.4];        // how long each card needs to finish (count-up, writing, branches, ticks)
const REPLY_WORDS = [12, 14, 9, 9];
const WPS = 9;                            // reply stream, words per second
const HOLD = 1.0;                         // read the reply before the next prompt
const SC: number[] = [], SEND: number[] = [], PIN: number[] = [], CARD: number[] = [], REPLY: number[] = [];
{
  let c = HOOK_OUT + 0.35;
  for (let i = 0; i < EXEC.length; i++) {
    SC.push(c);
    SEND.push(c + TYPE[i]);
    PIN.push(SEND[i] + STATUS);           // status ticks to done
    CARD.push(PIN[i] + 0.1);
    REPLY.push(CARD[i] + EXEC[i] + 0.2);  // the reply waits for the card to finish
    c = REPLY[i] + REPLY_WORDS[i] / WPS + HOLD;
  }
}
const END = REPLY[REPLY.length - 1] + REPLY_WORDS[REPLY_WORDS.length - 1] / WPS + 0.8;
export const SECONDS = Math.ceil((END + 3.2) * 10) / 10; // finale ~3.2 s
```

Four steps come out around 40 s. If that is too long, drop a step; don't shorten holds.

## Continuous thread: layout and scroll camera

Lay the whole thread out once, in thread coordinates, from text-length estimates; then scroll it with soft springs between focus points. The new prompt rising to the centre is what pushes the previous exchange up: that scroll IS the transition between steps.

```tsx
const FS = { prompt: 62, status: 44, reply: 58 };                       // mobile-readable sizes
const lines = (text: string, fs: number, width: number) => Math.max(1, Math.ceil((text.length * fs * 0.53) / width));
const bubbleH = (i: number) => lines(PROMPTS[i], FS.prompt, 1400 - 96) * FS.prompt * 1.3 + 56;
const replyH = (i: number) => lines(REPLIES[i], FS.reply, 1480 - 96) * FS.reply * 1.3 + 60;
const CARD_H = [482, 650, 430, 425];      // unscaled card heights, measured on stills
const CS = [1.38, 1.22, 1.38, 1.3];       // per-card scale: the tallest still clears the header

const LAY = [];                           // y of each element in the thread
{
  let y = 0;
  for (let i = 0; i < PROMPTS.length; i++) {
    const bubble = y;
    const status = bubble + bubbleH(i) * 0.86 + 50;   // the sent bubble shrinks to 0.86
    const card = status + FS.status * 1.4 + 56;
    const reply = card + CARD_H[i] * CS[i] + 70;
    LAY.push({ bubble, status, card, reply });
    y = reply + replyH(i) + 160;
  }
}
// focus keyframes: [time, thread y placed at the top of the screen]
const SCROLL: [number, number][] = [];
SC.forEach((c, i) => {
  SCROLL.push([c - 0.35, LAY[i].bubble + bubbleH(i) / 2 - 470]);              // new prompt centred
  SCROLL.push([CARD[i] - 0.15, LAY[i].card + (CARD_H[i] * CS[i]) / 2 - 605]); // card centred, below the header
  SCROLL.push([REPLY[i] - 0.25, LAY[i].reply + replyH(i) - 760]);            // reply in view
});
const SCROLLCFG = { damping: 18, stiffness: 80, mass: 1 };
const scrollAt = (t: number) => {
  let y = SCROLL[0][1] - 900, prev = y;   // the thread enters from below
  for (const [at, v] of SCROLL) { y += (v - prev) * sp(t, at, SCROLLCFG); prev = v; }
  return y;
};
// <AbsoluteFill style={{ transform: `translateY(${-scrollAt(t)}px)` }}> …thread elements at their LAY y… </AbsoluteFill>
```

Put a fixed header above the thread on a white-to-transparent gradient, so scrolled content slides under it cleanly. For a product that works with any AI (an MCP), the header is the product's chip ("<Product> MCP" + green dot) + "works with" + the AI icons: no assistant branding anywhere in the chat.

## Prompt bubble: rises in, types centred, slides right

```tsx
const pop = sp(t, SC[i], BOUNCY);
const k = sp(t, SEND[i], { damping: 16, stiffness: 140, mass: 1 });  // centre → right
const estW = Math.min(1400, prompt.length * FS.prompt * 0.53 + 96);
const shift = (COL_RIGHT - (W / 2 + estW / 2)) * k;
<div style={{ position: 'absolute', left: 0, right: 0, top: LAY[i].bubble, display: 'flex', justifyContent: 'center', transform: `translateX(${shift}px)` }}>
  <div style={{ maxWidth: 1400, padding: '28px 48px', borderRadius: 52, background: theme.ui.bubble, fontSize: FS.prompt,
    opacity: Math.min(1, pop * 2), transform: `translateY(${(1 - pop) * 80}px) scale(${mix(0.6, 1, pop) * mix(1, 0.86, k)})`, transformOrigin: '100% 0%' }}>
    {typed}{typing ? <Caret /> : null}
  </div>
</div>
```

Keep the caret solid (a blinking caret reads as flicker at 60 fps).

## Status line and reply bubble

The status line: three dots bouncing in the product colour + "Searching <product>…" + the real tool name in mono; at `PIN` it ticks to a check and the past tense. The reply is a **message bubble** (white, hairline, soft shadow, left, opposite the grey user bubble); bare text reads as a caption, not as the AI talking. No avatar needed.

```tsx
const b = sp(t, REPLY[i] - 0.05, BOUNCY);
<div style={{ maxWidth: 1480, padding: '28px 48px', borderRadius: 48, borderTopLeftRadius: 14, background: theme.ui.white,
  boxShadow: `inset 0 0 0 1px ${theme.ui.line}, 0 14px 36px ${theme.ui.shadow}`, fontSize: FS.reply,
  opacity: Math.min(1, b * 2), transform: `translate(${(1 - b) * -60}px, ${(1 - b) * 30}px) scale(${mix(0.7, 1, b)})`, transformOrigin: '0% 0%' }}>
  {words.map((w, j) => {
    const o = interpolate((t - REPLY[i]) * WPS - j, [0, 1.4], [0, 1], clamp);
    return <span key={j} style={{ opacity: Math.min(1, o * 1.6), color: o < 0.995 ? theme.brand.accent : theme.ui.ink }}>{w} </span>;
  })}
</div>
```

## Product card inside the thread

The card sits in the AI's column at its `LAY` y, scaled per card around its centre; it lands with a spring and a small bump when the tool call arrives.

```tsx
const cin = sp(t, CARD[i], BOUNCY);
<div style={{ position: 'absolute', left: AI_X + (760 * (CS[i] - 1)) / 2, top: LAY[i].card + (CARD_H[i] * (CS[i] - 1)) / 2, width: 760,
  opacity: Math.min(1, tw(t, CARD[i], 0.15)),
  transform: `translate(${(1 - cin) * -160}px, ${(1 - cin) * 180}px) scale(${CS[i] * mix(0.82, 1, cin) * (1 + kick(t, CARD[i] + 0.38, 0.55) * 0.03)}) rotate(${(1 - cin) * 6}deg)` }}>
  <Card t={t} at={CARD[i]} />
</div>
```

A card = the product's full logotype + a hairline divider + the title + one right-side value (or real channel logos), 3-4 rows, optional footer. Count-ups use `Math.round(target * tw(...))` with tabular numbers and pulse once when they land.

## Toggle as its own moment

```tsx
const TG = at + 0.75;                                   // after the card has landed
const on = Math.min(1.06, sp(t, TG, SNAP)), squish = kick(t, TG, 0.35), ring = tw(t, TG + 0.05, 0.7), lab = sp(t, TG + 0.15, BOUNCY);
// track: grey base + brand-colour layer with opacity = clamp(on); whole toggle scale(1 + kick(t, TG, 0.45) * 0.12)
// pulse ring: inset -2, box-shadow 0 0 0 3px brand line colour, scale(1 + ring * 0.7), opacity 1 - ring
// knob: left = 3 + min(1, on) * 24 - max(0, squish) * 6, width = 26 + |squish| * 8
// "Active" label in the brand colour pops beside it; the run log starts ~0.5 s later
```

## Word: springs in, pushes its neighbours, gets thrown out

No blur. `push` (an estimated max width in px) makes the word take its width as it lands, so earlier words slide aside and the line re-centres live. `out` throws it up and away.

```tsx
export const Word: React.FC<{ t: number; at: number; ink: string; push?: number; out?: number; children: React.ReactNode }> = ({ t, at, ink, push, out = 1e6, children }) => {
  const p = sp(t, at, BOUNCY);
  const o = tw(t, out, 0.45, Easing.bezier(0.5, 0, 0.9, 0.4)); // accelerating exit
  const f = Math.min(1, tw(t, at, 0.18)) * (1 - o);
  const grow = push ? { maxWidth: Math.min(1, sp(t, at - 0.04, SNAP)) * push } : {};
  return (
    <span style={{
      display: 'inline-flex', justifyContent: 'center', whiteSpace: 'nowrap', color: ink, opacity: f,
      transform: `translateY(${(1 - p) * 60 - o * 90}px) scale(${mix(0.55, 1, p)}) rotate(${(1 - p) * 7 - o * 5}deg)`,
      transformOrigin: '50% 100%', ...grow,
    }}>{children}</span>
  );
};

// a line in a flex row with `gap`: each word arrives 0.07-0.12 s after the previous one
// {['Your', 'new', 'sales', 'intern,'].map((w, k) => <Word key={k} t={t} at={0.75 + k * 0.11} ink={ink} push={size * 0.62 * w.length} out={SWAP + k * 0.05}>{w}</Word>)}
```

### Logo slam inside a sentence

```tsx
const sl = sp(t, slam, SNAP);
const punch = kick(t, slam + 0.12, 0.55) * 0.035; // apply as scale(1 + punch) on the whole hook layer
<span style={{ display: 'inline-flex', maxWidth: sp(t, slam - 0.05, SNAP) * 300, opacity: tw(t, slam, 0.08),
  transform: `scale(${mix(2.2, 1, sl)}) rotate(${(1 - sl) * -8}deg)` }}>
  <Img src={staticFile('brand/logotype.svg')} style={{ height: size }} />
</span>
```

## Logo slot: full logos with names, switching

Icons alone are not recognised by everyone: show each tool as icon + wordmark, one at a time in a single slot. For a product that works with any AI, end on all the icons together rather than on one assistant. The white chip behind springs between lockup widths. The outgoing logo is gone before the next lands.

```tsx
const LOGOS = [ // ar = wordmark aspect ratio from its viewBox
  { icon: 'logos/a.svg', text: 'logos/a-text.svg', ar: 97 / 24 },
  { icon: 'logos/b.svg', text: 'logos/b-text.svg', ar: 86 / 24 },
  { icon: 'logos/c.svg', text: 'logos/c-text.svg', ar: 63 / 24 },
  { icon: 'logos/a.svg', text: 'logos/a-text.svg', ar: 97 / 24 }, // end on the film's assistant
];
const LOGO_AT = [0.2, 0.85, 1.5, 2.15];
const LG = { y: 330, icon: 84, text: 60, gap: 22 };
const lockW = (k: number) => LG.icon + LG.gap + LG.text * LOGOS[k].ar;

const LogoSlot: React.FC<{ t: number }> = ({ t }) => {
  let w = lockW(0);
  for (let k = 1; k < LOGOS.length; k++) w += (lockW(k) - lockW(k - 1)) * sp(t, LOGO_AT[k] - 0.05, SNAP);
  const chip = sp(t, 0.15, BOUNCY);
  return (
    <>
      <div style={{ position: 'absolute', left: W / 2 - (w + 64) / 2, top: LG.y - 70, width: w + 64, height: 140, borderRadius: 34, background: theme.ui.white, boxShadow: `0 0 0 1px ${theme.ui.line}, 0 16px 40px ${theme.ui.shadow}`, opacity: Math.min(1, chip * 2), transform: `scale(${chip})` }} />
      {LOGOS.map((L, k) => {
        const nx = LOGO_AT[k + 1];
        if (t < LOGO_AT[k] || (nx !== undefined && t > nx + 0.5)) return null;
        const inn = sp(t, LOGO_AT[k], SNAP);
        const out = nx === undefined ? 0 : tw(t, nx - 0.16, 0.16, Easing.bezier(0.5, 0, 0.9, 0.4));
        return (
          <div key={k} style={{ position: 'absolute', left: W / 2 - lockW(k) / 2, top: LG.y - LG.icon / 2, display: 'flex', alignItems: 'center', gap: LG.gap, opacity: Math.min(1, inn * 2.5) * (1 - out), transform: `translateY(${(1 - inn) * 70 - out * 70}px) scale(${mix(0.6, 1, inn) * (1 - out * 0.3)}) rotate(${(1 - inn) * 8}deg)` }}>
            <Img src={staticFile(L.icon)} style={{ width: LG.icon, height: LG.icon, transform: `rotate(${(1 - inn) * -90}deg)` }} />
            <Img src={staticFile(L.text)} style={{ height: LG.text, width: LG.text * L.ar }} />
          </div>
        );
      })}
    </>
  );
};
```


## AI-written message (instead of merge tags)

Words appear at ~16 words/s with a caret; the phrase drawn from the lead's signal gets a marker sweep once written, then a one-line angle pops under it.

```tsx
type Seg = string | { hl: string };
const msg: Seg[] = ['Priya, ', { hl: 'four SDR hires in one quarter' }, ' is a big bet. Want your new reps booking meetings in their first week?'];
const words = (m: Seg[]) => m.flatMap((g) => (typeof g === 'string' ? g : g.hl).split(/(?<= )/).map((w) => ({ w, hl: typeof g !== 'string' })));

const Written: React.FC<{ t: number; at: number }> = ({ t, at }) => {
  const ws = words(msg);
  const done = at + ws.length / 16;
  const mark = tw(t, done + 0.05, 0.45, INOUT);
  return (
    <div>
      {ws.map((x, i) => (
        <span key={i} style={{
          opacity: interpolate((t - at) * 16 - i, [0, 1], [0, 1], clamp),
          fontWeight: x.hl ? 600 : 400,
          backgroundImage: x.hl ? `linear-gradient(${theme.brand.tint}, ${theme.brand.tint})` : undefined,
          backgroundRepeat: 'no-repeat', backgroundSize: x.hl ? `${mark * 100}% 100%` : undefined,
        }}>{x.w}</span>
      ))}
    </div>
  );
};
```

## Branching flow (multichannel with conditions)

Step node → connector → "Wait 3 days" pill → two SVG branches drawn with `pathLength={1}` → condition chips → two nodes. Wrap everything under the first node in a container whose `maxHeight` springs from 0, so the card grows as the flow draws.

```tsx
const br = tw(t, at, 0.55, INOUT);
<svg width={BW} height={78} style={{ overflow: 'visible' }}>
  {[`M${BW / 2} 0 C ${BW / 2} 40, ${BW * 0.25} 30, ${BW * 0.25} 78`, `M${BW / 2} 0 C ${BW / 2} 40, ${BW * 0.75} 30, ${BW * 0.75} 78`].map((d, k) => (
    <path key={k} d={d} fill="none" stroke={theme.brand.line} strokeWidth={2} strokeLinecap="round" pathLength={1} strokeDasharray={1} strokeDashoffset={1 - br} />
  ))}
</svg>
// chips: "Not opened" over the left branch, "Opened, no reply" over the right one, popping with sp(…, BOUNCY)
// a voice-message node = play dot + ~22 waveform bars whose heights breathe with Math.sin(t * 9 + i * 0.8)
```

## Run log (modern status list)

```tsx
// per step k: start = at + 0.6 + k * 0.45, end = start + 0.38
// dot: hairline circle → spinning ring while running → brand-colour fill with a white check (scale = sp(t, end, BOUNCY))
// a 2 px rail behind the dots fills from the first to the last dot: height = rowH * (n - 1) * interpolate(t, [start(0), end(n-1)], [0, 1])
// under each title, a result line slides up once done ("38 new leads matched"), plus a small mono duration on the right
```

## Hand-drawn highlight (the insight moment)

An SVG path drawn with `pathLength={1}` and an animated dash offset, in the assistant's colour, plus a small badge that pops in 0.35 s later.

```tsx
const Circle: React.FC<{ t: number; at: number; w: number; h: number; color: string }> = ({ t, at, w, h, color }) => {
  const draw = tw(t, at, 0.75, INOUT);
  // slightly irregular loop so it reads as hand-drawn
  const d = `M${w * 0.07} ${h * 0.1} C ${w * 0.34} 0, ${w * 0.84} 0, ${w * 0.94} ${h * 0.16} C ${w} ${h * 0.3}, ${w * 0.99} ${h * 0.79}, ${w * 0.86} ${h * 0.86} C ${w * 0.62} ${h * 0.96}, ${w * 0.2} ${h * 0.93}, ${w * 0.05} ${h * 0.82} C 0 ${h * 0.71}, 0 ${h * 0.27}, ${w * 0.08} ${h * 0.09}`;
  return (
    <svg width={w} height={h} style={{ position: 'absolute', overflow: 'visible', pointerEvents: 'none' }}>
      <path d={d} fill="none" stroke={color} strokeWidth={3} strokeLinecap="round" pathLength={1} strokeDasharray={1} strokeDashoffset={1 - draw} />
    </svg>
  );
};
```

## Backdrop: gradients only (end card)

The brand's dark signature backdrop is for the end card only; mid-film, stay on the light ground (a dark panel rising mid-film reads as a jarring cut).

Glows, horizons and skies are layered `radial-gradient`s. Large `box-shadow` blurs (above about 100 px) band in Chrome, and CSS `filter: blur` on big surfaces softens the whole frame.

```tsx
const Backdrop: React.FC<{ t: number; w: number; h: number }> = ({ t, w, h }) => (
  <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', background: `linear-gradient(165deg, ${theme.sky.deep} 0%, ${theme.sky.mid} 60%, ${theme.sky.low} 100%)` }}>
    {/* a planet-limb horizon: a huge circle filled with a radial gradient, not a shadow */}
    <div style={{ position: 'absolute', left: -1000 + Math.sin(t * 0.2) * 20, top: h * 0.6, width: 2800, height: 2800, borderRadius: '50%', transform: 'rotate(-8deg)', background: `radial-gradient(circle at 50% 0%, ${theme.sky.glow} 0%, transparent 40%)` }} />
    <div style={{ position: 'absolute', inset: 0, background: `radial-gradient(70% 55% at 20% 100%, ${theme.sky.mist}, transparent 70%)` }} />
    {Array.from({ length: 90 }, (_, i) => {
      const s = 1.2 + rnd(i, 3) * 2.2;
      return <div key={i} style={{ position: 'absolute', left: rnd(i, 1) * w, top: rnd(i, 2) * h * 0.7, width: s, height: s, borderRadius: s, background: theme.ui.white, opacity: 0.25 + 0.6 * Math.abs(Math.sin(t * (0.6 + rnd(i, 4)) + i)) }} />;
    })}
  </div>
);
```

For the finale, `mix` the panel's x, y, width, height and radius toward full frame with `INOUT` over about 1 s.

## Sound

```tsx
const BED_IN = 8.9; // seconds into the track: its own ending lands on the end card
const Sfx: React.FC<{ at: number; src: string; v: number }> = ({ at, src, v }) => (
  <Sequence from={Math.max(0, Math.round(at * FPS))} durationInFrames={Math.round(1.5 * FPS)}>
    <Audio src={staticFile(`audio/${src}`)} volume={v} />
  </Sequence>
);
const Sound: React.FC = () => {
  const vol = (fr: number) => interpolate(fr / FPS, [0, 0.25, SECONDS - 0.6, SECONDS - 0.05], [0, 0.8, 0.8, 0], clamp);
  return (
    <>
      <Audio src={staticFile('audio/bed.mp3')} startFrom={Math.round(BED_IN * FPS)} volume={vol} />
      {LOGO_AT.map((a) => <Sfx key={`l${a}`} at={a} src="pop.mp3" v={0.14} />)}
      {SEND.map((a) => <Sfx key={`c${a}`} at={a} src="click.mp3" v={0.3} />)}
      {CARD.map((a) => <Sfx key={`k${a}`} at={a + 0.3} src="pop.mp3" v={0.12} />)}
      {[SWAP + 0.3, PANEL - 0.05, END - 0.2].map((a) => <Sfx key={`w${a}`} at={a} src="whoosh.mp3" v={0.14} />)}
      <Sfx at={PAYOFF} src="chime.mp3" v={0.18} />
    </>
  );
};
```

A music prompt that gave the right energy (any text-to-music model; ask for ~10 s more than the film so you can offset it):

> Instrumental, no vocals. Energetic, playful modern tech launch track at 128 bpm that is at FULL ENERGY FROM THE VERY FIRST SECOND: punchy kick and crisp claps, snappy 16th hi-hats, bouncy plucked synth bass and a bright catchy synth-pluck hook all start immediately on beat one, no slow intro, no ambient build-up, no quiet section. Glassy mallet counter-melody, short punchy synth-brass stabs on accents, quick snare fills and white-noise sweeps every 4 bars to keep it moving. Constant drive and momentum for the whole track, confident and fun like a product launch reel. Ends with a big final hit and a short ring-out. Not house, not EDM drop, not lounge, not lo-fi, no elevator music.

**A picked track that's too short** (stock grooves are often ~25 s): find the tempo and bar starts from kick onsets, repeat whole 4-bar blocks of the full section on bar boundaries, start after the intro so the film opens at full energy, and keep the real ending on the last frame. Never time-stretch a picked track.

```bash
ffmpeg -i src.mp3 -filter_complex "[0:a]atrim=0:$b12,asetpts=PTS-STARTPTS[a];[0:a]atrim=$b8:$b12,asetpts=PTS-STARTPTS[b];[0:a]atrim=$b8:$b12,asetpts=PTS-STARTPTS[b2];[0:a]atrim=$b8,asetpts=PTS-STARTPTS[c];[a][b]acrossfade=d=0.03[ab];[ab][b2]acrossfade=d=0.03[abb];[abb][c]acrossfade=d=0.03[o]" -map "[o]" bed-ext.mp3
# then <Audio startFrom={Math.round(bedIn * FPS)} …/> with bedIn = trackLength - filmLength
```

Check a generated track before building on it: loudness per second (a long quiet stretch means regenerate, models often ignore a prompted structure):

```bash
ffmpeg -v error -i bed.mp3 -ac 1 -ar 8000 -f s16le - | python3 -c "import sys,array,math;a=array.array('h');a.frombytes(sys.stdin.buffer.read());x=[v/32768 for v in a];print(' '.join(f'{k}:{20*math.log10(math.sqrt(sum(v*v for v in x[k*8000:(k+1)*8000])/8000)+1e-9):.0f}' for k in range(len(x)//8000)))"
```

Use a licensed track or one you generated, and SFX from a licensed library or generated. Every effect needs a visible cause on screen.

## Gotchas

- `<Img>` with an SVG whose paths use `fill="currentColor"` renders black. Edit the SVG to a real colour (keep a white variant for dark backdrops).
- Never `Math.random()` or `Date.now()` in a component: frames render in parallel and out of order. Use `rnd(i, seed)`.
- Icon fonts need their own `@font-face` and a licence that covers video. Simple inline SVG line icons avoid both questions.
- Long prompts overflow the composer: show the tail with a leading ellipsis rather than wrapping.
- Check stills at every beat at `--scale=0.5` before rendering: overlap, wrapping and the camera push cropping the edges are the usual failures.
- Contact sheet for review: `ffmpeg -i out/review-1080p.mp4 -vf "select='not(mod(n\,300))',scale=960:-1,tile=2x3" -frames:v 1 out/sheet.png`.
