-- =====================================================
-- RFM CUSTOMER ANALYSIS
-- 1. CUSTOMER-LEVEL RFM METRICS
-- =====================================================

WITH analysis_date AS (

    SELECT
        date(
            MAX(order_purchase_timestamp),
            '+1 day'
        ) AS snapshot_date

    FROM olist_orders_dataset

    WHERE order_status = 'delivered'
),

customer_rfm AS (

    SELECT
        c.customer_unique_id,

        date(
            MAX(o.order_purchase_timestamp)
        ) AS last_purchase_date,

        CAST(
            julianday(a.snapshot_date)
            -
            julianday(
                date(MAX(o.order_purchase_timestamp))
            )
            AS INTEGER
        ) AS recency_days,

        COUNT(
            DISTINCT o.order_id
        ) AS frequency,

        ROUND(
            SUM(oi.price),
            2
        ) AS monetary

    FROM olist_customers_dataset c

    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    CROSS JOIN analysis_date a

    WHERE o.order_status = 'delivered'

    GROUP BY
        c.customer_unique_id,
        a.snapshot_date
)

SELECT *
FROM customer_rfm

ORDER BY monetary DESC

LIMIT 20;




WITH customer_frequency AS (

    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS frequency

    FROM olist_customers_dataset c

    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
)

SELECT
    frequency,
    COUNT(*) AS customer_count

FROM customer_frequency

GROUP BY frequency

ORDER BY frequency;



WITH analysis_date AS (

    SELECT
        date(
            MAX(order_purchase_timestamp),
            '+1 day'
        ) AS snapshot_date

    FROM olist_orders_dataset

    WHERE order_status = 'delivered'
),

customer_rfm AS (

    SELECT
        c.customer_unique_id,

        CAST(
            julianday(a.snapshot_date)
            -
            julianday(
                date(MAX(o.order_purchase_timestamp))
            )
            AS INTEGER
        ) AS recency_days,

        COUNT(DISTINCT o.order_id) AS frequency,

        SUM(oi.price) AS monetary

    FROM olist_customers_dataset c

    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    CROSS JOIN analysis_date a

    WHERE o.order_status = 'delivered'

    GROUP BY
        c.customer_unique_id,
        a.snapshot_date
),

rfm_scores AS (

    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        ROUND(monetary, 2) AS monetary,

        -- Smaller recency = better
        NTILE(4) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        -- Custom frequency score because 97% bought only once
        CASE
            WHEN frequency = 1 THEN 1
            WHEN frequency = 2 THEN 2
            WHEN frequency = 3 THEN 3
            ELSE 4
        END AS f_score,

        -- Higher monetary = better
        NTILE(4) OVER (
            ORDER BY monetary
        ) AS m_score

    FROM customer_rfm
)

SELECT *
FROM rfm_scores

ORDER BY
    r_score DESC,
    f_score DESC,
    m_score DESC;



-- finding :
-- 1. Most customers are one-time buyers (97%)
-- 2. Most customers are low spenders (75% spent less than $100)
-- Customer acquisition appears much more important than repeat purchasing in this dataset, 
-- as approximately 97% of customers completed only one delivered order. 
-- Traditional loyalty-based segmentation therefore has limited usefulness for this business context.