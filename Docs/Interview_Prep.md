# Interview Preparation — 30 Q&A on the E-Commerce Sales Dashboard Project

## Python & Data Cleaning

**1. Why did you use Pandas instead of pure Python loops for cleaning?**
Pandas vectorizes operations across entire columns using compiled C code under the hood, which is far faster than row-by-row Python loops on 50,000+ records, and it gives built-in tools for deduplication, type conversion, and missing-value handling.

**2. How did you handle missing values, and why not just drop every row with a null?**
I imputed where a sensible default existed (e.g., missing discount → 0, missing payment mode → the most frequent mode) and only dropped rows where a critical identifier like Order ID or Customer ID was missing, since dropping too aggressively would bias the dataset and lose usable information.

**3. How did you detect and remove duplicate records?**
Using `drop_duplicates()`, with a subset of key columns (e.g., Order ID for orders, Customer ID for customers) so that legitimate repeat purchases weren't mistaken for duplicate rows.

**4. What's the difference between `dropna()` and `fillna()`, and when did you use each?**
`dropna()` removes rows/columns with missing data; `fillna()` replaces missing values with a specified value or strategy. I used `fillna()` for recoverable fields (discount, shipping cost) and `dropna()` only for unrecoverable critical identifiers.

**5. How did you validate that a date column was actually clean after conversion?**
I used `pd.to_datetime(..., errors="coerce")`, which turns unparseable values into `NaT`, then checked for and handled any resulting nulls, and enforced a business rule that Ship Date must be on or after Order Date.

**6. What's the purpose of the `Profit Margin` and `Sales Category` engineered columns?**
Profit Margin (`Profit / Sales * 100`) standardizes profitability comparisons across products of very different price points. Sales Category buckets transactions into Low/Medium/High tiers to simplify segmentation in dashboards and reports.

**7. How would you scale this cleaning script if the dataset were 50 million rows instead of 50,000?**
I'd move from Pandas to a distributed engine like PySpark or Dask, push filtering/aggregation down to the database where possible, and process in chunks rather than loading everything into memory at once.

**8. Why use exception handling in a data pipeline script?**
Real pipelines run unattended; wrapping the pipeline in try/except with logging ensures failures are caught, logged with context, and don't silently corrupt downstream outputs.

**9. What does "production-ready" code mean to you in this context?**
Readable, PEP8-formatted, modular functions with clear responsibilities, logging instead of print statements, defensive checks on inputs, and no hardcoded paths that break outside my machine.

**10. How did you decide which columns to standardize for text formatting?**
Any column feeding into groupings or joins (names, categories, payment modes) needed consistent casing and trimmed whitespace, since `"UPI"` and `"upi "` would otherwise be treated as different groups.

## SQL

**11. Why use a CTE instead of a subquery for the YoY growth calculation?**
CTEs improve readability by naming intermediate result sets and can be referenced multiple times in the same query, whereas repeating a subquery is harder to maintain and can hurt performance if not optimized by the engine.

**12. What's the difference between RANK(), DENSE_RANK(), and ROW_NUMBER()?**
`ROW_NUMBER()` assigns a unique sequential number regardless of ties; `RANK()` gives tied rows the same rank but leaves gaps afterward; `DENSE_RANK()` gives tied rows the same rank without gaps.

**13. Why did you create indexes on columns like order_date and customer_id?**
These columns are frequently used in WHERE, JOIN, and GROUP BY clauses; indexing them speeds up lookups and aggregations significantly on large tables.

**14. What's the difference between WHERE and HAVING?**
WHERE filters rows before aggregation; HAVING filters groups after aggregation (e.g., customers with more than 20 orders can only be filtered with HAVING since order count is a result of GROUP BY).

**15. Why use a window function for the running total instead of a self-join?**
Window functions like `SUM() OVER (ORDER BY ...)` compute running totals in a single pass without the row-multiplication and performance cost of a self-join.

