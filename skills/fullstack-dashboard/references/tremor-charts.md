# Tremor Charts

## Source Catalog

Based on the official Tremor charts page: https://www.tremor.so/charts

The official Tremor charts page lists these chart families and variants:

- Area Chart
- Area Chart with stacked categories
- Area Chart with percentages
- Area Chart with axis titles
- Area Chart with only start and end x-axis labels
- Area Chart with tooltip callback
- Bar Chart
- Bar Chart with stacked categories
- Bar Chart with percentages
- Bar Chart with axis titles
- Vertical Bar Chart
- Bar Chart with only start and end x-axis labels
- Grouped Bar Chart
- Bar Chart with conditional formatting
- Bar Chart with custom styling
- Bar Chart with rounded-sm top corner bars
- Bar Chart with gradient bars
- Line Chart
- Line Chart with axis titles
- Line Chart with only start and end x-axis labels
- Line Chart with custom tooltip
- ComboChart
- Donut Chart
- Donut Chart as pie variant
- Donut Chart with tooltip callback
- Progress Circle
- Progress Circle with its default variants
- Progress Circle complemented by a metric
- Spark Chart
- Category Bar
- Category Bar with marker
- Tracker
- Bar List

## Selection Guide

- Use `Area Chart` for trends where the filled region helps show volume or composition.
- Use `Bar Chart` for comparisons across categories, ranks, or grouped values.
- Use `Vertical Bar Chart` when category labels are long or better read on a vertical axis.
- Use `Grouped Bar Chart` when the page needs side-by-side comparison by category and series.
- Use `Line Chart` for trends over time or ordered sequences.
- Use `ComboChart` when one series is better represented as bars and another as a line.
- Use `Donut Chart` for part-to-whole views with a small number of categories.
- Use `Progress Circle` for progress or completion states tied to a single goal.
- Use `Spark Chart` for compact trend glyphs in cards or table cells.
- Use `Category Bar` for threshold-style progress, score, or segmented status.
- Use `Tracker` for density, activity, or occupancy patterns.
- Use `Bar List` for ranked items with horizontal value bars.

## Dashboard Rules

- Prefer Tremor charts when the page needs a standard dashboard chart that can be assembled quickly.
- Prefer ECharts when the visualization needs advanced interactions, linked brushing, custom overlays, or nonstandard axis behavior.
- Keep Tremor charts inside `components/tremor-raw/charts/` so the dashboard can copy/paste the pieces it actually needs.
- Do not mix too many chart libraries in one page unless there is a clear reason. Tremor charts should cover the common dashboard cases; ECharts should cover the exceptions.

## Integration Notes

- Keep chart data serialized and pass it into client components.
- Keep chart wrappers small and colocated with the dashboard features they serve.
- Use Tremor chart variants first when the doc already covers the layout you need.
- Reuse the same color scale and value formatter conventions across Tremor and ECharts charts so the dashboard reads as one system.
