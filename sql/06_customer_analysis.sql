------------------------------------------
-- Repeat Purchase------------------------
------------------------------------------

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders

    FROM olist_orders_dataset o

    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
)

SELECT
    total_orders,
    COUNT(*) AS customer_count

FROM customer_orders

GROUP BY total_orders

ORDER BY total_orders;

------------------------------------------
-- Repeat Purchase Rate-------------------
------------------------------------------

WITH customer_metrics AS (

    SELECT
        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(oi.price) AS total_product_sales

    FROM olist_customers_dataset c

    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
),

customer_segments AS (

    SELECT
        customer_unique_id,
        total_orders,
        total_product_sales,

        CASE
            WHEN total_orders = 1
                THEN 'One-time Customer'
            ELSE 'Returning Customer'
        END AS customer_type

    FROM customer_metrics
)

SELECT
    customer_type,

    COUNT(*) AS total_customers,

    SUM(total_orders) AS total_orders,

    ROUND(
        SUM(total_product_sales),
        2
    ) AS total_product_sales,

    ROUND(
        AVG(total_orders),
        2
    ) AS orders_per_customer,

    ROUND(
        AVG(total_product_sales),
        2
    ) AS sales_per_customer,

    ROUND(
        SUM(total_product_sales) * 1.0 /
        SUM(total_orders),
        2
    ) AS average_order_value

FROM customer_segments

GROUP BY customer_type;






WITH first_purchase AS (

    SELECT
        c.customer_unique_id,

        strftime(
            '%Y-%m',
            MIN(o.order_purchase_timestamp)
        ) AS first_purchase_month

    FROM olist_orders_dataset o

    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
),

customer_months AS (

    SELECT DISTINCT
        c.customer_unique_id,

        strftime(
            '%Y-%m',
            o.order_purchase_timestamp
        ) AS purchase_month

    FROM olist_orders_dataset o

    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
),

cohort_data AS (

    SELECT
        cm.customer_unique_id,

        fp.first_purchase_month AS cohort_month,

        (
            CAST(
                strftime('%Y', cm.purchase_month || '-01')
                AS INTEGER
            )
            -
            CAST(
                strftime('%Y', fp.first_purchase_month || '-01')
                AS INTEGER
            )
        ) * 12

        +

        (
            CAST(
                strftime('%m', cm.purchase_month || '-01')
                AS INTEGER
            )
            -
            CAST(
                strftime('%m', fp.first_purchase_month || '-01')
                AS INTEGER
            )
        ) AS cohort_index

    FROM customer_months cm

    JOIN first_purchase fp
        ON cm.customer_unique_id = fp.customer_unique_id
),

cohort_counts AS (

    SELECT
        cohort_month,
        cohort_index,

        COUNT(DISTINCT customer_unique_id)
            AS customers

    FROM cohort_data

    GROUP BY
        cohort_month,
        cohort_index
),

cohort_sizes AS (

    SELECT
        cohort_month,
        customers AS cohort_size

    FROM cohort_counts

    WHERE cohort_index = 0
)

SELECT
    cc.cohort_month,
    cc.cohort_index,
    cc.customers,
    cs.cohort_size,

    ROUND(
        cc.customers * 100.0 /
        cs.cohort_size,
        2
    ) AS retention_rate_pct

FROM cohort_counts cc

JOIN cohort_sizes cs
    ON cc.cohort_month = cs.cohort_month

ORDER BY
    cc.cohort_month,
    cc.cohort_index;
