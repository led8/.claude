# API Types

## Generate Types From FastAPI

Run the backend first, then generate the frontend types from the live schema:

```bash
cd frontend
npx openapi-typescript http://127.0.0.1:8000/openapi.json -o ./lib/api/generated/openapi.d.ts
```

A useful package script is:

```json
{
  "scripts": {
    "gen:api": "openapi-typescript http://127.0.0.1:8000/openapi.json -o ./lib/api/generated/openapi.d.ts"
  }
}
```

## Typed Fetch Layer

```ts
// frontend/lib/dashboard-api.ts
import type { components, paths } from "@/lib/api/generated/openapi"

export type DashboardKpisResponse = components["schemas"]["DashboardKpisResponse"]
export type RevenueSeriesResponse = components["schemas"]["RevenueSeriesResponse"]
export type CustomerTableResponse = components["schemas"]["CustomerTableResponse"]
export type CustomersQuery = paths["/api/dashboard/customers"]["get"]["parameters"]["query"]

export async function getDashboardKpis(): Promise<DashboardKpisResponse> {
  const response = await fetch("http://127.0.0.1:8000/api/dashboard/kpis", { cache: "no-store" })
  if (!response.ok) throw new Error("Failed to load KPIs")
  return response.json()
}

export async function getRevenueSeries(): Promise<RevenueSeriesResponse> {
  const response = await fetch("http://127.0.0.1:8000/api/dashboard/revenue", { cache: "no-store" })
  if (!response.ok) throw new Error("Failed to load revenue series")
  return response.json()
}

export async function getCustomers(query: CustomersQuery = {}): Promise<CustomerTableResponse> {
  const params = new URLSearchParams()

  if (query.page) params.set("page", String(query.page))
  if (query.page_size) params.set("page_size", String(query.page_size))
  if (query.sort) params.set("sort", query.sort)
  if (query.order) params.set("order", query.order)

  const response = await fetch(`http://127.0.0.1:8000/api/dashboard/customers?${params}`, {
    cache: "no-store",
  })

  if (!response.ok) throw new Error("Failed to load customers")
  return response.json()
}
```

## Rules

- Prefer `components["schemas"][...]` for stable response body aliases.
- Use `paths[...]` query parameter types to keep pagination and sorting arguments aligned with the backend.
- Regenerate `openapi.d.ts` whenever the backend response models or query params change.
- If browser-side code must call the backend through a Next.js Route Handler, keep the handler response shape identical to the FastAPI response so the generated types still apply.
