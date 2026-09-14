# Pizza Sales Analysis

A year of pizza place sales, broken down by order volume, peak hours, bestsellers, revenue seasonality, and menu performance — built to identify which pizzas to promote, which to cut, and when to staff up.

> **Assumption:** the root folder name and folder tree in Section 2 of the brief were left as a template example that happens to match the actual uploaded file names exactly, so I've treated it as the real structure below. If the root folder is actually named something else, rename it — nothing inside changes.

## Overview

This project analyzes 21,350 orders and 48,620 order line items from a single pizza restaurant location covering the full 2015 calendar year. The dataset has no store, region, or customer-loyalty ID — it's one location, one year — so the analysis focuses on *when* customers order, *what* they order, and *which* menu items are actually earning their shelf space. The four tables (`orders`, `order_details`, `pizzas`, `pizza_types`) were joined into a single sales fact table and queried with the SQL in `script/pizza-sale-dashboard.sql`, then visualized in the Power BI file in `dashboard/`.

## Problem Statements

1. How many customers do we get each day, and are there peak hours?
2. How many pizzas are typically in an order, and do we have any bestsellers?
3. How much revenue did we make this year, and is there seasonality in sales?
4. Are there pizzas we should drop from the menu, or promotions worth running?

## Dataset

```
Pizza Sales Analysis/
├── data/            → .CSV/ order_details, orders, pizza_types, pizzas
├── script/          → SQL / pizza-sale-dashboard
├── dashboard/        → .pbix / pizza-sales
├── image/            → pizza-dashboard
└── README.md
```

| File | Record Count | Description |
|---|---|---|
| `data/orders.csv` | 21,350 | One row per order: order ID, date, timestamp |
| `data/order_details.csv` | 48,620 | One row per pizza line item within an order: pizza ID, quantity |
| `data/pizzas.csv` | 96 | Pizza SKU catalog: pizza ID, type, size (S/M/L/XL/XXL), price |
| `data/pizza_types.csv` | 32 | Pizza type catalog: name, category (Classic/Chicken/Supreme/Veggie), ingredients |

No revenue column exists in the raw data — every dollar figure in this project is derived as `order_details.quantity × pizzas.price`, joined up through `pizza_types` for category-level rollups.

## Tools and Technology

| Tool | Purpose in This Project |
|---|---|
| PostgreSQL (SQL) | Joining the four source tables and computing all revenue, order-volume, and ranking metrics |
| Power BI | Building the interactive dashboard (`dashboard/pizza-sales.pbix`) |
| Python (pandas, matplotlib) | Data validation and the supporting charts in the client report |
| Microsoft Word / Markdown | Client-facing report and this README |

## Methods

1. **Exploration** — profiled all four CSVs for row counts, nulls, and duplicate keys. Found zero nulls and zero duplicate primary keys across `orders`, `order_details`, `pizzas`, and `pizza_types`.
2. **Referential integrity check** — confirmed every `pizza_id` in `order_details` exists in `pizzas`, every `order_id` exists in `orders`, and every `pizza_type_id` in `pizzas` exists in `pizza_types`. Zero orphan rows.
3. **Cleaning** — no missing-value imputation was needed given zero nulls; the only real cleaning step was reading `pizza_types.csv` with `latin-1` encoding, since a couple of ingredient names contain accented characters that break plain UTF-8 parsing.
4. **Modeling** — joined `order_details → pizzas → pizza_types → orders` into one flat fact table, with a calculated `line_revenue = quantity × price` column, in the SQL script.
5. **Validation** — cross-checked SQL query outputs (total sales, avg pizzas/order, order count) against the existing Power BI dashboard's KPI cards — all four headline numbers matched (Total Sales $817.86K, Avg pizzas/order 2.32, Orders 21,350).
6. **Dashboard build** — used the existing `dashboard/pizza-sales.pbix` and its KPI cards, day-of-week chart, peak-hour chart, category/size donuts, and top-5 pizza table as the primary visual layer; built supporting Python charts for the client report where a plain trend/ranking view was clearer than a dashboard screenshot.

## Key Insights

