# Accessibility Guardrails

## Core Principle

Neumorphism is easy to make beautiful and easy to make unusable. The soft same-surface look tends to reduce contrast and weaken affordance, so accessibility must be explicit rather than assumed.

## Main Risks

- text and icons blend into the background
- buttons look decorative instead of clickable
- inputs and cards become hard to distinguish
- focus states disappear into the shadows
- disabled and inactive states become ambiguous

## Guardrails

### 1. Keep text readable

- body text should meet normal accessibility contrast targets
- labels and helper text should remain readable without relying on shadows
- muted text should still be genuinely legible, not merely stylish

### 2. Make controls obviously interactive

- use consistent patterns for raised buttons and inset inputs
- add clear labels or icons with enough contrast
- use hover, active, and focus states that are visible without guessing

If users cannot quickly tell whether a surface is a button, the effect is too subtle.

### 3. Preserve focus visibility

- always include a visible focus ring, border, accent glow, or equivalent
- do not rely on the default neumorphic shadow to indicate keyboard focus

Pure style is not more important than keyboard usability.

### 4. Strengthen primary actions

- use accent color, stronger contrast, or a hybrid filled treatment for the main CTA
- do not let the most important action blend into the background

### 5. Be selective

The safest use of neumorphism is selective:

- controls
- summary widgets
- meters
- toggles
- top-level panels

Avoid applying it to every row, every container, and every state layer.

### 6. Test with reduced visual assumptions

Review the interface in these conditions:

- lower screen brightness
- bright ambient light
- keyboard-only navigation
- grayscale or reduced color reliance
- zoomed text and browser zoom

If the UI stops making sense when the shadows are harder to perceive, the hierarchy is too dependent on the effect.

## Safe Compromises

These changes improve usability without abandoning the style:

- slightly darker text
- slightly stronger border on form controls
- more distinct focus ring
- accent-backed primary CTA
- flatter treatment on dense data regions
- clearer error and destructive states

## Review Checklist

- Can users distinguish page background, cards, inputs, and buttons quickly?
- Is the primary action obvious?
- Are hover, active, focus, disabled, and error states all visible?
- Does the UI still read clearly if the shadows become faint?
- Is neumorphism helping the interface, or only decorating it?
