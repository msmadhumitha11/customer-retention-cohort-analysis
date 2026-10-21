-- =====================================================
-- PROJECT: CUSTOMER RETENTION & COHORT ANALYSIS
-- TOOL: MYSQL WORKBENCH
-- DATABASE: customer_retention_db
-- =====================================================
CREATE DATABASE IF NOT EXISTS
customer_retention_db;


-- SECTION 1: SELECT DATABASE AND CHECK TABLES
USE customer_retention_db;
SELECT DATABASE() AS current_database;

SHOW TABLES;



-- SECTION 2: CHECK ROW COUNTS
SELECT COUNT(*) AS total_customers FROM customers;

SELECT COUNT(*) AS total_orders FROM orders;

SELECT COUNT(*) AS total_products FROM products;

SELECT COUNT(*) AS total_order_items FROM order_items;


-- SECTION 3: VIEW SAMPLE DATA
SELECT * FROM customers LIMIT 10;

SELECT * FROM orders LIMIT 10;

SELECT * FROM products LIMIT 10;

SELECT * FROM order_items LIMIT 10;


-- SECTION 4: DATA QUALITY CHECKS

-- Check duplicate customer IDs
SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check duplicate order IDs
SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check missing important customer information
SELECT *
FROM customers
WHERE customer_id IS NULL
   OR signup_date IS NULL
   OR city IS NULL;

-- Check missing order information
SELECT *
FROM orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR order_date IS NULL
   OR order_status IS NULL;

-- Check orders without a matching customer
SELECT o.*
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check order items without a matching order
SELECT oi.*
FROM order_items AS oi
LEFT JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check order items without a matching product
SELECT oi.*
FROM order_items AS oi
LEFT JOIN products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Check invalid quantities or prices
SELECT *
FROM order_items
WHERE quantity <= 0
   OR unit_price < 0;


-- SECTION 5: OVERALL BUSINESS PERFORMANCE

-- Order status summary
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Overall order counts and unique customers
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;

-- Total revenue from completed orders only
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price), 2)
        AS total_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';

-- Revenue by product category
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)
        AS category_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Best-selling products by revenue
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)
        AS product_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY product_revenue DESC
LIMIT 10;

-- Monthly revenue
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)
        AS monthly_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;


-- SECTION 6: CUSTOMER ANALYSIS

-- Customers by acquisition channel
SELECT
    acquisition_channel,
    COUNT(*) AS total_customers
FROM customers
GROUP BY acquisition_channel
ORDER BY total_customers DESC;

-- Customers by city
SELECT
    city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

-- Completed orders per customer
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS completed_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY completed_orders DESC;

-- Repeat customers
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(*) AS completed_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS repeat_customers
FROM customer_order_counts
WHERE completed_orders >= 2;

-- One-time customers
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(*) AS completed_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS one_time_customers
FROM customer_order_counts
WHERE completed_orders = 1;

-- Repeat customer rate
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(*) AS completed_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS purchasing_customers,
    SUM(completed_orders >= 2) AS repeat_customers,
    ROUND(
        100.0 * SUM(completed_orders >= 2) / COUNT(*),
        2
    ) AS repeat_customer_rate_pct
FROM customer_order_counts;


-- SECTION 7: CUSTOMER REVENUE AND RANKING

-- Revenue generated by each customer
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)
        AS customer_revenue
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY customer_revenue DESC;

-- Rank customers by revenue using a window function
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (ORDER BY revenue DESC)
        AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank;


-- SECTION 8: FIRST AND MOST RECENT PURCHASE

WITH customer_purchase_dates AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date,
        MAX(order_date) AS most_recent_purchase_date,
        COUNT(*) AS completed_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    d.first_purchase_date,
    d.most_recent_purchase_date,
    d.completed_orders
FROM customer_purchase_dates AS d
JOIN customers AS c
    ON c.customer_id = d.customer_id
ORDER BY d.first_purchase_date;


-- SECTION 9: MONTHLY ACTIVE CUSTOMERS

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;


-- SECTION 10: COHORT ANALYSIS
-- Cohort = month of a customer's first completed purchase.
-- Retention = customer makes a completed purchase in a later month.

WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(DATE_FORMAT(order_date, '%Y-%m-01'))
            AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
