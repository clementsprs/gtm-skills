# Reading a brand from the live site and app

The single biggest quality lever: build the film on the brand's real, current marketing system, read from the live surfaces, not on a generic kit or on what you remember of the brand.

## What to open

1. The marketing page closest to the film's topic (a feature page, an integration page, a launch page).
2. The product app, on a view that resembles what the film's cards will show (a list, a campaign, a report).
3. If a third-party product appears in the film (an AI assistant, a team-chat app, a CRM), its public web UI too.

## The extraction script

Paste in the browser console on each page. Adjust the selectors to the page.

```js
(() => {
  const pick = (sel) => document.querySelector(sel);
  const read = (el) => {
    if (!el) return null;
    const s = getComputedStyle(el);
    return {
      font: s.fontFamily, weight: s.fontWeight, size: s.fontSize,
      tracking: s.letterSpacing, color: s.color, bg: s.backgroundColor,
      radius: s.borderRadius, border: s.border, shadow: s.boxShadow,
    };
  };
  const out = {
    h1: read(pick('h1')),
    h2: read(pick('h2')),
    body: read(pick('p')),
    button: read(pick('a[class*="button"], button')),
    card: read(pick('[class*="card"]')),
    page: read(document.body),
  };
  console.log(JSON.stringify(out, null, 2));
  return out;
})();
```

For the app, also read a table row, a tag or badge, an input, and the selected state of a list item.

## Checklist

- Heading font, weight and letter-spacing (as an em value, for example `-0.03em`), heading ink colour.
- Body and secondary text colours. The site grey and the app grey are often different: keep both.
- Accent colour, its subtle tint, and the primary button style.
- Card radius, border or hairline colour (often an rgba of the text colour at around 10%), card fill.
- Tag and badge colours (info, success, neutral), usually three values each: fill, text, border.
- The **signature visual**: the hero device the page is built around (a product window in a bezel, a gradient sky, a 3D object, a pattern). The film's backdrop should echo it.
- The **background treatment**: plain, patterned, framed with thin rules, gradient.
- Assets: download the SVG logotype and icon the site serves, and any background pattern image. Check the brand's press or brand-assets page for usage rules.

## Writing it down

One `theme.ts`, grouped by surface, each value commented with where it was read and when:

```ts
// Read on yourbrand.com/product/<feature> and app.yourbrand.com, <date>.
export const site = {
  ink: '#111111',     // h1 color
  grey: '#777777',    // hero subline
  rule: '#EEEEEE',    // frame rules
} as const;

export const app = {
  head: '#1F2937',    // table header text
  body: '#334155',    // row text
  hair: 'rgba(31,41,55,0.10)', // every 1px border
  accent: '#3366FF',  // primary button
} as const;

// Third-party UI shown in the film, transcribed from its public look.
export const assistant = { bg: '#FAFAF7', bubble: '#F0EEE8', ink: '#141414', mark: '#D97757' } as const;
```

The hex values above are placeholders; replace every one with what you read. After this file exists, no colour literal appears anywhere else in the project.

## When you can't open a browser

Say so, and ask for: a full-page screenshot of the marketing page, two app screenshots, the logo files, and the brand's font names. Never fill the theme from memory.
