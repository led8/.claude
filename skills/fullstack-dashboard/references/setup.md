# Setup

## Recommended Layout

```text
project/
├── frontend/
│   ├── app/
│   ├── components/
│   ├── lib/
│   ├── next.config.ts
│   └── postcss.config.mjs
└── backend/
    ├── app/
    │   ├── api/routes/
    │   ├── schemas/
    │   └── main.py
    └── .venv/
```

## Frontend Bootstrap

```bash
npx create-next-app@latest frontend --ts --app
cd frontend
npm install tailwindcss @tailwindcss/postcss postcss next-themes echarts echarts-for-react
npm install -D openapi-typescript
npx shadcn@latest init
npx shadcn@latest add button card table badge dropdown-menu input select skeleton pagination separator
```

Tailwind CSS v4 uses the dedicated PostCSS plugin:

```ts
// frontend/postcss.config.mjs
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
}

export default config
```

```css
/* frontend/app/globals.css */
@import "tailwindcss";
```

After `shadcn init`, keep the generated `components.json`, `lib/utils.ts`, and theme token block in `app/globals.css`. Let shadcn own the base UI tokens instead of hand-rolling a second token system.

## Backend Bootstrap

```bash
mkdir backend
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn
mkdir -p app/api/routes app/schemas
```

## Tremor Raw Integration

- Browse the Tremor Raw blocks you need.
- Copy only the dashboard-specific pieces into `frontend/components/tremor-raw/`.
- Replace generic wrappers with local shadcn/ui primitives where possible.
- Keep cards, table shells, and KPI layout helpers; avoid importing a large parallel component library wholesale.

## Run Both Apps

```bash
# terminal 1
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload --port 8000
```

```bash
# terminal 2
cd frontend
npm run dev
```

FastAPI serves:

- OpenAPI schema: `http://127.0.0.1:8000/openapi.json`
- Interactive docs: `http://127.0.0.1:8000/docs`

Next.js serves:

- frontend app: `http://127.0.0.1:3000`

## Development Recommendation

- Use `next-devtools` MCP during development to inspect routes, streaming, and server/client boundaries.
- Use the `shadcn` MCP server before adding components so you reuse the right primitive set instead of guessing.
- Use the [`shadcn`](../shadcn/SKILL.md) skill when you need shadcn/ui docs, registry search, or CLI workflows.
