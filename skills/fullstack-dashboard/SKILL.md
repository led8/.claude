---
name: fullstack-dashboard
description: Generate full-stack analytics dashboards with a Next.js App Router frontend, Tailwind CSS v4, shadcn/ui, Tremor Raw patterns, ECharts, and a FastAPI backend.
---

# Fullstack Dashboard

## Overview

Use this skill when the user wants a dashboard-style product with a TypeScript Next.js frontend and a Python FastAPI backend. It is optimized for KPI cards, paginated and sorted tables, ECharts visualizations, light/dark theming, responsive layouts, and typed frontend-backend contracts generated from OpenAPI.

## Use It When

- building a new analytics, admin, or operations dashboard
- replacing mocked dashboard data with a real FastAPI backend
- migrating a page to Next.js App Router with SSR and streaming
- wiring shadcn/ui primitives into a data-heavy UI
- adding typed API contracts with `openapi-typescript`

## Default Stack

- Frontend: Next.js App Router with TypeScript and Server Components by default
- Styling: Tailwind CSS v4 via `@tailwindcss/postcss` and `@import "tailwindcss";`
- UI primitives: shadcn/ui components added with the CLI
- Dashboard layer: Tremor Raw copy/paste patterns for cards, table shells, layout details, and Tremor charts for common analytics visuals
- Charts: `echarts` and `echarts-for-react` in client components only
- Backend: FastAPI with Pydantic response models and automatic OpenAPI
- Types: `openapi-typescript` generating `paths` and `components` types from `/openapi.json`

## Architecture Rules

- Fetch page data in async Server Components for SSR by default.
- Use `loading.tsx` and Suspense boundaries for route-level streaming.
- Keep charts interactive in client components and pass only serialized data into them.
- Use Route Handlers only when browser-side code needs a same-origin proxy or header normalization.
- Keep KPI, chart, and table endpoints separate so the page can stream progressively.
- Prefer server-side pagination and sorting contracts over large client-side table state.

## Workflow

1. Start from the structure and install steps in [references/setup.md](references/setup.md).
2. Configure Tailwind CSS v4, `next-themes`, and shadcn/ui before building pages.
3. Add the FastAPI app, CORS, and response models from [references/backend.md](references/backend.md).
4. Generate frontend types from the FastAPI schema using [references/api-types.md](references/api-types.md).
5. Build the dashboard layout, loading state, KPI section, chart, and table using [references/frontend.md](references/frontend.md) and [references/tremor-charts.md](references/tremor-charts.md).
6. Add Route Handlers only where direct server-side fetches are not the right boundary.
7. Validate theme switching, responsiveness, pagination, sorting, and chart rendering locally.

## Read The Right Reference

- Read [references/setup.md](references/setup.md) for project layout, installs, Tailwind setup, shadcn initialization, and run commands.
- Read [references/frontend.md](references/frontend.md) for App Router pages, theme wiring, route handlers, ECharts integration, and dashboard component patterns.
- Read [references/backend.md](references/backend.md) for FastAPI structure, schemas, CORS, and pagination/sorting endpoints.
- Read [references/api-types.md](references/api-types.md) for `openapi-typescript` generation and typed frontend fetch helpers.
- Read [references/tremor-charts.md](references/tremor-charts.md) for the full Tremor chart catalog and when to use each chart family.
- Read the [`shadcn`](../shadcn/SKILL.md) skill when you need component docs, registry search, CLI install guidance, or component debugging.

## Recommended MCP Workflow

- Use the local `next-devtools` MCP server when you need to inspect App Router behavior, route boundaries, streaming/loading states, or rendering issues.
- Use the local `shadcn` MCP server to explore available components before adding or replacing UI primitives.
- Use the [`shadcn`](../shadcn/SKILL.md) skill alongside this one for shadcn/ui-specific work.
- If the codebase already contains shadcn/ui components, extend those first instead of re-adding similar primitives.
- Treat Tremor Raw as copy/paste source material. Pull in only the dashboard-specific pieces you need and adapt them to the existing component library.

## Delivery Notes

- Keep the frontend and backend decoupled at the network boundary but aligned at the schema boundary.
- Use server components for data loading and composition, client components for charting and interactive controls.
- Do not build a second design system on top of shadcn/ui. Use Tremor Raw to reinforce dashboard presentation, not to replace the base primitives.
- Keep generated examples minimal but runnable.