**16. What's a view, and why did you create one for monthly performance?**
A view is a saved, reusable query that behaves like a virtual table. I created `vw_monthly_performance` so dashboards and other queries can reference monthly KPIs without repeating the aggregation logic.

**17. When would you use a stored procedure instead of a plain query?**
When the same parameterized logic (e.g., "sales by region") needs to run repeatedly with different inputs — a stored procedure encapsulates it, improves reusability, and can reduce round-trips from the application layer.

**18. How did you calculate Average Order Value, and why divide by distinct order count rather than row count?**
AOV = Total Sales / Distinct Order Count. Since each order can have multiple line items (in a fuller schema), dividing by raw row count would understate AOV; distinct order count reflects actual transactions.

**19. How would you optimize a slow GROUP BY query on a large table?**
Add indexes on the grouping/filter columns, ensure the query only selects needed columns, consider pre-aggregating into a summary table for frequently repeated queries, and check the execution plan (`EXPLAIN`) to find bottlenecks.

**20. What's the difference between INNER JOIN and LEFT JOIN, and where would that matter in this dataset?**
INNER JOIN returns only matching rows in both tables; LEFT JOIN returns all rows from the left table plus matches from the right, with NULLs where there's no match. If I wanted "all customers, even those with zero orders," I'd need a LEFT JOIN from Customers to Orders.

## Power BI & DAX

**21. What's the difference between a calculated column and a measure in Power BI?**
A calculated column is computed row-by-row and stored in the model (uses memory, static per row); a measure is computed dynamically at query time based on the current filter context, which is why aggregations like Total Sales should be measures.

**22. Explain how CALCULATE() works and why it's central to DAX.**
`CALCULATE()` evaluates an expression under a modified filter context — it's the mechanism behind time intelligence, "top N" measures, and most conditional aggregations in DAX.

**23. What is filter context, and how does it affect your measures?**
Filter context is the set of filters (from slicers, visuals, rows/columns) applied when a measure is evaluated. The same `Total Sales` measure returns different numbers depending on which Region or Year is selected, because DAX re-evaluates it within that context.

**24. Why did you build a separate DateTable instead of using the Order Date column directly for time intelligence?**
Power BI's time intelligence functions (TOTALYTD, SAMEPERIODLASTYEAR, etc.) require a proper, continuous marked Date table; using the raw Order Date column directly can produce incorrect results for months/years with no transactions.

**25. How does RANKX work, and where did you use it?**
`RANKX` ranks values in a table expression against a specified measure. I used it for `Product Sales Rank` and `Customer Sales Rank` to power "Top N" visuals and conditional formatting.

**26. What's the difference between drill-through and drill-down in Power BI?**
Drill-down moves through a visual's own hierarchy (e.g., Category → Sub-Category) within the same visual; drill-through navigates to an entirely different report page filtered to the selected item (e.g., right-click a customer to see their detail page).

**27. Why use bookmarks, and how did you apply them here?**
Bookmarks capture a snapshot of filter/visual state so users can jump between predefined views (e.g., "Default" vs. "High Performers Only") without manually resetting slicers — useful for guided storytelling in an executive dashboard.

**28. How would you handle a slow-loading Power BI report with millions of rows?**
Reduce granularity via aggregation tables, use Import mode with only necessary columns, avoid excessive calculated columns, use DirectQuery only when necessary, and optimize DAX measures to avoid row-by-row iterators where a simpler aggregation would work.

## Business Analytics & Design

**29. How did you translate the discount-vs-margin finding into a business recommendation?**
I quantified that margin drops from ~30% with no discount to ~6.5% above 15% discount, then recommended capping broad discounting above that threshold and shifting to bundling/loyalty incentives that drive volume without directly eroding margin.

**30. How do you decide what goes on an "Executive Summary" page versus deeper analysis pages?**
The executive page should answer "how is the business doing right now" in under 10 seconds — a handful of KPI cards and one or two trend/breakdown visuals. Deeper pages (Sales, Customer, Product, Regional) are for the "why" and "so what," with more granular breakdowns, filters, and drill-through for analysts who need to investigate further.
