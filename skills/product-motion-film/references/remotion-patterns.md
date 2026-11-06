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

## Timeline: computed from what each beat needs

Each beat is chat → product executes to the end → back to chat. So beat starts are computed from the typing time, each card's own execution time and the reply length, not from a fixed beat length.

```ts
const SWAP = 3.5;                         // hook line A → product line
const PANEL = 5.1;                        // backdrop panel rises
const TYPE = 1.45;                        // prompt typing
const EXEC = [2.1, 3.4, 2.3, 4.0];        // how long each product card needs to finish (count-up, fills, ticks…)
const REPLY_WORDS = [12, 9, 9, 9];
const WPS = 9;                            // reply stream, words per second
const SC: number[] = [], SEND: number[] = [], TOOL: number[] = [], CARD: number[] = [], REPLY: number[] = [];
{
  let a = PANEL + 0.9;
  for (let i = 0; i < EXEC.length; i++) {
    SC.push(a);
    SEND.push(a + TYPE);
    TOOL.push(a + TYPE + 0.25);
    CARD.push(a + TYPE + 0.45);
    REPLY.push(a + TYPE + 0.45 + EXEC[i]);    // the reply waits for the card to finish
    a = REPLY[i] + REPLY_WORDS[i] / WPS + 0.9; // ~0.9 s to read the reply before the next prompt
  }
}
const END = REPLY[REPLY.length - 1] + REPLY_WORDS[REPLY_WORDS.length - 1] / WPS + 1.1;
export const SECONDS = Math.ceil((END + 3.6) * 10) / 10; // finale holds ~1.5 s after the URL lands
export const FILM_FRAMES = Math.round(SECONDS * FPS);
```

Four beats come out around 37 s. If that is too long, drop a beat; don't shorten holds.

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

## Typed prompt with caret

```tsx
const typed = (t: number, start: number, send: number, text: string) =>
  text.slice(0, Math.round(text.length * interpolate(t, [start + 0.05, send - 0.1], [0, 1], clamp)));

const Composer: React.FC<{ t: number }> = ({ t }) => {
  let text = '';
  let typing = false;
  SC.forEach((a, i) => {
    if (t >= a && t < SEND[i]) { typing = true; text = typed(t, a, SEND[i], PROMPTS[i]); }
  });
  // send button "press": dips just before SEND, springs back after
  const press = SEND.reduce((m, s) => Math.max(m, tw(t, s - 0.06, 0.06) * (1 - tw(t, s + 0.05, 0.15))), 0);
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
      <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', color: text ? theme.assistant.ink : theme.assistant.muted }}>
        {text ? (text.length > 52 ? '…' + text.slice(-51) : text) : 'Ask anything'}
        {typing ? <span style={{ display: 'inline-block', width: 2, height: '1em', background: theme.assistant.ink, marginLeft: 2, verticalAlign: 'middle' }} /> : null}
      </span>
      <span style={{ marginLeft: 'auto', transform: `scale(${1 - press * 0.1})` }}>{/* send button */}</span>
    </div>
  );
};
```

Keep the caret solid (no blink): blinking at 60 fps reads as flicker in a short film.

## Bottom-anchored thread that grows

Each message wraps in a container whose max height grows from 0, so a `justify-content: flex-end` column pushes older messages up smoothly instead of jumping.

```tsx
const Grow: React.FC<{ t: number; at: number; h: number; align: 'flex-start' | 'flex-end'; children: React.ReactNode }> = ({ t, at, h, align, children }) => {
  if (t < at) return null;
  const g = tw(t, at, 0.5, INOUT);       // height
  const p = tw(t, at + 0.06, 0.5);       // content fade + rise, slightly later
  return (
    <div style={{ maxHeight: mix(0, h, g), alignSelf: align, opacity: p, transform: `translateY(${(1 - p) * 10}px)` }}>
      <div style={{ paddingTop: 22 }}>{children}</div>
    </div>
  );
};

// in the thread: <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'flex-end', overflow: 'hidden', maskImage: 'linear-gradient(transparent, black 12%)' }}>
//   {SC.map((_, i) => (<>
//     <Grow t={t} at={SEND[i]}  h={140} align="flex-end"><UserBubble text={PROMPTS[i]} /></Grow>
//     <Grow t={t} at={TOOL[i]}  h={80}  align="flex-start"><ToolRow t={t} at={TOOL[i]} name={TOOLS[i]} /></Grow>
//     <Grow t={t} at={REPLY[i]} h={120} align="flex-start"><Reply t={t} at={REPLY[i]} text={REPLIES[i]} /></Grow>
//   </>))}
// </div>
```

