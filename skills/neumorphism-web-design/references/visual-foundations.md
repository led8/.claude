# Visual Foundations

See this visual [Example](example.png) for a reference implementation of the visual style.

## Mental Model

Neumorphism makes components feel molded from the same material as the page background. The effect depends on restraint:

- background and components sit close in value
- the highlight is soft and usually comes from the upper-left
- the shadow is soft and usually falls to the lower-right
- borders, if present, are faint and supportive rather than dominant

If the component color drifts too far from the page color, it stops feeling neumorphic and starts feeling like a normal card with shadows.

## Surface System

Start with a compact token set:

- `--surface-page`: page background
- `--surface-raised`: slightly lighter or richer than the page
- `--surface-inset`: same family, often a touch darker
- `--shadow-dark`: lower-right shadow
- `--shadow-light`: upper-left highlight
- `--accent`: one clear action color
- `--text-strong`, `--text-muted`

Typical light theme direction:

- page: cool gray-blue or warm gray
- raised surface: almost the same as the page
- inset surface: almost the same as the page, slightly darker
- accent: one clean blue, cyan, coral, or mint

Avoid saturated backgrounds. The calm surface is what makes the depth feel tactile.

## Depth Recipe

Use paired shadows rather than one dramatic shadow:

- dark shadow for depth
- light shadow for the embossed highlight

Typical characteristics:

- blur is wider than in flat UI
- offsets are modest
- opacity stays low
- the highlight is never pure white at full strength

For a raised element, the pair goes outside the component. For an inset element, the pair goes inside the component with `inset`.

## Shape Language

- Prefer medium-to-large radii.
- Favor simple geometry: rounded rectangles, pills, circles.
- Keep spacing generous so shadows have room to breathe.
- Use thin borders only when the component needs help separating from the page.

Sharp corners, dense grids, and tight spacing fight the visual language.

## Typography

Typography should compensate for the softness of the surfaces:

- use crisp, readable type
- keep body text darker than the surrounding UI chrome
- use weight and scale for hierarchy instead of relying on heavy dividers
- keep labels short and explicit

The interface should still read clearly if the shadows disappear.

## Color Strategy

The safest pattern is:

- one muted background family
- one accent family
- one error family
- one success family if needed

Use the accent sparingly on:

- the primary CTA
- active nav items
- chart highlights
- focused sliders or switches

If every element uses the accent, the composition loses its premium feel.

## Composition

Neumorphism works best when the page has:

- low clutter
- clear groups
- larger components
- visible whitespace

It works poorly when the page has:

- long data tables
- dense forms
- many competing states
- complicated nested cards

In those cases, use the style selectively on the top layer of interaction.
