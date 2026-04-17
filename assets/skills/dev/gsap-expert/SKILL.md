---
name: gsap-expert
description: Use when building animations with GSAP (GreenSock Animation Platform) in any JavaScript/TypeScript project — React, Next.js, Vue, Svelte, or vanilla JS. Covers core tweens, timelines, ScrollTrigger, SplitText, MorphSVG, DrawSVG, MotionPath, Flip, Observer, Draggable. Invoke for scroll-based animations, hero reveals, page transitions, SVG morphing, text animations, parallax effects, or any motion design work. As of 2024 GSAP is 100% free including all premium plugins (Webflow acquisition).
license: MIT
metadata:
  author: antifragile-claude-code
  version: "1.0.0"
  domain: frontend-animation
  triggers: gsap, greensock, scrolltrigger, splittext, timeline, tween, animation, morphsvg, drawsvg, motionpath, flip, scroll animation, parallax, hero animation, page transition
  role: specialist
  scope: implementation
  output-format: code
  related-skills: react-expert, nextjs-developer, frontend-design, ui-styling
---

<!-- Created: 18:45 17-Apr-2026 -->

# GSAP Expert

Senior motion-design specialist for GSAP 3.12+. GSAP (GreenSock Animation Platform) is the industry-standard JS animation library. **Webflow acquired GreenSock in 2024 and made 100% of GSAP — including all bonus/Club plugins — free for everyone, including commercial use.**

## When to Use This Skill

- Any scroll-triggered animation (`ScrollTrigger`)
- Hero section reveals, staggered entrances, complex timelines
- SVG animation: morphing paths, drawing strokes, motion-path following
- Text animations: word/char/line splits, typewriter, reveal
- Layout transitions with `Flip` plugin (FLIP technique)
- Drag interactions (`Draggable`, `InertiaPlugin`)
- Any animation where CSS `@keyframes` or Framer Motion feels limiting
- Migrating away from Framer Motion, AOS, or jQuery animations

## Installation

### npm / pnpm (recommended for apps)
```bash
pnpm add gsap
# or
npm install gsap
```
All plugins (ScrollTrigger, SplitText, MorphSVG, DrawSVG, MotionPath, Flip, Observer, Draggable, ScrollTo, ScrollSmoother, Physics2D, CustomEase, etc.) are bundled in the single `gsap` package — no separate installs needed.

### CDN (for static sites/prototypes)
```html
<script src="https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/gsap.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/ScrollTrigger.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/SplitText.min.js"></script>
```

### React/Next.js setup
Install the official hook package for zero-boilerplate context:
```bash
pnpm add gsap @gsap/react
```
Use `useGSAP()` — it auto-cleans animations on unmount and scopes selectors.

## Core API Cheat Sheet

### 1. Basic tween
```js
import gsap from "gsap";

gsap.to(".box", { x: 300, rotate: 360, duration: 2, ease: "power2.inOut" });
gsap.from(".box", { opacity: 0, y: 50, duration: 1 });
gsap.fromTo(".box", { x: 0 }, { x: 300, duration: 1 });
gsap.set(".box", { opacity: 0 }); // instant, no animation
```

### 2. Timeline (sequenced animations)
```js
const tl = gsap.timeline({ defaults: { duration: 1, ease: "power2.out" } });
tl.from(".hero-title", { y: 100, opacity: 0 })
  .from(".hero-sub",   { y: 50,  opacity: 0 }, "-=0.5") // overlap by 0.5s
  .from(".hero-cta",   { scale: 0.8, opacity: 0 }, "<"); // start with previous
```

### 3. Stagger
```js
gsap.from(".card", {
  y: 60, opacity: 0, duration: 0.8,
  stagger: { amount: 0.6, from: "start", grid: "auto" }
});
```

### 4. ScrollTrigger (most-used plugin)
```js
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
gsap.registerPlugin(ScrollTrigger);

gsap.to(".parallax", {
  yPercent: -50,
  ease: "none",
  scrollTrigger: {
    trigger: ".parallax-section",
    start: "top bottom",   // when top of trigger hits bottom of viewport
    end: "bottom top",     // when bottom of trigger hits top of viewport
    scrub: true,           // tie animation progress to scroll
    markers: false         // set true while debugging
  }
});

// Pin a section
ScrollTrigger.create({
  trigger: ".pin-section",
  start: "top top",
  end: "+=2000",
  pin: true,
  scrub: 1
});
```

### 5. SplitText (word/char animation)
```js
import { SplitText } from "gsap/SplitText";
gsap.registerPlugin(SplitText);

const split = new SplitText(".headline", { type: "chars,words" });
gsap.from(split.chars, { y: 80, opacity: 0, stagger: 0.02, duration: 0.8 });
```

## React / Next.js Pattern (with `@gsap/react`)

```tsx
"use client";
import { useRef } from "react";
import gsap from "gsap";
import { useGSAP } from "@gsap/react";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(useGSAP, ScrollTrigger);

export function Hero() {
  const container = useRef<HTMLDivElement>(null);

  useGSAP(() => {
    // Selectors are auto-scoped to `container`
    gsap.from(".hero-title", {
      y: 100, opacity: 0, duration: 1, ease: "power3.out"
    });

    gsap.to(".parallax-bg", {
      yPercent: -30,
      ease: "none",
      scrollTrigger: {
        trigger: container.current,
        start: "top bottom",
        end: "bottom top",
        scrub: true
      }
    });
  }, { scope: container }); // auto-cleanup on unmount

  return (
    <div ref={container} className="relative overflow-hidden">
      <div className="parallax-bg absolute inset-0 bg-gradient-to-b from-indigo-900 to-black" />
      <h1 className="hero-title relative">Your Headline</h1>
    </div>
  );
}
```

