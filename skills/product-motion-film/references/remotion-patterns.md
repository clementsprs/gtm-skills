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

## Timeline: safe pacing constants

Declare the whole timeline at the top of the film, in seconds, derived from the beat starts. Changing one beat start shifts everything inside it.

```ts
const SWAP = 3.0;                              // hook line A → product line
const PANEL = 4.6;                             // backdrop panel rises
const BEAT = 4.7;                              // per beat: 4.5-5 s reads at first watch, 3.2 s does not
const SC = [5.5, 5.5 + BEAT, 5.5 + 2 * BEAT, 5.5 + 3 * BEAT] as const;
const SEND = SC.map((a) => a + 1.15);          // prompt typed 0 → 1.1, sent at 1.15
const TOOL = SC.map((a) => a + 1.4);           // tool-call row appears
const CARD = SC.map((a) => a + 1.6);           // product card enters
const REPLY = SC.map((a) => a + 2.2);          // reply streams at ~8 words/s
const END = SC[3] + BEAT + 1.2;                // finale starts
export const SECONDS = END + 3.6;              // finale holds ~1.5 s after the URL lands
export const FILM_FRAMES = Math.round(SECONDS * FPS);
```

Card details (a counter, a variable filling in, a highlight, ticks) run from `CARD + 1.1` to `CARD + 2.9`.

## Word: arrives soft, settles sharp

Blur only small type, and only while it moves. Stagger words 0.06-0.1 s.

```tsx
export const Word: React.FC<{ t: number; at: number; ink: string; children: React.ReactNode }> = ({ t, at, ink, children }) => {
  const p = tw(t, at, 0.7);
  return (
    <span style={{
      display: 'inline-block', color: ink, opacity: p,
      transform: `translateY(${(1 - p) * 16}px)`,
      filter: p < 1 ? `blur(${(1 - p) * 5}px)` : undefined,
    }}>{children}</span>
  );
};

// a two-line claim: ink line then grey line
const Claim: React.FC<{ t: number; at: number; a: string; b: string }> = ({ t, at, a, b }) => {
  const words = (s: string, from: number, ink: string) =>
    s.split(' ').map((w, k) => <Word key={k} t={t} at={from + k * 0.08} ink={ink}>{w}&nbsp;</Word>);
  const aCount = a.split(' ').length;
  return (
    <div style={{ textAlign: 'center' }}>
      <div>{words(a, at, theme.site.ink)}</div>
      <div>{words(b, at + aCount * 0.08 + 0.1, theme.site.grey)}</div>
    </div>
  );
};
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

## Card entrance and exit (one card per beat)

```tsx
const Slot: React.FC<{ t: number; from: number; to: number; children: React.ReactNode }> = ({ t, from, to, children }) => {
  if (t < from || t > to + 0.6) return null;
  const inn = tw(t, from, 0.75);
  const out = tw(t, to, 0.45, INOUT);
  return (
    <div style={{
      position: 'absolute', left: 1036, top: 300, width: 760,
      opacity: inn * (1 - out),
      transform: `translateY(${(1 - inn) * 50 - out * 30}px) scale(${mix(0.97, 1, inn)})`,
      transformOrigin: '50% 0',
    }}>{children}</div>
  );
};

