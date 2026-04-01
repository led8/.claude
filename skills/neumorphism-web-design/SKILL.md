---
name: neumorphism-web-design
description: Design soft, tactile web interfaces in the neumorphism style.
---

# Neumorphism Web Design

## Overview

Use this skill when the user explicitly wants a neumorphic interface or when the design direction calls for soft, same-surface depth with subtle highlights and shadows. Treat neumorphism as a visual style layer, not as a reason to weaken usability.

The style works best for calm dashboards, finance widgets, control panels, onboarding flows, settings screens, and curated marketing sections with a limited number of primary actions. It is a poor default for dense enterprise CRUD screens, high-noise content layouts, or interfaces that already depend on strong visual separation.

## Core Style Rules

- Use one dominant surface color for the page and most components.
- Create depth with a light highlight and a darker shadow instead of hard borders.
- Favor rounded corners, soft spacing, and low visual noise.
- Keep accent color usage sparse and intentional.
- Make interactive states obvious even if that means breaking the pure aesthetic slightly.

## Workflow

1. Confirm that neumorphism is the requested direction and that the product can tolerate a soft, low-contrast visual language.
2. Start from a surface system: page background, raised surface, inset surface, and one restrained accent color.
3. Decide which components should feel **raised** and which should feel **inset**.
4. Build the minimal component set first: button, card, input, toggle, nav item, and one data display pattern.
5. Add hover, active, disabled, focus, and error states early so controls stay usable.
6. Review contrast, focus visibility, and affordance clarity before adding extra decoration.
7. If the interface starts feeling washed out or ambiguous, reduce neumorphism and restore clearer separation.

## Raised vs Inset

- Use **raised** treatment for buttons, floating actions, cards, panels, icon chips, and key summary widgets.
- Use **inset** treatment for inputs, pressed states, sliders, segmented selections, and recessed containers.
- Use **flat or accent-backed** treatment for the most important CTA when a pure neumorphic button is too subtle.

## Read The Right Reference

- Read [references/visual-foundations.md](references/visual-foundations.md) for color, shadows, radius, spacing, and composition rules.
- Read [references/component-patterns.md](references/component-patterns.md) for buttons, cards, forms, nav, dashboards, and mobile patterns.
- Read [references/css-recipes.md](references/css-recipes.md) for reusable CSS variables and component recipes.
- Read [references/accessibility-guardrails.md](references/accessibility-guardrails.md) before shipping or reviewing any neumorphic UI.

## Decision Rules

- If the layout is content-heavy, use neumorphism sparingly on controls and summary cards instead of every surface.
- If the user needs a premium but calm look, favor light backgrounds, subtle depth, and one bright accent color.
- If the user needs strong information hierarchy, mix neumorphic surfaces with clearer typography and selective high-contrast sections.
- If a control looks decorative instead of clickable, increase state contrast, add a clearer label, or abandon the effect for that component.
- If accessibility and affordance conflict with the style, preserve accessibility.

## Delivery Notes

- Prefer HTML and CSS patterns that can be adapted to the repository's stack instead of locking the skill to one framework.
- Keep the shadow system consistent across the page; random shadow values break the illusion of one shared material.
- Avoid adding noise such as glass effects, heavy textures, or multiple competing gradients unless the user explicitly asks for a hybrid style.
