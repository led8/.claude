# Frontend

## Recommended Frontend Files

```text
frontend/
├── app/
│   ├── api/dashboard/customers/route.ts
│   ├── dashboard/loading.tsx
│   ├── dashboard/page.tsx
│   ├── globals.css
│   └── layout.tsx
├── components/
│   ├── charts/revenue-chart.tsx
│   ├── dashboard/customer-table.tsx
│   ├── dashboard/kpi-grid.tsx
│   └── theme-provider.tsx
├── lib/
│   ├── api/generated/openapi.d.ts
│   └── dashboard-api.ts
└── next.config.ts
```

## Theme and Layout

```tsx
// frontend/components/theme-provider.tsx
"use client"

import { ThemeProvider as NextThemesProvider } from "next-themes"

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  return (
    <NextThemesProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      {children}
    </NextThemesProvider>
  )
}
```

```tsx
// frontend/app/layout.tsx
import "./globals.css"
import { ThemeProvider } from "@/components/theme-provider"

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen bg-background text-foreground antialiased">
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  )
}
```

```tsx
// frontend/app/dashboard/loading.tsx
export default function Loading() {
  return <div className="grid gap-4 md:grid-cols-3"><div className="h-28 animate-pulse rounded-xl bg-muted" /><div className="h-28 animate-pulse rounded-xl bg-muted" /><div className="h-28 animate-pulse rounded-xl bg-muted" /></div>
}
```

## Dashboard Page

```tsx
// frontend/app/dashboard/page.tsx
import dynamic from "next/dynamic"
import { CustomerTable } from "@/components/dashboard/customer-table"
import { KpiGrid } from "@/components/dashboard/kpi-grid"
import { getCustomers, getDashboardKpis, getRevenueSeries } from "@/lib/dashboard-api"

const RevenueChart = dynamic(() => import("@/components/charts/revenue-chart"), {
  ssr: false,
  loading: () => <div className="h-[320px] animate-pulse rounded-xl bg-muted" />,
})

export default async function DashboardPage({
  searchParams,
}: {
  searchParams: Record<string, string | string[] | undefined>
}) {
  const page = Number(searchParams.page ?? "1")
  const pageSize = Number(searchParams.page_size ?? "10")
  const sort = String(searchParams.sort ?? "updated_at")
  const order = String(searchParams.order ?? "desc") as "asc" | "desc"

  const [kpis, revenue, customers] = await Promise.all([
    getDashboardKpis(),
    getRevenueSeries(),
    getCustomers({ page, page_size: pageSize, sort, order }),
  ])

  return (
    <main className="mx-auto flex max-w-7xl flex-col gap-6 px-4 py-6 lg:px-8">
      <KpiGrid items={kpis.items} />
      <RevenueChart points={revenue.points} />
      <CustomerTable data={customers} />
    </main>
  )
}
```

## KPI Grid and Table

```tsx
// frontend/components/dashboard/kpi-grid.tsx
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { components } from "@/lib/api/generated/openapi"

type DashboardKpi = components["schemas"]["KpiItem"]

export function KpiGrid({ items }: { items: DashboardKpi[] }) {
  return (
    <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
      {items.map((item) => (
        <Card key={item.label}>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-muted-foreground">{item.label}</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-semibold">{item.value}</p>
            <p className="text-sm text-muted-foreground">{item.delta}</p>
          </CardContent>
        </Card>
      ))}
    </section>
  )
}
```

