# Power BI Dashboard — Build Guide
### E-Commerce Sales Dashboard | Executive Analytics Suite

> **Important note:** A `.pbix` file is a proprietary binary format that only Power BI Desktop can write, so it can't be generated directly as a text/code artifact. This guide gives you everything needed to build the exact dashboard in Power BI Desktop in under an hour: the data model, every DAX measure, page-by-page layout, and formatting rules. Follow it top to bottom and save as `Ecommerce Dashboard.pbix`.

---

## 1. Load & Model the Data

1. Open Power BI Desktop → **Get Data → Text/CSV** → import `Python/cleaned_data.csv`.
2. Go to **Model view** and confirm data types:
   - `Order Date`, `Ship Date` → Date
   - `Sales`, `Profit`, `Shipping Cost`, `Discount`, `Profit Margin` → Decimal Number
   - `Quantity`, `Year`, `Order Processing Days` → Whole Number
3. Create a **Date dimension table** (Modeling → New Table):

```dax
DateTable =
ADDCOLUMNS (
    CALENDAR ( DATE ( 2022, 1, 1 ), DATE ( 2025, 12, 31 ) ),
    "Year", YEAR ( [Date] ),
    "MonthNumber", MONTH ( [Date] ),
    "MonthName", FORMAT ( [Date], "MMMM" ),
    "Quarter", "Q" & FORMAT ( [Date], "Q" )
)
```

4. Mark `DateTable` as a **Date Table** (Table tools → Mark as Date Table → `Date` column).
5. Create a relationship: `DateTable[Date]` (1) → `cleaned_data[Order Date]` (many).
6. Hide the raw `Month`/`Year` columns from `cleaned_data` in report view to avoid ambiguity — use the DateTable ones instead for all time intelligence.

---

## 2. DAX Measures

Create a dedicated measure table called `_Measures` (New Table → type `_Measures = {1}` then delete the column) and add all measures below inside it.

### Core KPIs
```dax
Total Sales = SUM ( cleaned_data[Sales] )

Total Profit = SUM ( cleaned_data[Profit] )

Total Orders = DISTINCTCOUNT ( cleaned_data[Order ID] )

Total Customers = DISTINCTCOUNT ( cleaned_data[Customer ID] )

Average Order Value = DIVIDE ( [Total Sales], [Total Orders] )

Profit Margin % = DIVIDE ( [Total Profit], [Total Sales] )

Total Quantity Sold = SUM ( cleaned_data[Quantity] )

Return Rate % =
DIVIDE (
    CALCULATE ( [Total Orders], cleaned_data[Return Status] = "Returned" ),
    [Total Orders]
)
```

### Time Intelligence
```dax
Sales YTD = TOTALYTD ( [Total Sales], DateTable[Date] )

Profit YTD = TOTALYTD ( [Total Profit], DateTable[Date] )

Previous Month Sales = CALCULATE ( [Total Sales], PREVIOUSMONTH ( DateTable[Date] ) )

Previous Year Sales = CALCULATE ( [Total Sales], SAMEPERIODLASTYEAR ( DateTable[Date] ) )

MoM Growth % =
VAR PrevMonth = [Previous Month Sales]
RETURN DIVIDE ( [Total Sales] - PrevMonth, PrevMonth )

YoY Growth % =
VAR PrevYear = [Previous Year Sales]
RETURN DIVIDE ( [Total Sales] - PrevYear, PrevYear )

Rolling 3-Month Avg Sales =
AVERAGEX (
    DATESINPERIOD ( DateTable[Date], MAX ( DateTable[Date] ), -3, MONTH ),
    [Total Sales]
)
```

