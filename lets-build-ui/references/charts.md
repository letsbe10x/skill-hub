---
purpose: Chart type recommendations for dashboards and data-heavy UIs
lookup-by: Data Type
---

# Charts & Data Visualization Reference

Use during Step 7 (conditional) when the component inventory includes dashboards, analytics views, reporting pages, or data tables.

| No | Data Type | Best Chart Type | When to Use | When NOT to Use | A11y Grade | Library Recommendation | Interactive Level |
|----|-----------|----------------|-------------|-----------------|------------|----------------------|-------------------|
| 1 | Trend Over Time | Line Chart | Data has a time axis; observe rise/fall trends | Fewer than 4 points (use stat card); > 6 series (visual noise) | AA | Chart.js, Recharts, ApexCharts | Hover + Zoom |
| 2 | Compare Categories | Bar Chart (H or V) | Comparing discrete categories by magnitude; ≤ 15 categories | Categories > 15 (use table); data has time dimension (use line) | AAA | Chart.js, Recharts, D3.js | Hover + Sort |
| 3 | Part-to-Whole | Pie Chart or Donut | ≤ 5 categories; one dominant segment | Categories > 5; slice differences < 5%; accessibility-first context | C | Chart.js, Recharts, D3.js | Hover + Drill |
| 4 | Correlation / Distribution | Scatter Plot or Bubble | Exploring relationship between two continuous variables | Variables are categorical (use grouped bar); fewer than 20 points | B | D3.js, Plotly, Recharts | Hover + Brush |
| 5 | Heatmap / Intensity | Heat Map or Choropleth | Intensity/density across a 2D grid; time-based patterns (e.g. activity by hour × day) | Fewer than 20 cells (use bar); user needs exact values | B | D3.js, Plotly, ApexCharts | Hover + Zoom |
| 6 | Geographic Data | Choropleth Map or Bubble Map | Data has a regional/location dimension; spatial distribution is core insight | Regions with very different sizes making comparison misleading | B | D3.js, Mapbox, Leaflet | Pan + Zoom + Drill |
| 7 | Funnel / Flow | Funnel Chart or Sankey | Sequential multi-stage process; conversion or drop-off rates between defined stages | Stages aren't sequential; values don't decrease monotonically | AA | D3.js, Recharts, Custom SVG | Hover + Drill |
| 8 | Performance vs Target | Gauge Chart or Bullet Chart | Single KPI measured against a defined target or threshold | No target or benchmark exists; comparing multiple KPIs (use bullet grid) | AA | D3.js, ApexCharts, Custom SVG | Hover |
| 9 | Time-Series Forecast | Line with Confidence Band | Historical data + model predictions; communicating uncertainty range | No historical baseline; prediction confidence too low | AA | Chart.js, ApexCharts, Plotly | Hover + Toggle |
| 10 | Anomaly Detection | Line Chart with Highlights | Monitoring time-series for outliers; alerting to unexpected spikes | Anomalies are predefined categories (use bar with highlight) | AA | D3.js, Plotly, ApexCharts | Hover + Alert |
| 11 | Hierarchical / Nested | Treemap | Size relationships within a hierarchy; proportional structure overview | Hierarchy depth > 3 levels; user needs precise comparison | C | D3.js, Recharts, ApexCharts | Hover + Drilldown |
| 12 | Flow / Process | Sankey Diagram | How quantities flow between nodes; multi-source multi-target distribution | Flow directions form loops (use network graph); < 3 source-target pairs | C | D3.js (d3-sankey), Plotly | Hover + Drilldown |
| 13 | Cumulative Changes | Waterfall Chart | Individual positive/negative components add to a final total (e.g. P&L) | Changes are not additive; more than 12 bars | AA | ApexCharts, Highcharts, Plotly | Hover |
| 14 | Multi-Variable Comparison | Radar / Spider Chart | Comparing multiple entities across the same fixed attribute set | Axes > 8 (unreadable); values need precise comparison | B | Chart.js, Recharts, ApexCharts | Hover + Toggle |
| 15 | Stock / Trading OHLC | Candlestick Chart | Financial time-series with Open/High/Low/Close data; trading context only | Non-financial audience; no OHLC data available | B | Lightweight Charts (TradingView), ApexCharts | Real-time + Hover + Zoom |
| 16 | Relationship / Connection | Network Graph | Mapping connections between entities; network topology | Node count > 500 without clustering; mobile context | D | D3.js (d3-force), Vis.js, Cytoscape.js | Drilldown + Hover + Drag |
| 17 | Distribution / Statistical | Box Plot | Spread, median, and outliers; comparing distributions across groups | Fewer than 20 data points per group | AA | Plotly, D3.js, Chart.js (plugin) | Hover |
| 18 | Performance vs Target (Compact) | Bullet Chart | Multiple KPIs side by side; space-constrained contexts | Single KPI with emphasis (use gauge); no defined target range | AAA | D3.js, Plotly, Custom SVG | Hover |
| 19 | Proportional / Percentage | Waffle Chart | What fraction of a whole is filled; percentage progress | More than 5 categories (use stacked bar) | AA | D3.js, React-Waffle, Custom CSS Grid | Hover |
| 20 | Hierarchical Proportional | Sunburst Chart | Nested proportions where both hierarchy and size matter | More than 3 hierarchy levels; precision matters; mobile | C | D3.js (d3-hierarchy), Recharts, ApexCharts | Drilldown + Hover |
| 21 | Root Cause Analysis | Decomposition Tree | Decomposing a metric into contributing factors; AI drill-down scenarios | No clear parent-child causal relationship | AA | Power BI (native), React-Flow, Custom D3.js | Drill + Expand |
| 22 | 3D Spatial Data | 3D Scatter / Surface Plot | Scientific context where Z-axis carries essential info not expressible in 2D | 2D projection conveys same insight; mobile; accessibility-required environments | D | Three.js, Deck.gl, Plotly 3D | Rotate + Zoom + VR |
| 23 | Real-Time Streaming | Streaming Area Chart | Live monitoring dashboards; IoT/ops data updating at ≥ 1 Hz | Update frequency < 1/min (use periodic-refresh line); without pause control | B | Smoothed D3.js, CanvasJS | Real-time + Pause + Zoom |
| 24 | Sentiment / Emotion | Word Cloud with Sentiment | NLP output visualization; exploratory text corpus sentiment | Precise values matter; screen-reader context; corpus < 50 items | C | D3-cloud, Highcharts, Nivo | Hover + Filter |
| 25 | Process Mining | Process Map / Graph | Analyzing event logs; identifying bottlenecks and deviations in ops funnels | No event log data; audience expects static flowchart; node count > 100 without pre-filtering | B | React-Flow, Cytoscape.js, Recharts | Drag + Node-Click |

## Chart Anti-patterns (from ui-ux-pro-max)

- **Pie chart with > 5 slices** — use a bar chart or ranked list instead
- **3D charts for standard business data** — fundamentally inaccessible (Grade D); must not be used as primary chart type
- **Dual Y-axis** — avoid; use small multiples instead
- **Missing zero baseline on bar charts** — always start bar charts at zero
- **Color-only encoding** — always pair color with shape/label for colorblind accessibility
- **Missing empty state** — every chart must handle "no data" gracefully
- **Network graph without fallback** — fundamentally inaccessible (Grade D); always provide list alternative

## Accessibility Grades

`AAA` = fully accessible | `AA` = WCAG compliant with care | `B` = requires extra attention | `C` = limited accessibility, require table fallback | `D` = fundamentally inaccessible, must provide alternative view
