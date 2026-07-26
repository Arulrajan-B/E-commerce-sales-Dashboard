-- =============================================================================
-- E-COMMERCE SALES DASHBOARD PROJECT
-- File: ecommerce.sql
-- Engine: MySQL 8.0+
-- Description: Schema creation, data load, and full analytical query set
--              built on top of Python/cleaned_data.csv
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. DATABASE & TABLE SETUP
-- -----------------------------------------------------------------------------

DROP DATABASE IF EXISTS ecommerce_dashboard;
CREATE DATABASE ecommerce_dashboard;
USE ecommerce_dashboard;

CREATE TABLE sales (
    order_id            VARCHAR(15),
    order_date          DATE,
    ship_date           DATE,
    customer_id         VARCHAR(15),
    customer_name       VARCHAR(100),
    segment             VARCHAR(30),
    country             VARCHAR(50),
    state               VARCHAR(50),
    city                VARCHAR(50),
    postal_code         VARCHAR(10),
    region              VARCHAR(20),
    product_id          VARCHAR(15),
    category            VARCHAR(50),
    sub_category        VARCHAR(50),
    product_name        VARCHAR(150),
    sales               DECIMAL(12,2),
    quantity            INT,
    discount            DECIMAL(5,2),
    profit              DECIMAL(12,2),
    shipping_cost       DECIMAL(10,2),
    payment_mode        VARCHAR(30),
    return_status       VARCHAR(20),
    month               VARCHAR(15),
    year                INT,
    profit_margin       DECIMAL(6,2),
    order_processing_days INT,
    sales_category      VARCHAR(10),
    PRIMARY KEY (order_id)
);

-- Load the cleaned CSV produced by Python/cleaning.py
-- NOTE: enable local_infile on the server/client if required, and update
-- the path below to the absolute path of cleaned_data.csv on your machine.
--
-- LOAD DATA LOCAL INFILE '/path/to/Python/cleaned_data.csv'
-- INTO TABLE sales
-- FIELDS TERMINATED BY ','
-- OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

CREATE INDEX idx_order_date   ON sales (order_date);
CREATE INDEX idx_customer_id  ON sales (customer_id);
CREATE INDEX idx_product_id   ON sales (product_id);
CREATE INDEX idx_region       ON sales (region);
CREATE INDEX idx_category     ON sales (category);

-- =============================================================================
-- 1. CORE KPI QUERIES
-- =============================================================================

-- Total Sales
SELECT ROUND(SUM(sales), 2) AS total_sales FROM sales;

-- Total Profit
SELECT ROUND(SUM(profit), 2) AS total_profit FROM sales;

-- Overall Profit Margin %
SELECT ROUND(SUM(profit) / SUM(sales) * 100, 2) AS overall_profit_margin_pct FROM sales;

-- Average Order Value (AOV)
SELECT ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value FROM sales;

-- Total Orders & Total Customers
SELECT COUNT(DISTINCT order_id) AS total_orders,
       COUNT(DISTINCT customer_id) AS total_customers
FROM sales;

-- =============================================================================
-- 2. TIME-BASED ANALYSIS
-- =============================================================================

-- Monthly Sales & Profit
SELECT year, month,
       ROUND(SUM(sales), 2)  AS monthly_sales,
       ROUND(SUM(profit), 2) AS monthly_profit
FROM sales
GROUP BY year, month
ORDER BY year, MONTH(order_date);

-- Yearly Sales
SELECT year, ROUND(SUM(sales), 2) AS yearly_sales
FROM sales
GROUP BY year
ORDER BY year;

-- Sales Growth % (Year-over-Year) using a CTE + window function
WITH yearly AS (
    SELECT year, SUM(sales) AS total_sales
    FROM sales
    GROUP BY year
)
SELECT year,
       total_sales,
       ROUND(
         (total_sales - LAG(total_sales) OVER (ORDER BY year))
         / LAG(total_sales) OVER (ORDER BY year) * 100, 2
       ) AS yoy_growth_pct
FROM yearly
ORDER BY year;

-- Running Total of Sales by Month (window function)
WITH monthly AS (
    SELECT year, MONTH(order_date) AS month_num, month,
           SUM(sales) AS monthly_sales
    FROM sales
    GROUP BY year, MONTH(order_date), month
)
SELECT year, month, monthly_sales,
       SUM(monthly_sales) OVER (ORDER BY year, month_num) AS running_total_sales
FROM monthly
ORDER BY year, month_num;

-- =============================================================================
-- 3. PRODUCT & CATEGORY ANALYSIS
-- =============================================================================

-- Category-wise Sales
SELECT category, ROUND(SUM(sales), 2) AS category_sales, ROUND(SUM(profit), 2) AS category_profit
FROM sales
GROUP BY category
ORDER BY category_sales DESC;

-- Sub-Category-wise Sales
SELECT category, sub_category, ROUND(SUM(sales), 2) AS sub_category_sales
FROM sales
GROUP BY category, sub_category
ORDER BY sub_category_sales DESC;

-- Top 10 Products by Sales (RANK + DENSE_RANK + ROW_NUMBER demonstrated together)
SELECT product_name,
       total_sales,
       RANK()       OVER (ORDER BY total_sales DESC) AS sales_rank,
       DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_dense_rank,
       ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS row_num