## Next.js App Router Gotchas

1. **Must be client component**: add `"use client"` at the top.
2. **Register plugins ONCE** at module scope — not inside the component.
3. **SSR safety**: GSAP touches `window`. `useGSAP` handles this; for custom effects, wrap in `useEffect` or check `typeof window !== "undefined"`.
4. **ScrollTrigger + Next.js navigation**: Call `ScrollTrigger.refresh()` after layout changes or route transitions if scroll positions get stale.
5. **Strict Mode double-render**: `useGSAP` handles cleanup correctly; do not use bare `useEffect` with GSAP or you'll get duplicated animations in dev.

## Common Patterns

### Parallax on scroll
```js
gsap.utils.toArray<HTMLElement>(".parallax").forEach((el) => {
  const speed = parseFloat(el.dataset.speed || "0.5");
  gsap.to(el, {
    yPercent: -100 * speed,
    ease: "none",
    scrollTrigger: { trigger: el, start: "top bottom", end: "bottom top", scrub: true }
  });
});
```

### Horizontal scroll section
```js
const sections = gsap.utils.toArray(".panel");
gsap.to(sections, {
  xPercent: -100 * (sections.length - 1),
  ease: "none",
  scrollTrigger: {
    trigger: ".container",
    pin: true,
    scrub: 1,
    snap: 1 / (sections.length - 1),
    end: () => "+=" + document.querySelector(".container")!.offsetWidth
  }
});
```

### Counter / number tween
```js
const obj = { val: 0 };
gsap.to(obj, {
  val: 1000, duration: 2, ease: "power1.out",
  onUpdate: () => el.textContent = Math.round(obj.val).toString()
});
```

### Flip layout transition
```js
import { Flip } from "gsap/Flip";
gsap.registerPlugin(Flip);

const state = Flip.getState(".item");
// ... change layout (e.g., toggle a class, reorder DOM) ...
Flip.from(state, { duration: 0.7, ease: "power2.inOut", stagger: 0.05 });
```

## Easing Quick Reference
- **Natural**: `power1.out`, `power2.out`, `power3.out` (smoother as number goes up)
- **Snappy**: `back.out(1.7)`, `expo.out`
- **Bouncy**: `elastic.out(1, 0.3)`, `bounce.out`
- **Linear (scroll-tied)**: `"none"` — always use this with `scrub: true`
- **Custom**: `CustomEase.create("myEase", "M0,0 C0.4,0 0.2,1 1,1")` (CustomEase is now free)

## Performance Checklist

- Animate `transform` and `opacity` — avoid `width`, `height`, `top`, `left` (triggers layout)
- Use `force3D: true` (default) to enable GPU compositing
- Batch `ScrollTrigger` reads with `ScrollTrigger.batch()` for many elements
- Call `ScrollTrigger.refresh()` after images/fonts load, not on every resize
- Use `willChange: "transform"` sparingly; GSAP handles this automatically
- For 60fps on mobile: keep simultaneous animations under ~30 elements

## Framework Alternatives — When to Pick GSAP

| Use case | Pick |
|---|---|
| Scroll-based storytelling, parallax, pinning | **GSAP + ScrollTrigger** |
| Simple mount/unmount transitions in React | Framer Motion |
| Complex timelines, SVG morph, text splits | **GSAP** |
| Physics-based drag, spring animations | Framer Motion or GSAP Physics2D |
| Page-level route transitions (Next.js) | **GSAP Flip** or `next-view-transitions` |
| 3D (Three.js scenes) | **GSAP** (animates Three objects perfectly) |

## Migration Tips

- **From Framer Motion**: GSAP is imperative, not declarative — you call `gsap.to()` instead of passing `animate={}` props. Timelines replace `<AnimatePresence>` + `variants`.
- **From AOS**: ScrollTrigger replaces AOS with infinitely more control. Swap `data-aos` attrs for a single `useGSAP` block.
- **From jQuery `.animate()`**: Literally 20× faster and supports transforms/colors/SVG out of the box.

## Official References
- Docs: https://gsap.com/docs/v3/
- Plugins: https://gsap.com/docs/v3/Plugins/
- React guide: https://gsap.com/resources/React
- Starter templates: https://gsap.com/resources/nextjs/ and https://stackblitz.com/@gsap-dev
- Cheat sheet: https://gsap.com/cheatsheet/
- Ease visualizer: https://gsap.com/docs/v3/Eases
- Forum (authoritative answers from GreenSock team): https://gsap.com/community/

## Deliverable Quality Bar

When writing GSAP code for a user:
1. **Always `registerPlugin` at module scope**, never inside hooks/components
2. **Always use `useGSAP` in React** — never bare `useEffect` for animations
3. **Always clean up ScrollTrigger instances** on unmount (`useGSAP` does this automatically)
4. **Test with `markers: true`** for any ScrollTrigger, then remove before shipping
5. **Prefer `xPercent`/`yPercent` over `x`/`y`** for responsive animations
6. **Use `gsap.context()`** if not using `@gsap/react` — scopes selectors and enables cleanup
7. **Respect `prefers-reduced-motion`**:
```js
const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
if (reduceMotion) gsap.globalTimeline.timeScale(0); // or skip animations entirely
```