### Rankings & "Top" Measures
```dax
Top Customer =
CALCULATE (
    VALUES ( cleaned_data[Customer Name] ),
    TOPN ( 1, VALUES ( cleaned_data[Customer Name] ), [Total Sales] )
)

Top Product =
CALCULATE (
    VALUES ( cleaned_data[Product Name] ),
    TOPN ( 1, VALUES ( cleaned_data[Product Name] ), [Total Sales] )
)

Top Region =
CALCULATE (
    VALUES ( cleaned_data[Region] ),
    TOPN ( 1, VALUES ( cleaned_data[Region] ), [Total Sales] )
)

Product Sales Rank =
RANKX ( ALL ( cleaned_data[Product Name] ), [Total Sales] )

Customer Sales Rank =
RANKX ( ALL ( cleaned_data[Customer Name] ), [Total Sales] )
```

### Supporting Measures
```dax
Total Shipping Cost = SUM ( cleaned_data[Shipping Cost] )

Avg Processing Days = AVERAGE ( cleaned_data[Order Processing Days] )

Discount Amount = SUMX ( cleaned_data, cleaned_data[Sales] * cleaned_data[Discount] )

Sales (Selected Category %) =
DIVIDE ( [Total Sales], CALCULATE ( [Total Sales], ALL ( cleaned_data[Category] ) ) )
```

---

## 3. Report Pages

### Page 1 — Executive Summary
- KPI cards across the top: **Total Sales, Total Profit, Profit Margin %, Average Order Value, Total Orders, Total Customers**
- Line chart: `Total Sales` & `Total Profit` by `DateTable[MonthName]/Year`
- Donut chart: `Total Sales` by `Category`
- Map (Bing/ArcGIS map visual): `Total Sales` by `State`
- Navigation buttons (top bar) linking to the other 4 pages
- Bookmark: "Default View" resetting all slicers

### Page 2 — Sales Analysis
- Clustered bar chart: `Total Sales` by `Sub Category`
- Ribbon chart: `Total Sales` by `Region` over `Year` (shows rank changes)
- Waterfall chart: Month-over-month `Total Sales` change
- Line chart: `Rolling 3-Month Avg Sales` vs `Total Sales`
- Slicers: `Year`, `Region`, `Payment Mode`

### Page 3 — Customer Analysis
- Table: Top 20 customers with `Total Sales`, `Total Profit`, `Customer Sales Rank`
- Treemap: `Total Sales` by `Segment`
- Clustered column: `Total Customers` by `Segment`
- Card: `Top Customer`
- Drill-through page: "Customer Detail" (right-click a customer → drill through to see their full order history via a Table visual)

### Page 4 — Product Analysis
- Matrix: `Category` × `Sub Category` with `Total Sales`, `Total Profit`, `Profit Margin %`
- Bar chart: Top 10 products by `Total Sales` (using `Product Sales Rank` <= 10 filter)
- Scatter chart: `Total Sales` (x) vs `Profit Margin %` (y), bubble size = `Total Quantity Sold`, one bubble per `Sub Category`
- Card: `Top Product`

### Page 5 — Regional Analysis
- Filled map: `Total Sales` by `State`
- Clustered bar: `Total Sales` by `Region`
- Table: `Region`, `Total Sales`, `Total Profit`, `Profit Margin %`, `Return Rate %`
- Card: `Top Region`

---

## 4. Interactivity Checklist

- [ ] **Slicers** on every page: `Year`, `Region`, `Category` (sync slicers across pages via View → Sync Slicers)
- [ ] **Tooltips**: build a custom tooltip page showing Sales/Profit trend for the hovered category
- [ ] **Bookmarks**: "Default", "High Performers Only" (filtered to Profit Margin % > 20%)
- [ ] **Drill-through**: Category → Sub Category → Product
- [ ] **Navigation buttons**: icon buttons in a top nav bar, using bookmarks + "Page Navigation" action
- [ ] **Conditional formatting**: color KPI cards and matrix cells by profit margin (red/yellow/green)

## 5. Theme

Import a custom theme JSON (View → Themes → Browse for themes) with:
- Primary: `#1F4E8C` (deep blue)
- Secondary: `#5B9BD5` (light blue)
- Background: `#FFFFFF` / `#F5F7FA`
- Font: Segoe UI, 10-11pt body, 16-20pt titles

Save the final file as `PowerBI/Ecommerce Dashboard.pbix`.
