# GitHub Repository Guide

## Suggested Commit History

```
chore: initialize repository structure
feat(data): add raw Orders, Customers, and Products datasets
feat(python): add data cleaning and feature engineering pipeline
docs(python): add requirements.txt
feat(sql): add schema, indexes, and full analytical query set
docs(powerbi): add dashboard build guide and DAX measure library
feat(powerbi): add Ecommerce Dashboard.pbix
docs: add README with project overview and usage instructions
docs: add business insights and recommendations
docs: add project report (Report.pdf)
docs: add resume bullet points and interview prep guide
chore: add LICENSE and .gitignore
```

## Folder Descriptions (for README or wiki)

| Folder | Description |
|---|---|
| `Dataset/` | Raw, unprocessed CSV exports (Orders, Customers, Products) |
| `Python/` | Data cleaning pipeline, dependencies, and cleaned output |
| `SQL/` | MySQL schema, indexes, views, stored procedures, and analytical queries |
| `PowerBI/` | Dashboard file and full build guide with DAX measures |
| `Images/` | Dashboard screenshots for the README |
| `Docs/` | Report, business insights, resume bullets, interview prep, GitHub guide |

## Release Notes — v1.0.0

**E-Commerce Sales Dashboard — Initial Release**

- Complete data pipeline: raw data → Python cleaning → MySQL analysis → Power BI dashboard
- 51,000+ order records across 4 years and 6 product categories
- 5-page interactive Power BI dashboard with 15+ DAX measures
- Full documentation: README, project report, business insights, resume bullets, interview prep guide

### How to reproduce
```bash
cd Python && pip install -r requirements.txt && python cleaning.py
```
Then load `cleaned_data.csv` into MySQL via `SQL/ecommerce.sql`, and follow `PowerBI/PowerBI_Build_Guide.md` to rebuild the dashboard.