// rows inside the card stagger in, 0.18 s apart
// const p = tw(t, at + 0.3 + k * 0.18, 0.6);  style={{ opacity: p, transform: `translateY(${(1 - p) * 12}px)` }}
```

A card is a header (icon + title + one right-side value), 3-4 rows, and an optional footer ("Showing 4 of 1,284 results · View in app"). Count-ups use `Math.round(target * tw(...))` with `fontVariantNumeric: 'tabular-nums'` so digits don't jitter.

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

## Logos that pop in and stay

```tsx
const LOGOS = ['logos/a.svg', 'logos/b.svg', 'logos/c.svg', 'logos/d.svg'];
const Tiles: React.FC<{ t: number }> = ({ t }) => (
  <>
    {LOGOS.map((src, i) => {
      const at = 0.2 + i * 0.16;
      const p = tw(t, at, 0.8, SOFTPOP); // scale with a small overshoot
      const f = tw(t, at, 0.35);         // quick fade so the overshoot is visible
      return (
        <div key={src} style={{ position: 'absolute', left: W / 2 + (i - 1.5) * 164 - 64, top: 300, width: 128, height: 128, borderRadius: 28, background: theme.ui.white, boxShadow: `0 0 0 1px ${theme.ui.line}, 0 10px 30px ${theme.ui.shadow}`, display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: f, transform: `scale(${p})` }}>
          <Img src={staticFile(src)} style={{ width: 59, height: 59 }} />
        </div>
      );
    })}
  </>
);
```

A nice transition: when the backdrop panel rises, one tile (the assistant's) shrinks and flies onto the mark in the chat window's title bar (`mix` its x, y and size between the two positions with `INOUT`), while the others lift out.

## Camera: one slow push

```tsx
const Cam: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const t = useT();
  const k = 1 + 0.035 * tw(t, SC[0], END - SC[0], Easing.bezier(0.45, 0, 0.55, 1))
              - 0.035 * tw(t, END - 0.3, 0.9, INOUT); // settle back for the finale
  return <AbsoluteFill style={{ transform: `scale(${k})`, transformOrigin: '50% 52%' }}>{children}</AbsoluteFill>;
};
```

Captions and the background ground sit outside `Cam` so they don't drift.

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

- Hook to beats: the claim lifts out (24 px up + fade, 0.5 s `INOUT`) while the backdrop panel rises from 120 px below.
- Beat to beat: the caption and the card leave together (30 px lift, 0.45 s); the next caption and card enter 0.05 s later. The chat window stays, which is what makes the film feel continuous.
- Beats to finale: the chat window drops 40 px and fades in 0.6 s, the panel grows to full frame, the closing line arrives word by word.

Avoid hard cuts and whole-frame crossfades: the film is one continuous space.

## Sound

```tsx
const Sound: React.FC = () => {
  const vol = (fr: number) => interpolate(fr / FPS, [0, 0.5, SECONDS - 2, SECONDS - 0.15], [0, 0.75, 0.75, 0], clamp);
  const at = (sec: number, file: string, v: number, dur = 1) => (
    <Sequence key={`${file}${sec}`} from={Math.round(sec * FPS)} durationInFrames={Math.round(dur * FPS)}>
      <Audio src={staticFile(`audio/${file}`)} volume={v} />
    </Sequence>
  );
  return (
    <>
      <Audio src={staticFile('audio/bed.mp3')} volume={vol} />
      {SEND.map((s) => at(s, 'click.mp3', 0.28))}
      {[0.2, 0.36, 0.52, 0.68].map((s) => at(s, 'pop.mp3', 0.12))}
      {[PANEL - 0.1, END - 0.1].map((s) => at(s, 'whoosh.mp3', 0.13))}
      {at(PAYOFF, 'chime.mp3', 0.18, 3)}
    </>
  );
};
```

Use a licensed track or one you generated with a music model, and SFX from a licensed library or generated. Keep effect volumes low: they accent, they don't announce.

## Gotchas

- `<Img>` with an SVG whose paths use `fill="currentColor"` renders black. Edit the SVG to a real colour (keep a white variant for dark backdrops).
- Never `Math.random()` or `Date.now()` in a component: frames render in parallel and out of order. Use `rnd(i, seed)`.
- Icon fonts need their own `@font-face` and a licence that covers video. Simple inline SVG line icons avoid both questions.
- Long prompts overflow the composer: show the tail with a leading ellipsis rather than wrapping.
- Check stills at every beat at `--scale=0.5` before rendering: overlap, wrapping and the camera push cropping the edges are the usual failures.
- Contact sheet for review: `ffmpeg -i out/review-1080p.mp4 -vf "select='not(mod(n\,300))',scale=960:-1,tile=2x3" -frames:v 1 out/sheet.png`.
