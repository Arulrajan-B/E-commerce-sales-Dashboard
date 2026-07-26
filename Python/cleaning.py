"""
cleaning.py
===========
E-Commerce Sales Dashboard Project
-----------------------------------
Purpose:
    Loads the raw Orders, Customers, and Products data exported from the
    Dataset/ folder, cleans and merges them, engineers analysis-ready
    columns, and exports a single flat file (cleaned_data.csv) that is
    consumed by SQL/ecommerce.sql and the Power BI dashboard.

Author: Data Analytics Team
"""

import logging
import os

import numpy as np
import pandas as pd

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATASET_DIR = os.path.join(BASE_DIR, "Dataset")
OUTPUT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cleaned_data.csv")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Load
# ---------------------------------------------------------------------------

def load_data(dataset_dir: str) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Load the three raw CSV exports. Raises FileNotFoundError with a clear
    message if any file is missing."""
    try:
        orders = pd.read_csv(os.path.join(dataset_dir, "Orders.csv"))
        customers = pd.read_csv(os.path.join(dataset_dir, "Customers.csv"))
        products = pd.read_csv(os.path.join(dataset_dir, "Products.csv"))
    except FileNotFoundError as exc:
        logger.error("Could not find one of the required dataset files: %s", exc)
        raise
    return orders, customers, products


# ---------------------------------------------------------------------------
# Cleaning helpers
# ---------------------------------------------------------------------------

def remove_duplicates(df: pd.DataFrame, subset=None, name: str = "") -> pd.DataFrame:
    before = len(df)
    df = df.drop_duplicates(subset=subset)
    removed = before - len(df)
    if removed:
        logger.info("Removed %d duplicate rows from %s", removed, name)
    return df


def standardize_text_columns(df: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
    """Trim whitespace and apply title case to text columns for consistency."""
    for col in columns:
        if col in df.columns:
            df[col] = df[col].astype(str).str.strip()
            df[col] = df[col].replace({"nan": np.nan, "": np.nan})
    return df


def handle_missing_values(df: pd.DataFrame) -> pd.DataFrame:
    """Impute or drop missing values depending on the column's importance."""
    # Ship Date: if missing, estimate as Order Date + median shipping days
    if "Ship Date" in df.columns and "Order Date" in df.columns:
        median_gap = (df["Ship Date"] - df["Order Date"]).median()
        missing_mask = df["Ship Date"].isna()
        df.loc[missing_mask, "Ship Date"] = df.loc[missing_mask, "Order Date"] + median_gap

    # Discount: assume no discount if missing
    if "Discount" in df.columns:
        df["Discount"] = df["Discount"].fillna(0)

    # Shipping Cost: fill with category-level median
    if "Shipping Cost" in df.columns:
        df["Shipping Cost"] = df["Shipping Cost"].fillna(df["Shipping Cost"].median())

    # Payment Mode: fill with the most frequent mode
    if "Payment Mode" in df.columns:
        mode_value = df["Payment Mode"].mode(dropna=True)
        if not mode_value.empty:
            df["Payment Mode"] = df["Payment Mode"].fillna(mode_value.iloc[0])

    # Drop rows still missing a critical identifier after imputation
    critical_cols = [c for c in ["Order ID", "Customer ID", "Product ID"] if c in df.columns]
    df = df.dropna(subset=critical_cols)
    return df


def remove_invalid_values(df: pd.DataFrame) -> pd.DataFrame:
    """Remove records that fail basic business-rule sanity checks."""
    before = len(df)
    if "Quantity" in df.columns:
        df = df[df["Quantity"] > 0]
    if "Sales" in df.columns:
        df = df[df["Sales"] > 0]
    if "Order Date" in df.columns and "Ship Date" in df.columns:
        df = df[df["Ship Date"] >= df["Order Date"]]
    removed = before - len(df)
    if removed:
        logger.info("Removed %d rows failing business-rule validation", removed)
    return df


# ---------------------------------------------------------------------------
# Feature engineering
# ---------------------------------------------------------------------------

def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    df["Month"] = df["Order Date"].dt.month_name()
    df["Year"] = df["Order Date"].dt.year

    df["Profit Margin"] = np.where(
        df["Sales"] != 0, (df["Profit"] / df["Sales"]) * 100, 0
    ).round(2)

    df["Order Processing Days"] = (df["Ship Date"] - df["Order Date"]).dt.days

    def sales_bucket(sales: float) -> str:
        if sales < 1000:
            return "Low"
        if sales < 10000:
            return "Medium"
        return "High"

    df["Sales Category"] = df["Sales"].apply(sales_bucket)

    return df


# ---------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------

def main() -> None:
    try:
        logger.info("Loading raw data from %s", DATASET_DIR)
        orders, customers, products = load_data(DATASET_DIR)

        # --- Standardize text & remove duplicates in each raw table -------
        customers = standardize_text_columns(
            customers, ["Customer Name", "Segment", "Country", "State", "City", "Region"]
        )
        customers = remove_duplicates(customers, subset=["Customer ID"], name="Customers")
        customers = customers.dropna(subset=["Customer Name", "Customer ID"])

        products = standardize_text_columns(products, ["Category", "Sub Category", "Product Name"])
        products = remove_duplicates(products, subset=["Product ID"], name="Products")

        orders = standardize_text_columns(orders, ["Payment Mode", "Return Status"])
        orders = remove_duplicates(orders, subset=None, name="Orders")

        # --- Convert date columns -----------------------------------------
        orders["Order Date"] = pd.to_datetime(orders["Order Date"], errors="coerce")
        orders["Ship Date"] = pd.to_datetime(orders["Ship Date"], errors="coerce")
        orders = orders.dropna(subset=["Order Date"])

        # --- Handle missing values & invalid values on Orders --------------
        orders = handle_missing_values(orders)
        orders = remove_invalid_values(orders)

        # --- Merge into a single flat, analysis-ready table ----------------
        logger.info("Merging Orders + Customers + Products")
        merged = orders.merge(customers, on="Customer ID", how="inner")
        merged = merged.merge(products, on="Product ID", how="inner")

        # --- Feature engineering --------------------------------------------
        merged = engineer_features(merged)

        # --- Final column order for readability -----------------------------
        final_columns = [
            "Order ID", "Order Date", "Ship Date", "Customer ID", "Customer Name",
            "Segment", "Country", "State", "City", "Postal Code", "Region",
            "Product ID", "Category", "Sub Category", "Product Name",
            "Sales", "Quantity", "Discount", "Profit", "Shipping Cost",
            "Payment Mode", "Return Status", "Month", "Year", "Profit Margin",
            "Order Processing Days", "Sales Category",
        ]
        merged = merged[[c for c in final_columns if c in merged.columns]]

        merged.to_csv(OUTPUT_PATH, index=False)
        logger.info("Cleaned dataset exported to %s (%d rows, %d columns)",
                    OUTPUT_PATH, merged.shape[0], merged.shape[1])

    except Exception:
        logger.exception("Data cleaning pipeline failed")
        raise


if __name__ == "__main__":
    main()
