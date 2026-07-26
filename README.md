# 🛒 E-Commerce Sales Dashboard

An end-to-end data analytics portfolio project covering data generation, cleaning (Python), analysis (SQL), and executive-level visualization (Power BI). Built to simulate a real company's sales analytics workflow, from raw exports to boardroom-ready dashboard.

![Status](https://img.shields.io/badge/status-complete-brightgreen)
![Python](https://img.shields.io/badge/python-3.10%2B-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![PowerBI](https://img.shields.io/badge/Power%20BI-Desktop-yellow)

---

## 📌 Project Overview

This project analyzes 4 years (2022–2025) of simulated e-commerce transactions across India — spanning Electronics, Furniture, Clothing, Office Supplies, Home & Kitchen, and Sports — to uncover sales trends, profitability drivers, customer behavior, and regional performance, and presents the findings through an interactive Power BI dashboard.

## 🎯 Objectives

- Simulate a realistic, messy raw dataset the way a company's transactional export would look
- Clean and engineer analysis-ready features using Python/Pandas
- Perform deep-dive SQL analysis (rankings, trends, running totals, stored procedures)
- Build an interactive, multi-page Power BI dashboard with DAX-driven KPIs
- Translate the analysis into concrete business recommendations

## 📁 Project Structure

```
Ecommerce Dashboard/
├── Dataset/                # Raw source data
│   ├── Orders.csv
│   ├── Customers.csv
│   └── Products.csv
├── Python/                 # Data cleaning & feature engineering
│   ├── cleaning.py
│   ├── requirements.txt
│   └── cleaned_data.csv
├── SQL/
│   └── ecommerce.sql       # Schema + full analytical query set (MySQL)
├── PowerBI/
│   ├── Ecommerce Dashboard.pbix
│   └── PowerBI_Build_Guide.md
├── Images/                 # Dashboard screenshots
├── Docs/
│   ├── Report.pdf
│   ├── Business_Insights.md
│   ├── Resume_Bullets.md
│   └── Interview_Prep.md
├── README.md
├── LICENSE
└── .gitignore
```

## 🛠️ Tools Used

| Layer | Tool |
|---|---|
| Data generation & cleaning | Python (Pandas, NumPy) |
| Analysis | MySQL 8.0 (CTEs, window functions, views, stored procedures) |
| Visualization | Power BI Desktop (DAX, bookmarks, drill-through) |
| Version control | Git & GitHub |

## 📊 Dataset

~51,000 cleaned order-level records with 27 columns spanning order, customer, product, financial, and logistics attributes. See [`Dataset/`](./Dataset) for raw files and [`Python/cleaned_data.csv`](./Python/cleaned_data.csv) for the analysis-ready output.

## 🐍 Python — Data Cleaning

`Python/cleaning.py` loads the three raw CSVs and:
- Removes duplicate records
- Handles missing values (imputation rules per column)
- Converts and validates date columns
- Standardizes text formatting
- Removes invalid/negative values
- Engineers `Month`, `Year`, `Profit Margin`, `Sales Category`, and `Order Processing Days`
- Merges everything into a single flat `cleaned_data.csv`

Run it with:
```bash
cd Python
py install -r requirements.txt
python cleaning.py
```

## 🗄️ SQL — Analysis

`SQL/ecommerce.sql` includes schema creation, indexing, and queries covering total/monthly/yearly sales & profit, category and regional breakdowns, top customers/products/regions, average order value, YoY growth, running totals, window functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`), CTEs, views, and stored procedures.

## 📈 Power BI — Dashboard

Five-page executive dashboard (Executive Summary, Sales Analysis, Customer Analysis, Product Analysis, Regional Analysis) with KPI cards, trend lines, treemaps, maps, matrices, slicers, drill-through, bookmarks, and custom tooltips. Full build steps and every DAX measure are documented in [`PowerBI/PowerBI_Build_Guide.md`](./PowerBI/PowerBI_Build_Guide.md).

## 🖼️ Dashboard Screenshots

_Add exported screenshots from your built dashboard to the `Images/` folder and reference them here, e.g.:_
```markdown
![Executive Summary](./Images/executive_summary.png)
```

## 💡 Key Insights

See [`Docs/Business_Insights.md`](./Docs/Business_Insights.md) for the full breakdown of best/worst performing regions, seasonality, discount impact on margin, and recommendations.

## ⚙️ Installation

```bash
git clone https://github.com/<your-username>/ecommerce-sales-dashboard.git
cd ecommerce-sales-dashboard/Python
pip install -r requirements.txt
python cleaning.py
```

Then import `Python/cleaned_data.csv` into MySQL (see `SQL/ecommerce.sql`) and/or Power BI Desktop (see `PowerBI/PowerBI_Build_Guide.md`).

## 🚀 Usage

1. Regenerate or replace raw data in `Dataset/`
2. Run `Python/cleaning.py` to produce `cleaned_data.csv`
3. Load the cleaned data into MySQL and run `SQL/ecommerce.sql`
4. Open Power BI Desktop and follow `PowerBI_Build_Guide.md` to rebuild/refresh the dashboard

## 🔭 Future Scope

- Automate the pipeline with Apache Airflow for scheduled refreshes
- Add a demand-forecasting model (e.g., Prophet or ARIMA) for next-quarter sales
- Deploy an interactive web version using Streamlit or Power BI Embedded
- Integrate real-time data via an e-commerce platform API

## 📄 License

This project is licensed under the MIT License — see [LICENSE](./LICENSE) for details.

## 👤 Author

**Arul** — Final-Year B.E. Computer Science Engineering Student
*Data Analyst | Full-Stack & AI Development*