## Tool-call row: shimmer, then tick

```tsx
const ToolRow: React.FC<{ t: number; at: number; name: string }> = ({ t, at, name }) => {
  const done = t >= at + 0.5;
  const sweep = ((t - at) * 1.5) % 1;
  const shimmer: React.CSSProperties = {
    backgroundImage: `linear-gradient(90deg, ${theme.assistant.muted} ${sweep * 140 - 30}%, ${theme.assistant.ink} ${sweep * 140 - 10}%, ${theme.assistant.muted} ${sweep * 140 + 10}%)`,
    WebkitBackgroundClip: 'text', color: 'transparent',
  };
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 18px', borderRadius: 14, boxShadow: `inset 0 0 0 1px ${theme.assistant.hair}` }}>
      <img src={staticFile('brand/icon.svg')} width={24} height={24} />
      <span style={{ fontFamily: 'Mono', ...(done ? { color: theme.assistant.muted } : shimmer) }}>{name}</span>
      <span style={{ marginLeft: 'auto', transform: `scale(${done ? tw(t, at + 0.5, 0.35, SOFTPOP) : 1})` }}>
        {done ? <Tick color={theme.ui.green} /> : <Spinner t={t} />}
      </span>
    </div>
  );
};
```

## Streamed reply

```tsx
const Reply: React.FC<{ t: number; at: number; text: string }> = ({ t, at, text }) => {
  const shown = (t - at) * 8; // words per second
  return (
    <div>
      {text.split(' ').map((w, i, all) => (
        <span key={i} style={{ opacity: interpolate(shown - i, [0, 1.2], [0, 1], clamp) }}>
          {w}{i < all.length - 1 ? ' ' : ''}
        </span>
      ))}
    </div>
  );
};
```

## Card thrown in and out (one card per beat)

```tsx
const Slot: React.FC<{ t: number; from: number; to: number; children: React.ReactNode }> = ({ t, from, to, children }) => {
  if (t < from || t > to + 0.6) return null;
  const inn = sp(t, from, BOUNCY);
  const out = tw(t, to, 0.45, Easing.bezier(0.5, 0, 0.9, 0.4));
  const bump = kick(t, from + 0.38, 0.55); // the tool call's packet lands
  return (
    <div style={{
      position: 'absolute', left: 1036 + (1 - inn) * 320 - out * 260, top: 300 + (1 - inn) * 160 - out * 620, width: 760,
      opacity: Math.min(1, tw(t, from, 0.15)) * (1 - out * out),
      transform: `scale(${mix(0.82, 1, inn) * (1 + bump * 0.03)}) rotate(${(1 - inn) * 7 - out * 9}deg)`,
      transformOrigin: '30% 50%',
    }}>{children}</div>
  );
};

// inside the card, rows slide in one after another and their tags pop with a twist:
// const p = sp(t, at + 0.3 + k * 0.15, BOUNCY);  style={{ opacity: Math.min(1, p * 2), transform: `translateX(${(1 - p) * 90}px)` }}
// const tg = sp(t, at + 0.75 + k * 0.15, BOUNCY); style={{ transform: `scale(${tg}) rotate(${(1 - tg) * 12}deg)` }}
// bars overshoot:   width = value * sp(t, at, { damping: 10, stiffness: 90, mass: 1 })  (show Math.min(1, g) in the number)
// a preview flips to the next record: ph = tw(t, sw - 0.22, 0.44, INOUT); rotateX(ph < 0.5 ? ph * 180 : (ph - 1) * 180)
// a toggle snaps: knob left = 3 + Math.min(1.06, sp(t, at, SNAP)) * 24, knob width + Math.abs(kick(t, at, 0.35)) * 8
```