FROM (
    SELECT product_name, ROUND(SUM(sales), 2) AS total_sales
    FROM sales
    GROUP BY product_name
) product_totals
ORDER BY total_sales DESC
LIMIT 10;

-- Category profitability with CASE WHEN classification
SELECT category,
       ROUND(SUM(profit), 2) AS total_profit,
       CASE
           WHEN SUM(profit) >= 1000000 THEN 'High Profitability'
           WHEN SUM(profit) >= 300000  THEN 'Medium Profitability'
           ELSE 'Low Profitability'
       END AS profitability_tier
FROM sales
GROUP BY category
ORDER BY total_profit DESC;

-- =============================================================================
-- 4. CUSTOMER ANALYSIS
-- =============================================================================

-- Top 10 Customers by Sales
SELECT customer_name, ROUND(SUM(sales), 2) AS customer_sales
FROM sales
GROUP BY customer_name
ORDER BY customer_sales DESC
LIMIT 10;

-- Customer segment performance
SELECT segment,
       COUNT(DISTINCT customer_id) AS customers,
       ROUND(SUM(sales), 2) AS segment_sales,
       ROUND(AVG(sales), 2) AS avg_sale_value
FROM sales
GROUP BY segment
ORDER BY segment_sales DESC;

-- Customers with more than 20 orders (GROUP BY + HAVING)
SELECT customer_id, customer_name, COUNT(order_id) AS order_count
FROM sales
GROUP BY customer_id, customer_name
HAVING COUNT(order_id) > 20
ORDER BY order_count DESC;

-- =============================================================================
-- 5. REGIONAL ANALYSIS
-- =============================================================================

-- Top Regions by Sales
SELECT region, ROUND(SUM(sales), 2) AS region_sales, ROUND(SUM(profit), 2) AS region_profit
FROM sales
GROUP BY region
ORDER BY region_sales DESC;

-- Top States by Sales
SELECT state, ROUND(SUM(sales), 2) AS state_sales
FROM sales
GROUP BY state
ORDER BY state_sales DESC
LIMIT 10;

-- Region + Category matrix (multi-column GROUP BY)
SELECT region, category, ROUND(SUM(sales), 2) AS sales
FROM sales
GROUP BY region, category
ORDER BY region, sales DESC;

-- =============================================================================
-- 6. JOINS EXAMPLE (self-contained demonstration using the same table twice)
-- =============================================================================
-- Compares each customer's most recent order against their first order.
SELECT first_order.customer_id,
       first_order.first_order_date,
       last_order.last_order_date,
       DATEDIFF(last_order.last_order_date, first_order.first_order_date) AS customer_lifetime_days
FROM (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM sales GROUP BY customer_id
) first_order
JOIN (
    SELECT customer_id, MAX(order_date) AS last_order_date
    FROM sales GROUP BY customer_id
) last_order
  ON first_order.customer_id = last_order.customer_id
ORDER BY customer_lifetime_days DESC
LIMIT 20;

-- =============================================================================
-- 7. DATE FUNCTIONS
-- =============================================================================

SELECT order_id,
       order_date,
       DATE_FORMAT(order_date, '%Y-%m') AS order_year_month,
       QUARTER(order_date) AS order_quarter,
       DAYNAME(order_date) AS order_day_name,
       DATEDIFF(ship_date, order_date) AS days_to_ship
FROM sales
LIMIT 20;

-- =============================================================================
-- 8. VIEWS
-- =============================================================================

CREATE OR REPLACE VIEW vw_monthly_performance AS
SELECT year, month,
       ROUND(SUM(sales), 2)  AS monthly_sales,
       ROUND(SUM(profit), 2) AS monthly_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM sales
GROUP BY year, month;

CREATE OR REPLACE VIEW vw_top_customers AS
SELECT customer_id, customer_name, ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY customer_id, customer_name
ORDER BY total_sales DESC;

-- =============================================================================
-- 9. STORED PROCEDURES
-- =============================================================================

DELIMITER $$

CREATE PROCEDURE sp_sales_by_region(IN region_name VARCHAR(20))
BEGIN
    SELECT category,
           ROUND(SUM(sales), 2)  AS total_sales,
           ROUND(SUM(profit), 2) AS total_profit
    FROM sales
    WHERE region = region_name
    GROUP BY category
    ORDER BY total_sales DESC;
END$$

CREATE PROCEDURE sp_top_n_products(IN n INT)
BEGIN
    SELECT product_name, ROUND(SUM(sales), 2) AS total_sales
    FROM sales
    GROUP BY product_name
    ORDER BY total_sales DESC
    LIMIT n;
END$$

DELIMITER ;

-- Example calls:
-- CALL sp_sales_by_region('South');
-- CALL sp_top_n_products(5);

-- =============================================================================
-- 10. DISCOUNT IMPACT ANALYSIS
-- =============================================================================

SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.15 THEN 'Low Discount (<=15%)'
        ELSE 'High Discount (>15%)'
    END AS discount_band,
    ROUND(AVG(profit_margin), 2) AS avg_profit_margin,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY discount_band
ORDER BY avg_profit_margin DESC;

-- =============================================================================
-- END OF FILE
-- =============================================================================
