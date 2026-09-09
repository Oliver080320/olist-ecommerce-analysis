---------------------------------------------
-- Step 1：Category Sales Performance--------
---------------------------------------------

SELECT
    COALESCE(
        ct.product_category_name_english,
        'Unknown'
    ) AS category,

    ROUND(SUM(oi.price), 2) AS total_product_sales,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(*) AS total_items,

    ROUND(
        SUM(oi.price) * 1.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS sales_per_order

FROM olist_orders_dataset o

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

JOIN olist_products_dataset p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY category

ORDER BY total_product_sales DESC;


---------------------------------------------
-- Step 2：Category Sales Share Percentage---
---------------------------------------------
WITH category_sales AS (

    SELECT
        COALESCE(
            ct.product_category_name_english,
            'Unknown'
        ) AS category,

        SUM(oi.price) AS total_product_sales,

        COUNT(DISTINCT o.order_id) AS total_orders

    FROM olist_orders_dataset o

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id

    LEFT JOIN product_category_name_translation ct
        ON p.product_category_name = ct.product_category_name

    WHERE o.order_status = 'delivered'

    GROUP BY category
)

SELECT
    category,


    ROUND(total_product_sales, 2)
        AS total_product_sales,
    total_orders,

    ROUND(
        total_product_sales * 100.0 /
        SUM(total_product_sales) OVER (),
        2
    ) AS sales_share_pct

FROM category_sales

ORDER BY total_product_sales DESC;


---------------------------------------------------
-- Step 3：Sales Concentration / Pareto Analysis---
---------------------------------------------------
WITH category_sales AS (

    SELECT
        COALESCE(
            ct.product_category_name_english,
            'Unknown'
        ) AS category,

        SUM(oi.price) AS total_product_sales

    FROM olist_orders_dataset o

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id

    LEFT JOIN product_category_name_translation ct
        ON p.product_category_name = ct.product_category_name

    WHERE o.order_status = 'delivered'

    GROUP BY category
),

ranked_categories AS (

    SELECT
        category,
        total_product_sales,

        ROW_NUMBER() OVER (
            ORDER BY total_product_sales DESC
        ) AS sales_rank,

        SUM(total_product_sales) OVER (
            ORDER BY total_product_sales DESC
        ) AS cumulative_sales,

        SUM(total_product_sales) OVER ()
            AS overall_sales

    FROM category_sales
)

SELECT
    category,

    sales_rank,

    ROUND(total_product_sales, 2)
        AS total_product_sales,

    SUM(total_product_sales) OVER (
    ORDER BY total_product_sales DESC
    ) AS cumulative_sales,

    ROUND(
        cumulative_sales * 100.0 /
        overall_sales,
        2
    ) AS cumulative_sales_pct

FROM ranked_categories

ORDER BY sales_rank;

------------------------------
-- Top Products---------------
------------------------------

SELECT
    oi.product_id,

    COALESCE(
        ct.product_category_name_english,
        'Unknown'
    ) AS category,

    ROUND(SUM(oi.price), 2)
        AS total_product_sales,

    COUNT(*) AS items_sold,

    COUNT(DISTINCT o.order_id)
        AS total_orders

FROM olist_orders_dataset o

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

JOIN olist_products_dataset p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY
    oi.product_id,
    category

ORDER BY total_product_sales DESC

LIMIT 20;


