# Business Insights — E-Commerce Sales Dashboard

_Figures below are computed directly from `Python/cleaned_data.csv` (~51,300 orders, 2022–2025)._

## Headline Numbers

| Metric | Value |
|---|---|
| Total Sales | ₹301.5 Cr |
| Total Profit | ₹62.8 Cr |
| Overall Profit Margin | 20.8% |
| Average Order Value | ₹58,697 |
| Total Orders | 51,362 |
| Total Customers | 5,937 |
| Return Rate | 5.9% |

## Regional Performance

- **Best region: South** — highest total sales (₹930 Cr... _i.e._ ₹93.0 Cr) driven by high order volumes from Tamil Nadu, Karnataka, and Telangana metros.
- **Worst region: East** — lowest total sales (₹53.8 Cr), roughly 42% below the South. This points to under-penetration in West Bengal, Odisha, Bihar, and Jharkhand markets relative to the rest of the country.
- **Recommendation:** prioritize regional marketing spend and warehouse/logistics investment in the East to close the gap; investigate whether lower East sales stem from awareness, delivery times, or product-mix fit.

## Seasonality

- **Highest sales month: August**, closely followed by July and May — suggesting a mid-year demand peak, plausibly tied to festive pre-season buying and end-of-summer sales.
- **Lowest sales month: February** — the softest month of the year, ~14% below August.
- **Recommendation:** run targeted promotions in February to smooth the seasonal dip, and ensure inventory and staffing are scaled up ahead of the July–August peak.

## Category Profitability

- **Most profitable category: Electronics** (₹28.7 Cr profit) — highest average order values and strong margins despite premium pricing.
- **Least profitable category: Office Supplies** (₹1.1 Cr profit) — low unit prices and thin margins mean this category contributes volume but little bottom-line value.
- **Recommendation:** protect and grow Electronics through bundling and upsell (accessories, extended warranty); consider whether Office Supplies is worth continued heavy discounting or better used as a loyalty/traffic driver rather than a profit center.

## Customer Analysis

- **Top customers** (Priya Nair, Radha Das, Pooja Rao) each generated over ₹1.1 Cr in lifetime sales — a reminder that in this dataset a small set of high-value accounts contributes disproportionately, which is typical of B2B/Corporate-heavy segments.
- **Low-value customers** cluster around ₹35,000–45,000 in lifetime spend — likely one-time or occasional buyers.
- **Recommendation:** build a tiered loyalty program for top-decile customers, and design win-back/onboarding campaigns to increase repeat-purchase rate among low-frequency buyers.

## Discount Impact on Profitability

| Discount Band | Avg. Profit Margin |
|---|---|
| No Discount | 29.8% |
| Low Discount (≤15%) | 22.1% |
| High Discount (>15%) | 6.5% |

- Margin erodes sharply as discount depth increases — orders with discounts above 15% run at roughly a **quarter** of the margin of full-price orders.
- **Recommendation:** cap blanket discounting above 15% except for clearance/inventory-clearing SKUs, and shift promotional strategy toward bundling or loyalty points, which drive volume without directly cannibalizing margin.

## Sales Trend

- Year-over-year sales show steady growth from 2022 through 2025, consistent with the simulated dataset's upward demand curve — validate this against the `SQL/ecommerce.sql` YoY growth query and the Power BI "YoY Growth %" measure for the live, refreshed numbers.

## Business Recommendations (Summary)

1. Invest in East region market penetration (logistics + marketing).
2. Smooth seasonality with February promotions; prepare inventory for the July–August peak.
3. Double down on Electronics; re-evaluate Office Supplies' role in the portfolio.
4. Launch a top-tier loyalty program and a low-engagement win-back campaign.
5. Cap deep discounting (>15%) to protect margin; shift to bundling/loyalty incentives.

## Future Improvements

- Add a cohort/RFM (Recency, Frequency, Monetary) analysis for customer segmentation.
- Layer in a demand forecasting model to plan inventory ahead of seasonal peaks.
- Track customer acquisition cost (CAC) and lifetime value (LTV) once marketing spend data is available.
