-- =====================================================
-- 1. OVERALL SALES KPIs
-- =====================================================

SELECT
    ROUND(SUM(oi.price), 2) AS total_product_sales,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers,

    ROUND(
        SUM(oi.price) * 1.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value,

    ROUND(
        COUNT(*) * 1.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS items_per_order

FROM olist_orders_dataset o

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered';


-- =====================================================
-- 2. Monthly Sales Performance
-- =====================================================


SELECT
    strftime(
        '%Y-%m',
        o.order_purchase_timestamp
    ) AS month,

    ROUND(SUM(oi.price), 2) AS monthly_sales,

    COUNT(DISTINCT o.order_id) AS orders,

    COUNT(DISTINCT c.customer_unique_id) AS customers,

    ROUND(
        SUM(oi.price) * 1.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS aov

FROM olist_orders_dataset o

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'

GROUP BY month
ORDER BY month;



-- =====================================================
-- 3. Month-over-Month Growth
-- =====================================================

WITH monthly_sales AS (
    SELECT
        strftime(
            '%Y-%m',
            o.order_purchase_timestamp
        ) AS month,

        SUM(oi.price) AS total_product_sales,

        COUNT(DISTINCT o.order_id) AS total_orders

    FROM olist_orders_dataset o

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY month
),

monthly_with_previous AS (
    SELECT
        month,
        total_product_sales,
        total_orders,

        LAG(total_product_sales)
        OVER (ORDER BY month) AS previous_month_sales

    FROM monthly_sales
)

SELECT
    month,

    ROUND(total_product_sales, 2)
        AS total_product_sales,

    total_orders,

    ROUND(previous_month_sales, 2)
        AS previous_month_sales,

    ROUND(
        (
            total_product_sales - previous_month_sales
        )
        * 100.0
        / NULLIF(previous_month_sales, 0),
        2
    ) AS sales_growth_pct

FROM monthly_with_previous

ORDER BY month;


-- =====================================================
-- 4. Sales by State
-- =====================================================


SELECT
    c.customer_state,

    ROUND(SUM(oi.price), 2) AS sales,

    COUNT(DISTINCT o.order_id) AS orders,

    COUNT(DISTINCT c.customer_unique_id) AS customers,

    ROUND(
        SUM(oi.price) * 1.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS aov

FROM olist_orders_dataset o

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'

GROUP BY c.customer_state

ORDER BY sales DESC;



-- =====================================================
-- PHASE 3 FINDINGS
-- =====================================================

/*

Overall Performance
-total_product_sales	total_orders	total_customers	    average_order_value	    items_per_order
13221498.11	                96478	        93358	          137.04	                    1.14

Monthly Trend
-

Sales Drivers
-

Regional Performance
-

Business Interpretation
-

*/