-----------------------------------------------------------------------------------------------------
-- check the number and the names of tables in the database------------------------------------------
-----------------------------------------------------------------------------------------------------

SELECT name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;

-----------------------------------------------------------------------------------------------------
-- display the first 10 rows of each table in the database-------------------------------------------
-----------------------------------------------------------------------------------------------------

SELECT *
FROM olist_customers_dataset
limit 10;

SELECT *
FROM olist_geolocation_dataset
limit 10;

SELECT *
FROM olist_order_items_dataset
limit 10;

SELECT *
FROM olist_order_payments_dataset
limit 10;

SELECT *
FROM olist_order_reviews_dataset
limit 10;

SELECT *
FROM olist_orders_dataset
limit 10;

SELECT *
FROM olist_products_dataset
limit 10;

SELECT *
FROM olist_sellers_dataset
limit 10;

SELECT *
FROM product_category_name_translation
limit 10;


-----------------------------------------------------------------------------------------------------
-- check the field names and data types of each table in the database--------------------------------
-----------------------------------------------------------------------------------------------------

PRAGMA table_info(olist_orders_dataset);
PRAGMA table_info(olist_order_items_dataset);
PRAGMA table_info(olist_order_payments_dataset);
PRAGMA table_info(olist_order_reviews_dataset);
PRAGMA table_info(olist_products_dataset);
PRAGMA table_info(olist_sellers_dataset);
PRAGMA table_info(product_category_name_translation);
PRAGMA table_info(olist_geolocation_dataset);
PRAGMA table_info(olist_customers_dataset);


-----------------------------------------------------------------------------------------------------
-- check the number of rows and unique values to ensure the primary key of each table in the database
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- check the grain of the data in the order_items and order_payments tables--------------------------
-----------------------------------------------------------------------------------------------------

--- olist_customers_dataset
--- grain of the data is customer_id
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT customer_unique_id) AS unique_customer_ids
FROM olist_customers_dataset;

--- olist_order_items_dataset
--- grain of the data is order_id and order_item_id
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(DISTINCT seller_id) AS unique_sellers,
    COUNT(DISTINCT order_item_id) AS unique_order_items
FROM olist_order_items_dataset;

SELECT
    order_id,
    COUNT(*) AS item_rows
FROM olist_order_items_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY item_rows DESC
LIMIT 10;

SELECT *
FROM olist_order_items_dataset
WHERE order_id = '8272b63d03f5f79c56e9e4120aec44ef';

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS row_count
FROM olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

--- olist_order_reviews_dataset
--- grain of the data is review_id and order_id
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT review_id) AS unique_reviews,
    COUNT(DISTINCT order_id) AS unique_orders
FROM olist_order_reviews_dataset;

SELECT
    review_id,
    order_id,
    COUNT(*) AS row_count
FROM olist_order_reviews_dataset
GROUP BY review_id, order_id
HAVING COUNT(*) > 1;


--- olist_orders_dataset
--- grain of the data is order_id and customer_id
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM olist_orders_dataset;

--- olist_sellers_dataset
--- grain of the data is seller_id, so we will check the number of unique seller_id values
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT seller_id) AS unique_sellers
FROM olist_sellers_dataset;

--- olist_products_dataset
--- grain of the data is product_id, so we will check the number of unique product_id values
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_products
FROM olist_products_dataset;

--- olist_order_payments_dataset
--- grain of the data is order_id and payment_sequential
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM olist_order_payments_dataset;

SELECT
    order_id,
    COUNT(*) AS payment_rows
FROM olist_order_payments_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_rows DESC
LIMIT 10;

SELECT *
FROM olist_order_payments_dataset
WHERE order_id = 'fa65dad1b0e818e3ccc5cb0e39231352';

SELECT
    payment_sequential,
    order_id,
    COUNT(*) AS row_count
FROM olist_order_payments_dataset
GROUP BY payment_sequential, order_id
HAVING COUNT(*) > 1;


-----------------------------------------------------------------------------------------------------
-- check the foreign key relationships between the tables in the database----------------------------
-----------------------------------------------------------------------------------------------------


--- olist_orders_dataset 
SELECT COUNT(*) AS unmatched_orders
FROM olist_orders_dataset o
LEFT JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

--- olist_order_items_dataset
SELECT COUNT(*) AS unmatched_order_items
FROM olist_order_items_dataset oi
LEFT JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS UNMATCHED_ORDER_ITEMS
FROM olist_order_items_dataset oii
LEFT JOIN olist_sellers_dataset s
    ON oii.seller_id = s.seller_id
WHERE s.seller_id IS NULL;





/*
PHASE 1 FINDINGS

1. Customers
   Grain:
   One row per customer_id / order-level customer record

   Candidate key:
   customer_id

   Important fields:
   customer_id,
   customer_unique_id,
   customer_zip_code_prefix,
   customer_city,
   customer_state

   Notes:
   customer_unique_id represents the same underlying customer
   across different orders.


2. Orders
   Grain:
   One row per order

   Candidate key:
   order_id

   Foreign key:
   customer_id -> olist_customers_dataset.customer_id

   Important fields:
   order_id,
   customer_id,
   order_status,
   order_purchase_timestamp,
   order_delivered_customer_date,
   order_estimated_delivery_date


3. Order Items
   Grain:
   One row per item within an order

   Candidate key:
   (order_id, order_item_id)

   Foreign keys:
   order_id   -> olist_orders_dataset.order_id
   product_id -> olist_products_dataset.product_id
   seller_id  -> olist_sellers_dataset.seller_id

   Important fields:
   order_id,
   order_item_id,
   product_id,
   seller_id,
   price,
   freight_value


4. Payments
   Grain:
   One row per payment record within an order

   Candidate key:
   (order_id, payment_sequential)

   Foreign key:
   order_id -> olist_orders_dataset.order_id

   Important fields:
   order_id,
   payment_sequential,
   payment_type,
   payment_installments,
   payment_value


5. Reviews
   Grain:
   One row per review record associated with an order

   Candidate key:
   TO BE VERIFIED

   Foreign key:
   order_id -> olist_orders_dataset.order_id

   Important fields:
   review_id,
   order_id,
   review_score,
   review_comment_title,
   review_comment_message,
   review_creation_date,
   review_answer_timestamp


6. Products
   Grain:
   One row per product

   Candidate key:
   product_id

   Important fields:
   product_id,
   product_category_name,
   product_weight_g,
   product_length_cm,
   product_height_cm,
   product_width_cm


7. Sellers
   Grain:
   One row per seller

   Candidate key:
   seller_id

   Important fields:
   seller_id,
   seller_zip_code_prefix,
   seller_city,
   seller_state


8. Geolocation
   Grain:
   One geolocation record for a ZIP code prefix and coordinate

   Candidate key:
   No confirmed candidate key in the raw dataset

   Important fields:
   geolocation_zip_code_prefix,
   geolocation_lat,
   geolocation_lng,
   geolocation_city,
   geolocation_state


9. Category Translation
   Grain:
   One row per product category translation

   Candidate key:
   product_category_name

   Important fields:
   product_category_name,
   product_category_name_english
*/

-- Geolocation 的组合是否真的唯一
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    COUNT(*) AS row_count
FROM olist_geolocation_dataset
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng
HAVING COUNT(*) > 1
ORDER BY row_count DESC;