```tsx
// frontend/components/dashboard/customer-table.tsx
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import type { components } from "@/lib/api/generated/openapi"

type CustomerTableResponse = components["schemas"]["CustomerTableResponse"]

export function CustomerTable({ data }: { data: CustomerTableResponse }) {
  const nextOrder = data.order === "asc" ? "desc" : "asc"

  return (
    <Card>
      <CardHeader>
        <CardTitle>Customers</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead><Link href={`?page=1&sort=name&order=${nextOrder}`}>Name</Link></TableHead>
              <TableHead>Segment</TableHead>
              <TableHead className="text-right"><Link href={`?page=1&sort=mrr&order=${nextOrder}`}>MRR</Link></TableHead>
              <TableHead className="text-right"><Link href={`?page=1&sort=updated_at&order=${nextOrder}`}>Updated</Link></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.items.map((row) => (
              <TableRow key={row.id}>
                <TableCell className="font-medium">{row.name}</TableCell>
                <TableCell>{row.segment}</TableCell>
                <TableCell className="text-right">${row.mrr.toLocaleString()}</TableCell>
                <TableCell className="text-right">{row.updated_at}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <div className="flex items-center justify-between text-sm text-muted-foreground">
          <span>Page {data.page} of {Math.ceil(data.total / data.page_size)}</span>
          <div className="flex gap-2">
            <Link href={`?page=${Math.max(1, data.page - 1)}&sort=${data.sort}&order=${data.order}`}>Previous</Link>
            <Link href={`?page=${data.page + 1}&sort=${data.sort}&order=${data.order}`}>Next</Link>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
```

## ECharts

```ts
// frontend/next.config.ts
const nextConfig = {
  transpilePackages: ["echarts", "zrender"],
}

export default nextConfig
```

```tsx
// frontend/components/charts/revenue-chart.tsx
"use client"

import ReactEChartsCore from "echarts-for-react/lib/core"
import * as echarts from "echarts/core"
import { BarChart, LineChart } from "echarts/charts"
import { GridComponent, LegendComponent, TooltipComponent } from "echarts/components"
import { CanvasRenderer } from "echarts/renderers"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { components } from "@/lib/api/generated/openapi"

echarts.use([GridComponent, LegendComponent, TooltipComponent, LineChart, BarChart, CanvasRenderer])

type RevenuePoint = components["schemas"]["RevenuePoint"]

export default function RevenueChart({ points }: { points: RevenuePoint[] }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Revenue</CardTitle>
      </CardHeader>
      <CardContent>
        <ReactEChartsCore
          echarts={echarts}
          style={{ height: 320 }}
          option={{
            tooltip: { trigger: "axis" },
            legend: { top: 0 },
            grid: { left: 24, right: 24, top: 36, bottom: 24, containLabel: true },
            xAxis: { type: "category", data: points.map((point) => point.month) },
            yAxis: { type: "value" },
            series: [
              { name: "Revenue", type: "bar", data: points.map((point) => point.revenue) },
              { name: "Cost", type: "line", smooth: true, data: points.map((point) => point.cost) },
            ],
          }}
        />
      </CardContent>
    </Card>
  )
}
```

## Route Handler Proxy

Use a Route Handler only when the browser needs a same-origin endpoint. Server Components can call FastAPI directly.

```tsx
// frontend/app/api/dashboard/customers/route.ts
import { NextRequest } from "next/server"

export async function GET(request: NextRequest) {
  const qs = request.nextUrl.searchParams.toString()
  const upstream = await fetch(`http://127.0.0.1:8000/api/dashboard/customers?${qs}`, {
    cache: "no-store",
  })

  return new Response(upstream.body, {
    status: upstream.status,
    headers: { "content-type": "application/json" },
  })
}
```

## Tremor Raw Guidance

- Copy Tremor Raw KPI or table shells into `components/tremor-raw/`.
- Replace wrapper primitives with local shadcn/ui `Card`, `Table`, `Badge`, and `Button` components.
- Keep Tremor-style layout, spacing, and dashboard affordances. Avoid importing a second foundational component set.

For chart-heavy dashboards, pair those shells with the catalog in [references/tremor-charts.md](references/tremor-charts.md) and use Tremor charts before falling back to ECharts.

```tsx
// frontend/components/tremor-raw/metric-shell.tsx
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export function MetricShell({
  title,
  value,
  helper,
}: {
  title: string
  value: string
  helper: string
}) {
  return (
    <Card className="overflow-hidden border-border/60 shadow-sm">
      <CardHeader className="space-y-1 pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">{title}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-1">
        <p className="text-3xl font-semibold tracking-tight">{value}</p>
        <p className="text-sm text-muted-foreground">{helper}</p>
      </CardContent>
    </Card>
  )
}
```