customer_activity AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m-01')
            AS activity_month
    FROM orders
    WHERE order_status = 'Completed'
),
cohort_activity AS (
    SELECT
        fp.cohort_month,
        ca.activity_month,
        TIMESTAMPDIFF(
            MONTH,
            STR_TO_DATE(fp.cohort_month, '%Y-%m-%d'),
            STR_TO_DATE(ca.activity_month, '%Y-%m-%d')
        ) AS month_number,
        ca.customer_id
    FROM first_purchase AS fp
    JOIN customer_activity AS ca
        ON fp.customer_id = ca.customer_id
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(*) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    a.month_number,
    s.cohort_customers,
    COUNT(DISTINCT a.customer_id) AS retained_customers,
    ROUND(
        100.0 * COUNT(DISTINCT a.customer_id)
        / s.cohort_customers,
        2
    ) AS retention_rate_pct
FROM cohort_activity AS a
JOIN cohort_sizes AS s
    ON a.cohort_month = s.cohort_month
GROUP BY
    a.cohort_month,
    a.month_number,
    s.cohort_customers
ORDER BY
    a.cohort_month,
    a.month_number;


-- SECTION 11: COHORT RETENTION TABLE
-- One row per cohort; columns show activity month numbers.

WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(DATE_FORMAT(order_date, '%Y-%m-01'))
            AS cohort_month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
customer_activity AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m-01')
            AS activity_month
    FROM orders
    WHERE order_status = 'Completed'
),
cohort_activity AS (
    SELECT
        fp.cohort_month,
        TIMESTAMPDIFF(
            MONTH,
            STR_TO_DATE(fp.cohort_month, '%Y-%m-%d'),
            STR_TO_DATE(ca.activity_month, '%Y-%m-%d')
        ) AS month_number,
        ca.customer_id
    FROM first_purchase AS fp
    JOIN customer_activity AS ca
        ON fp.customer_id = ca.customer_id
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(*) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
),
retention AS (
    SELECT
        a.cohort_month,
        a.month_number,
        s.cohort_customers,
        COUNT(DISTINCT a.customer_id) AS retained_customers
    FROM cohort_activity AS a
    JOIN cohort_sizes AS s
        ON a.cohort_month = s.cohort_month
    GROUP BY
        a.cohort_month,
        a.month_number,
        s.cohort_customers
)
SELECT
    cohort_month,
    MAX(cohort_customers) AS cohort_customers,
    MAX(CASE WHEN month_number = 0 THEN
        ROUND(100.0 * retained_customers / cohort_customers, 2)
    END) AS month_0_pct,
    MAX(CASE WHEN month_number = 1 THEN
        ROUND(100.0 * retained_customers / cohort_customers, 2)
    END) AS month_1_pct,
    MAX(CASE WHEN month_number = 2 THEN
        ROUND(100.0 * retained_customers / cohort_customers, 2)
    END) AS month_2_pct,
    MAX(CASE WHEN month_number = 3 THEN
        ROUND(100.0 * retained_customers / cohort_customers, 2)
    END) AS month_3_pct,
    MAX(CASE WHEN month_number = 4 THEN
        ROUND(100.0 * retained_customers / cohort_customers, 2)
    END) AS month_4_pct,
    MAX(CASE WHEN month_number = 5 THEN
        ROUND(100.0 * retained_customers / cohort_customers, 2)
    END) AS month_5_pct
FROM retention
GROUP BY cohort_month
ORDER BY cohort_month;


-- SECTION 12: CUSTOMER ORDER SEQUENCE
-- Use LAG to compare each purchase with the previous purchase.

WITH purchase_sequence AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_date
    FROM orders
    WHERE order_status = 'Completed'
)
SELECT
    customer_id,
    order_id,
    order_date,
    previous_order_date,
    DATEDIFF(order_date, previous_order_date)
        AS days_since_previous_order
FROM purchase_sequence
ORDER BY customer_id, order_date, order_id;


-- SECTION 13: RUNNING REVENUE BY MONTH

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    order_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY order_month
        ),
        2
    ) AS running_revenue
FROM monthly_revenue
ORDER BY order_month;


-- SECTION 14: FINAL PROJECT SUMMARY

SELECT
    (SELECT COUNT(*) FROM customers)
        AS total_registered_customers,
    (SELECT COUNT(*) FROM orders)
        AS total_orders,
    (SELECT COUNT(*)
     FROM orders
     WHERE order_status = 'Completed')
        AS completed_orders,
    (SELECT COUNT(*)
     FROM orders
     WHERE order_status = 'Cancelled')
        AS cancelled_orders,
    (
        SELECT ROUND(SUM(oi.quantity * oi.unit_price), 2)
        FROM orders AS o
        JOIN order_items AS oi
            ON o.order_id = oi.order_id
        WHERE o.order_status = 'Completed'
    ) AS completed_order_revenue;