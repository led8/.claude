# CSS Recipes

## Token Starter

```css
:root {
  --surface-page: #e7eef8;
  --surface-raised: #e9f0fa;
  --surface-inset: #e3ebf5;
  --text-strong: #42526b;
  --text-muted: #7f91aa;
  --accent: #2d8cff;
  --accent-strong: #1e6fe0;
  --shadow-dark: #c7d3e3;
  --shadow-light: #f8fbff;
  --radius-md: 16px;
  --radius-lg: 24px;
  --shadow-raised:
    10px 10px 22px var(--shadow-dark),
    -10px -10px 22px var(--shadow-light);
  --shadow-inset:
    inset 8px 8px 16px #d2dceb,
    inset -8px -8px 16px #f7fbff;
  --shadow-focus:
    0 0 0 3px rgba(45, 140, 255, 0.22);
}

body {
  background: var(--surface-page);
  color: var(--text-strong);
}
```

Adjust values together. A single changed shadow color can break the illusion.

## Raised Surface

```css
.neu-raised {
  background: var(--surface-raised);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-raised);
}
```

Use for cards, quiet buttons, icon chips, and floating widgets.

## Inset Surface

```css
.neu-inset {
  background: var(--surface-inset);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-inset);
}
```

Use for inputs, pressed states, tracks, and recessed panels.

## Button Pattern

```css
.neu-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  min-height: 48px;
  padding: 0 1.25rem;
  border: 0;
  border-radius: 999px;
  background: var(--surface-raised);
  color: var(--text-strong);
  box-shadow: var(--shadow-raised);
  transition: transform 120ms ease, box-shadow 120ms ease;
}

.neu-button:hover {
  transform: translateY(-1px);
}

.neu-button:active {
  box-shadow: var(--shadow-inset);
  transform: translateY(0);
}

.neu-button:focus-visible {
  outline: none;
  box-shadow: var(--shadow-raised), var(--shadow-focus);
}
```

## Primary CTA Pattern

```css
.neu-button-primary {
  background: linear-gradient(135deg, #47b9ff, var(--accent));
  color: white;
  box-shadow:
    10px 10px 22px rgba(177, 196, 220, 0.7),
    -8px -8px 18px rgba(255, 255, 255, 0.5);
}
```

This is intentionally a small break from pure same-surface neumorphism. It makes the primary action easier to recognize.

## Input Pattern

```css
.neu-input {
  width: 100%;
  min-height: 48px;
  padding: 0.85rem 1rem;
  border: 1px solid transparent;
  border-radius: 18px;
  background: var(--surface-inset);
  color: var(--text-strong);
  box-shadow: var(--shadow-inset);
}

.neu-input::placeholder {
  color: var(--text-muted);
}

.neu-input:focus {
  outline: none;
  border-color: rgba(45, 140, 255, 0.35);
  box-shadow: var(--shadow-inset), var(--shadow-focus);
}
```

## Icon Chip Pattern

```css
.neu-icon-chip {
  display: grid;
  place-items: center;
  width: 48px;
  aspect-ratio: 1;
  border-radius: 16px;
  background: var(--surface-raised);
  box-shadow: var(--shadow-raised);
  color: var(--text-muted);
}

.neu-icon-chip[aria-current="page"] {
  color: var(--accent);
}
```

## Panel Strategy

When a screen has many cards:

- give the outer page or shell the weakest depth
- give the main cards the strongest depth
- keep inner subsections flatter
- reserve inset treatments for interactive wells, inputs, and pressed states

Too many nested shadows makes the UI feel swollen instead of refined.
