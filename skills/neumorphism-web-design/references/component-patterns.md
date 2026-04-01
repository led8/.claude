# Component Patterns

## Buttons

### Secondary button

- raised surface
- same-color background as the surrounding page
- stronger label contrast than the container
- hover increases depth slightly
- active state flips to inset or reduces the outer shadows

### Primary button

Pure neumorphism can make the main CTA too quiet. Use one of these safer patterns:

- accent-filled button with softer shadows
- raised button with accent text and icon plus a clearer hover state
- hybrid button: neutral outer surface with an accent inner fill

### Icon button

- circular or rounded-square raised chip
- icon stays darker than surrounding chrome
- active state can use accent icon color
- include a visible focus style even if it is not perfectly neumorphic

## Cards and Panels

- Use raised cards for summaries, balances, profile blocks, and compact charts.
- Keep the card background very close to the page background.
- Use typography and spacing to separate sections instead of adding many nested shadows.
- If a card contains many widgets, let the outer card carry the main depth and keep inner sections flatter.

## Inputs

Inputs usually work better as inset surfaces:

- input shell looks pressed into the page
- placeholder text is muted but still readable
- typed text uses stronger contrast
- focus state should add a border, ring, or accent glow

Do not rely on the inset shadow alone to communicate focus.

## Switches and Toggles

- track can be inset
- knob can be raised
- active state may add accent fill behind the knob

This is one of the most natural neumorphic patterns because the physical metaphor is clear.

## Navigation

### Top or side nav

- keep the nav container relatively flat or lightly raised
- make active items clearly raised or accented
- do not apply equal depth to every icon or every row

### Bottom tab bar

- slightly raised container
- active tab uses accent icon color plus clearer depth
- inactive items stay quieter and flatter

## Sliders and Progress

- track often works as inset
- thumb works as raised
- progress arcs can use soft neutral shells with one vivid accent segment

Circular progress indicators are a strong match for neumorphism because they benefit from soft curvature and limited chrome.

## Lists and Transactions

Neumorphism can make rows blend together. To prevent that:

- keep list rows slightly raised
- use stronger text hierarchy
- use color to mark directionality such as debit vs credit
- avoid stacking too many nested inset containers in one row

## Dashboards

The style works well for:

- compact KPI cards
- circular meters
- sleep, finance, wellness, and smart-home control panels
- mobile account summary screens

Keep charts simple and let the surface do part of the branding. Busy data visualization plus soft surfaces often becomes muddy.

## Error and Destructive States

These states often need stronger contrast than the style wants.

- use clearer borders or fills
- keep destructive actions visually explicit
- do not hide danger inside a barely tinted neumorphic chip

When clarity matters, let the status color dominate more than the style.