A card is a header (the product's **full logotype** + a hairline divider + the card title + one right-side value), 3-4 rows, and an optional footer ("Showing 4 of 1,284 results · View in app"). Count-ups use `Math.round(target * tw(...))` with `fontVariantNumeric: 'tabular-nums'`, and pulse once (`scale(1 + kick(...) * 0.18)`) when they land. The card stays on screen while the chat replies; it is thrown out when the next card arrives.

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

## Packet from chat to card

A dotted quadratic arc and a small glowing dot that travels along it, right after the tool call starts. It ties "conversation" to "execution".

```tsx
const Beam: React.FC<{ at: number; from: [number, number]; to: [number, number] }> = ({ at, from, to }) => {
  const t = useT();
  if (t < at || t > at + 1.0) return null;
  const c: [number, number] = [(from[0] + to[0]) / 2 + 20, Math.min(from[1], to[1]) + 100];
  const u = tw(t, at, 0.5, INOUT);
  const q = (k: number, i: 0 | 1) => (1 - k) ** 2 * from[i] + 2 * (1 - k) * k * c[i] + k ** 2 * to[i];
  const fade = 1 - tw(t, at + 0.55, 0.4);
  return (
    <AbsoluteFill style={{ opacity: fade }}>
      <svg width={W} height={H}>
        <path d={`M${from[0]} ${from[1]} Q${c[0]} ${c[1]} ${to[0]} ${to[1]}`} stroke={theme.fx.trail} strokeWidth={2} fill="none" strokeLinecap="round" strokeDasharray="1 9" />
      </svg>
      <div style={{ position: 'absolute', left: q(u, 0) - 9, top: q(u, 1) - 9, width: 18, height: 18, borderRadius: 9, background: theme.ui.white, boxShadow: `0 0 0 5px ${theme.fx.halo}, 0 0 22px ${theme.fx.glow}` }} />
    </AbsoluteFill>
  );
};
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

## Logo slot: full logos with names, switching

Icons alone are not recognised by everyone: show each tool as icon + wordmark, one at a time in a single slot, ending on the one the film uses. The white chip behind springs between lockup widths. The outgoing logo is gone before the next lands.

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

When the backdrop panel rises, the final lockup flies on an arc (`mix` x, y and a scale toward the title bar's size, plus `Math.sin(k * Math.PI) * -110` on y) into the chat window's title bar, where the same mark + wordmark take over. Start the flight only once the window has landed, or the logo arrives in empty sky.

## Camera: follows the action

Keyframes per beat (composer → product card → chat for the reply), each move a soft spring. Translate + scale around a moving focus point; never switch `transform-origin` mid-film (it jumps).

```tsx
type Key = { at: number; z: number; x: number; y: number };
const CAM: Cfg = { damping: 17, stiffness: 70, mass: 1 };
const KEYS: Key[] = [
  { at: 0, z: 1, x: 960, y: 540 },
  ...SC.flatMap((a, i): Key[] => [
    { at: a - 0.1, z: 1.06, x: CHAT_CX, y: 1040 },        // typing: lean on the composer
    { at: CARD[i] - 0.1, z: 1.05, x: CARD_CX, y: 560 },   // the product executes
    { at: REPLY[i] - 0.25, z: 1.05, x: CHAT_CX, y: 820 }, // back to the chat for the reply
  ]),
  { at: END - 0.4, z: 1, x: 960, y: 540 },                 // wide for the finale
];
const Cam: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const t = useT();
  let { z, x, y } = KEYS[0];
  for (let k = 1; k < KEYS.length; k++) {
    const e = sp(t, KEYS[k].at, CAM);
    z += (KEYS[k].z - KEYS[k - 1].z) * e; x += (KEYS[k].x - KEYS[k - 1].x) * e; y += (KEYS[k].y - KEYS[k - 1].y) * e;
  }
  z *= 1 + [...SEND, ...CARD.map((c) => c + 0.38)].reduce((m, at) => m + kick(t, at, 0.45), 0) * 0.012; // punches
  return <AbsoluteFill style={{ transform: `translate(${x * (1 - z)}px, ${y * (1 - z)}px) scale(${z})`, transformOrigin: '0 0' }}>{children}</AbsoluteFill>;
};
```

Keep zoom at or under ~1.07 and check stills at each key: at that scale, the panel's top edge must stay clear of the captions, which sit outside `Cam` with the ground.

## Backdrop: gradients only

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

## Scene transitions

- Hook to beats: the claim's words are thrown up and away; the backdrop panel springs up from ~700 px below (like a phone rising into frame) and the chat window springs in after it; the assistant's lockup flies into the title bar.
- Beat to beat: the caption's number chip flips (rotateX) and its words spring in while the old ones are thrown out; the old card is thrown up-left as the new one is thrown in. The chat window stays, which is what makes the film feel continuous.
- Beats to finale: the chat window drops and fades, the panel springs to full frame, the closing line builds word by word with the logo slamming in where the brand name would be.

Avoid hard cuts and whole-frame crossfades: the film is one continuous space.

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

Check it before building on it: loudness per second (a long quiet stretch means regenerate, models often ignore a prompted structure):

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
