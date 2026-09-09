-- =====================================================
-- 1. REVIEW SCORE AT ORDER LEVEL
-- =====================================================

WITH review_by_order AS (

    SELECT
        order_id,

        ROUND(
            AVG(review_score),
            2
        ) AS order_review_score,

        COUNT(DISTINCT review_id) AS review_count

    FROM olist_order_reviews_dataset

    GROUP BY order_id
)

SELECT *
FROM review_by_order
LIMIT 20;

--------------------------------------
-- Overall Review Distribution--------
--------------------------------------

-- total reviews score
SELECT
    review_score,
    COUNT(*) AS review_count,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS review_share_pct

FROM olist_order_reviews_dataset

GROUP BY review_score

ORDER BY review_score;


-- average review score 
SELECT
    ROUND(AVG(review_score), 2)
        AS average_review_score,

    COUNT(*) AS total_reviews

FROM olist_order_reviews_dataset;





SELECT DISTINCT
    o.order_id,

    COALESCE(
        ct.product_category_name_english,
        'Unknown'
    ) AS category

FROM olist_orders_dataset o

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

JOIN olist_products_dataset p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name_translation ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status = 'delivered';


-----------------------------------------
-- Category Review Analysis--------------
-----------------------------------------


WITH review_by_order AS (

    SELECT
        order_id,
        AVG(review_score) AS order_review_score

    FROM olist_order_reviews_dataset

    GROUP BY order_id
),

order_category AS (

    SELECT DISTINCT
        o.order_id,

        COALESCE(
            ct.product_category_name_english,
            'Unknown'
        ) AS category

    FROM olist_orders_dataset o

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id

    LEFT JOIN product_category_name_translation ct
        ON p.product_category_name = ct.product_category_name

    WHERE o.order_status = 'delivered'
)

SELECT
    oc.category,

    COUNT(*) AS reviewed_orders,

    ROUND(
        AVG(r.order_review_score),
        2
    ) AS average_review_score

FROM order_category oc

JOIN review_by_order r
    ON oc.order_id = r.order_id

GROUP BY oc.category
ORDER BY average_review_score DESC;

------------------------------------------------------
-- Low Rating Rate <= 2 and Five Star Rate by Category-----
------------------------------------------------------


WITH review_by_order AS (

    SELECT
        order_id,
        AVG(review_score) AS order_review_score

    FROM olist_order_reviews_dataset

    GROUP BY order_id
),

order_category AS (

    SELECT DISTINCT
        o.order_id,

        COALESCE(
            ct.product_category_name_english,
            'Unknown'
        ) AS category

    FROM olist_orders_dataset o

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id

    LEFT JOIN product_category_name_translation ct
        ON p.product_category_name = ct.product_category_name

    WHERE o.order_status = 'delivered'
)

SELECT
    oc.category,

    COUNT(*) AS reviewed_orders,

    ROUND(
        AVG(r.order_review_score),
        2
    ) AS average_review_score,

    ROUND(
        SUM(
            CASE
                WHEN r.order_review_score <= 2
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS low_rating_pct,

    ROUND(
        SUM(
            CASE
                WHEN r.order_review_score = 5
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS five_star_pct

FROM order_category oc

JOIN review_by_order r
    ON oc.order_id = r.order_id

GROUP BY oc.category

ORDER BY reviewed_orders DESC;






-- =====================================================
-- 6. CATEGORY SALES + CUSTOMER REVIEWS
-- =====================================================

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
),

review_by_order AS (

    SELECT
        order_id,
        AVG(review_score) AS order_review_score

    FROM olist_order_reviews_dataset

    GROUP BY order_id
),

order_category AS (

    SELECT DISTINCT
        o.order_id,

        COALESCE(
            ct.product_category_name_english,
            'Unknown'
        ) AS category

    FROM olist_orders_dataset o

    JOIN olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    JOIN olist_products_dataset p
        ON oi.product_id = p.product_id

    LEFT JOIN product_category_name_translation ct
        ON p.product_category_name = ct.product_category_name

    WHERE o.order_status = 'delivered'
),

category_reviews AS (

    SELECT
        oc.category,

        COUNT(*) AS reviewed_orders,

        AVG(r.order_review_score)
            AS average_review_score,

        SUM(
            CASE
                WHEN r.order_review_score <= 2
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
            AS low_rating_pct,

        SUM(
            CASE
                WHEN r.order_review_score = 5
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
            AS five_star_pct

    FROM order_category oc

    JOIN review_by_order r
        ON oc.order_id = r.order_id

    GROUP BY oc.category
)

SELECT
    cs.category,

    ROUND(
        cs.total_product_sales,
        2
    ) AS total_product_sales,

    cs.total_orders,

    ROUND(
        cs.total_product_sales * 1.0 /
        cs.total_orders,
        2
    ) AS sales_per_order,

    cr.reviewed_orders,

    ROUND(
        cr.average_review_score,
        2
    ) AS average_review_score,

    ROUND(
        cr.low_rating_pct,
        2
    ) AS low_rating_pct,

    ROUND(
        cr.five_star_pct,
        2
    ) AS five_star_pct,

    ROUND(
        cr.reviewed_orders * 100.0 /
        cs.total_orders,
        2
    ) AS review_coverage_pct

FROM category_sales cs

LEFT JOIN category_reviews cr
    ON cs.category = cr.category

ORDER BY total_product_sales DESC;




-- =====================================================
-- 7. DELIVERY PERFORMANCE VS CUSTOMER REVIEWS
-- =====================================================

WITH review_by_order AS (

    SELECT
        order_id,
        AVG(review_score) AS order_review_score

    FROM olist_order_reviews_dataset

    GROUP BY order_id
),

delivery_review AS (

    SELECT
        o.order_id,

        julianday(
            date(o.order_delivered_customer_date)
        )
        -
        julianday(
            date(o.order_estimated_delivery_date)
        ) AS delay_days,

        r.order_review_score

    FROM olist_orders_dataset o

    JOIN review_by_order r
        ON o.order_id = r.order_id

    WHERE o.order_status = 'delivered'

      AND o.order_delivered_customer_date
          IS NOT NULL

      AND o.order_estimated_delivery_date
          IS NOT NULL
),

delivery_groups AS (

    SELECT
        order_id,
        delay_days,
        order_review_score,

        CASE
            WHEN delay_days <= 0
                THEN 'On Time / Early'

            WHEN delay_days <= 3
                THEN '1-3 Days Late'

            WHEN delay_days <= 7
                THEN '4-7 Days Late'

            ELSE '8+ Days Late'
        END AS delivery_group

    FROM delivery_review
)

SELECT
    delivery_group,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(delay_days),
        2
    ) AS average_delay_days,

    ROUND(
        AVG(order_review_score),
        2
    ) AS average_review_score,

    ROUND(
        SUM(
            CASE
                WHEN order_review_score <= 2
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS low_rating_pct,

    ROUND(
        SUM(
            CASE
                WHEN order_review_score = 5
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS five_star_pct

FROM delivery_groups

GROUP BY delivery_group

ORDER BY
    CASE delivery_group
        WHEN 'On Time / Early' THEN 1
        WHEN '1-3 Days Late' THEN 2
        WHEN '4-7 Days Late' THEN 3
        WHEN '8+ Days Late' THEN 4
    END;