- **$817,860.05** in total 2015 revenue across 49,574 pizzas sold and 21,350 orders — an average order value of **$38.31**.
- Customers order **2.32 pizzas per order** on average, but that's skewed by a long tail: the median order is 2 pizzas, 75% of orders are 3 or fewer, and one outlier order hit 28 pizzas.
- **Friday is the busiest day** (3,538 orders across the year) and **Sunday the quietest** (2,624) — a 35% gap between the two.
- Order volume peaks at **lunch (12–1 PM, ~5,000 orders combined)** and again at **dinner (5–7 PM, ~6,700 orders combined)**, with almost nothing before 10 AM or after 11 PM.
- Revenue is **not flat across the year** — July ($72,558) and May ($71,403) are the strongest months, while October ($64,028) and September ($64,180) are the weakest, an ~11% swing between best and worst month.
- **The Classic Deluxe Pizza** is the volume bestseller (2,453 sold), but **The Thai Chicken Pizza** generates the most revenue ($43,434.25) — quantity leader and revenue leader aren't the same pizza.
- **The Brie Carre Pizza** is the clear underperformer: 490 units sold and $11,588.50 in revenue, roughly half the volume of the next-lowest item — the strongest candidate for a menu cut or a promo push.
- By category, **Classic** pizzas drive the most revenue (26.9% of total, $220,053) despite having fewer SKUs than Supreme or Veggie, meaning each Classic pizza type pulls more sales on average than items in the other three categories.
- The restaurant had **7 zero-order days** in the data (Dec 25, four of the five Mondays in October, plus Sep 24–25) — reads as planned closures rather than a data gap, since Dec 25 and a run of consecutive Mondays don't look random.

## Dashboard / Model / Output

The Power BI dashboard (`dashboard/pizza-sales.pbix`, screenshot below) is a single-page view with:

- **KPI header** — Total Sales ($817.86K), Avg pizzas per order (2.32), Daily average orders (59.64), and total Order count (21K)
- **Sales by Month** — line chart showing the monthly revenue trend across 2015
- **Days with High Footfall** — horizontal bar ranking order volume by day of week, Friday highest
- **Peak Hours Order** — horizontal bar grouping orders into daypart buckets (12–3 PM, 3–6 PM, 6–9 PM, etc.), 6–9 PM the busiest window
- **Orders by category / Orders by size** — two donut charts breaking down order line share by pizza category (Classic/Chicken/Supreme/Veggie) and by size (S/M/L/XL)
- **Top 5 Pizzas** — table ranking pizzas by total sales, led by The Thai Chicken Pizza at $43,434.25

![Pizza Sales Dashboard](image/pizza-dashboard.png)

## How to Run This Project

1. Load the four CSVs from `data/` (`orders.csv`, `order_details.csv`, `pizzas.csv`, `pizza_types.csv`) into a PostgreSQL database, one table per file, matching the column names in each CSV.
2. Run `script/pizza-sale-dashboard.sql` against that database — it contains 12 standalone queries covering total/monthly/yearly sales, category breakdowns, orders-per-day, peak hours, average pizzas per order, bestsellers, seasonality, and worst-sellers.
3. Open `dashboard/pizza-sales.pbix` in Power BI Desktop and point its data source connection at the same database (or refresh against the CSVs directly) to regenerate the visuals.
4. Reference `image/pizza-dashboard.png` for the dashboard's intended final layout if visuals need to be rebuilt.

## Result and Conclusion

The data shows a healthy, seasonal single-location pizza business generating $817.86K a year off 21,350 orders, with clear, actionable patterns in when customers show up and what they buy. Staffing and promotions currently aren't tied to the Friday-dinner demand peak or the July/May revenue highs this data reveals, and the menu is carrying at least one pizza (The Brie Carre) selling at roughly half the volume of everything else on it. Acting on the day-part and menu findings below is a low-cost way to lift revenue without adding new products or locations.

## Future Work

1. Add a `customer_id` or loyalty identifier to the data model to move from order-level to customer-level analysis (repeat-purchase rate, customer lifetime value).
2. Bring in a cost/margin figure per pizza (ingredients are listed but not priced) to convert "bestseller by revenue" into "bestseller by profit."
3. Pull in staffing schedules or labor-hour data to test whether Friday/weekend peak hours are actually staffed to match demand.
4. Run a controlled promotion on the bottom 2–3 menu items (Brie Carre, Green Garden, Mediterranean) and measure whether a discount lifts volume enough to justify keeping them on the menu.
5. Extend the dataset beyond one year to confirm whether the July/May revenue peak and October/September dip are a genuine seasonal pattern or specific to 2015.

## Author and Contact

**Author:** Dibbya Prakash Gorla
**Email:** dibbyagorla@gmail.com
**GitHub:** dibbyagorla-cloud

> ⚠️ Placeholder contact info — replace with your actual details before publishing.
