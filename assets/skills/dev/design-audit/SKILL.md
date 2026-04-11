# /design-audit — Post-Implementation Design Checklist

## Trigger
User says: "design-audit", "check my design", "audit this", "review the UI", "anything missing?", or after completing a UI component/page

## Purpose
Catch everything that gets left behind: inconsistent spacing, missing states, broken responsive, accessibility gaps, and incomplete interactions.

## Audit Checklist (run ALL sections)

### 1. Spacing Consistency
```bash
# Find spacing classes in the component
grep -oE '(p|m|gap|space)[-_](x|y|t|b|l|r|s|e)?-[0-9.]+' FILE | sort | uniq -c | sort -rn
```
- Check: Are sibling elements using the same spacing?
- Check: Is padding consistent within same nesting level?
- Check: Are section gaps using the scale (6, 8, 12, 16, 24)?
- Flag: Any arbitrary values like `p-[17px]`?
- Flag: Mixing `gap` with child margins?

### 2. Responsive Breakpoints
```bash
grep -cE 'sm:|md:|lg:|xl:' FILE
```
- Check: Does every text size > `text-xl` have responsive variants?
- Check: Grid/flex layouts adapt (`grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`)?
- Check: Padding increases on larger screens (`px-4 sm:px-6 lg:px-8`)?
- Check: Hidden/shown elements at breakpoints make sense?
- Flag: Any component that looks broken below 375px width?

### 3. Interactive States (MOST COMMONLY MISSED)
For every button, link, and interactive element:
- [ ] `hover:` state present?
- [ ] `focus-visible:` ring/outline present?
- [ ] `disabled:` opacity + cursor-not-allowed?
- [ ] `active:` scale or color shift for buttons?
- [ ] Loading state (spinner or skeleton)?

### 4. Empty & Error States
- [ ] What shows when data is empty (0 items)?
- [ ] What shows on API error?
- [ ] What shows while loading (skeleton, not just spinner)?
- [ ] Form validation errors — inline, not just toast?
- [ ] 404/not found state for dynamic pages?

### 5. Typography Hierarchy
- [ ] Only ONE `h1` per page?
- [ ] Heading sizes decrease properly (h1 > h2 > h3)?
- [ ] Body text is `text-sm` or `text-base` (not too small)?
- [ ] Text colors follow hierarchy (gray-900 → gray-600 → gray-500)?
- [ ] Line height readable for body text (`leading-relaxed` for long text)?

### 6. Dark Mode
```bash
grep -cE 'dark:' FILE
```
- [ ] Background colors have dark variants?
- [ ] Text colors have dark variants?
- [ ] Borders have dark variants (`border-gray-200 dark:border-gray-800`)?
- [ ] Shadows appropriate for dark mode?
- [ ] Images/icons visible on dark backgrounds?

### 7. Accessibility
- [ ] All images have `alt` text?
- [ ] Form inputs have associated `<label>`?
- [ ] Buttons have text or `aria-label`?
- [ ] Color contrast meets WCAG AA (4.5:1 for text)?
- [ ] Keyboard navigation works (Tab order logical)?
- [ ] `sr-only` text for icon-only buttons?

### 8. Animations & Transitions
- [ ] Hover transitions present (`transition-colors duration-200`)?
- [ ] No layout shift on hover (don't change padding/border-width)?
- [ ] Loading skeletons use `animate-pulse`?
- [ ] Modals/dropdowns have enter/leave transitions?
- [ ] Respects `prefers-reduced-motion`?

### 9. Polish Details
- [ ] Consistent border radius (`rounded-lg` for most, `rounded-xl` for cards)?
- [ ] Consistent shadow usage (`shadow-sm` default, `shadow-md` for elevated)?
- [ ] Proper truncation for long text (`truncate` or `line-clamp-2`)?
- [ ] Icons same size as adjacent text?
- [ ] No orphaned words in headings (use `text-balance` or `max-w-` on headings)?
- [ ] Cursor styles correct (`cursor-pointer` on clickable non-buttons)?

## Output Format
Produce a scorecard:
```
DESIGN AUDIT — [Component Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Spacing:      ✅ / ⚠️ / ❌  [notes]
Responsive:   ✅ / ⚠️ / ❌  [notes]
States:       ✅ / ⚠️ / ❌  [notes]
Empty/Error:  ✅ / ⚠️ / ❌  [notes]
Typography:   ✅ / ⚠️ / ❌  [notes]
Dark Mode:    ✅ / ⚠️ / ❌  [notes]
Accessibility:✅ / ⚠️ / ❌  [notes]
Animations:   ✅ / ⚠️ / ❌  [notes]
Polish:       ✅ / ⚠️ / ❌  [notes]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Score: X/9
Top 3 fixes: [actionable items]
```

## Rules
- Run EVERY section, not just the obvious ones
- Be specific: "line 42: `mb-3` should be `mb-6` to match siblings" not "fix spacing"
- Suggest exact Tailwind classes, not vague "improve this"
- Focus on the 3 highest-impact fixes first
