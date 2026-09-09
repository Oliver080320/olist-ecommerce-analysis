---------------------------------------------------
--- Order Data Quality Checks----------------------
---------------------------------------------------

--- Check for missing values
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) 
        AS missing_order_id,

    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)
        AS missing_customer_id,

    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END)
        AS missing_order_status,

    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END)
        AS missing_purchase_date,

    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END)
        AS missing_delivery_date,

    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END)
        AS missing_estimated_delivery_date

FROM olist_orders_dataset;

SELECT COUNT(*)
FROM olist_orders_dataset;

--- Check Order Status
SELECT
    order_status,
    COUNT(*) AS order_count
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY order_count DESC;

--- Check for missing delivery dates by order status
SELECT
    order_status,
    COUNT(*) AS missing_delivery_date_count
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY missing_delivery_date_count DESC;

--- Check Duplicate Orders
SELECT
    order_id,
    COUNT(*) AS row_count
FROM olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

--- Check for orders with order_approved_at before order_purchase_timestamp
SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at
FROM olist_orders_dataset
WHERE order_approved_at < order_purchase_timestamp;

SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM olist_orders_dataset
WHERE order_delivered_customer_date < order_purchase_timestamp;



---------------------------------------------------
--- Customer Data Quality Checks-------------------
---------------------------------------------------

--- Check for missing values
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)
        AS missing_customer_id,

    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END)
        AS missing_unique_customer_id,

    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END)
        AS missing_city,

    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END)
        AS missing_state

FROM olist_customers_dataset;

--- Check Customer State
SELECT
    customer_state,
    COUNT(*) AS customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY customers DESC;



---------------------------------------------------
--- Payment Data Quality Checks--------------------
---------------------------------------------------

--- check for missing values
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END)
        AS missing_order_id,

    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END)
        AS missing_payment_sequential,

    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END)
        AS missing_payment_type,

    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END)
        AS missing_payment_installments,

    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END)
        AS missing_payment_value

FROM olist_order_payments_dataset;


--- Check Payment Types and their counts
SELECT
    payment_type,
    COUNT(*) AS payment_count
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY payment_count DESC;

--- Check negative payment values
SELECT *
FROM olist_order_payments_dataset
WHERE payment_value < 0;

--- Check negative payment installments
SELECT *
FROM olist_order_payments_dataset
WHERE payment_installments < 0;

---------------------------------------------------
--- Order Item Data Quality Checks-----------------
---------------------------------------------------

--- check for missing values
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END)
        AS missing_order_id,

    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END)
        AS missing_order_item_id,

    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END)
        AS missing_product_id,

    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END)
        AS missing_seller_id,

    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END)
        AS missing_shipping_limit_date,

    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END)
        AS missing_price,

    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END)
        AS missing_freight

FROM olist_order_items_dataset;

--- Check for duplicate order_id and order_item_id combinations
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS row_count
FROM olist_order_items_dataset
GROUP BY
    order_id,
    order_item_id
HAVING COUNT(*) > 1;

--- check for negative values in price and freight_value
SELECT *
FROM olist_order_items_dataset
WHERE price <= 0
   OR freight_value < 0;

--- check for order item values in price
SELECT *
FROM olist_order_items_dataset
WHERE order_item_id <= 0;


---------------------------------------------------
--- Review Data Quality Checks---------------------
---------------------------------------------------

--- check for missing values. Missing comment (58247)
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END)
        AS missing_review_id,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END)
        AS missing_order_id,

    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END)
        AS missing_review_score,

    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END)
        AS missing_comment

FROM olist_order_reviews_dataset;


--- Check review scores and their counts
SELECT
    review_score,
    COUNT(*) AS review_count
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;


---------------------------------------------------
--- Seller Data Quality Checks---------------------
---------------------------------------------------

--- check for missing values
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END)
        AS missing_seller_id,

    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END)
        AS missing_city,

    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END)
        AS missing_state

FROM olist_sellers_dataset;

--- Check seller states and their counts
SELECT
    seller_state,
    COUNT(*) AS sellers
FROM olist_sellers_dataset
GROUP BY seller_state
ORDER BY sellers DESC;



---------------------------------------------------
--- Geolocation Data Quality Checks----------------
---------------------------------------------------

--- check for missing values
SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END)
        AS missing_zip,

    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END)
        AS missing_lat,

    SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END)
        AS missing_lng

FROM olist_geolocation_dataset;

--- Check for duplicate geolocation_zip_code_prefix, geolocation_lat, geolocation_lng combinations
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS row_count
FROM olist_geolocation_dataset
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

# /*

# PHASE 2: DATA QUALITY FINDINGS

1. Orders

---

* Missing values:
  2,965 records have missing order_delivered_customer_date.

* Most missing delivery dates are associated with orders that
  were not completed, such as shipped, canceled, unavailable,
  processing, or invoiced orders.

* However, 8 orders have order_status = 'delivered' while
  order_delivered_customer_date is NULL.
  These records should be treated carefully in any delivery-time analysis.

* Duplicate order IDs:
  None detected.

* Order status distribution:
  delivered      96,478
  shipped         1,107
  canceled          625
  unavailable       609
  invoiced          314
  processing        301
  created             5
  approved            2

* Date validity:
  No invalid chronological relationships were detected in the
  date checks performed.

Conclusion:
The orders table is generally reliable. Missing delivery dates are
mostly explained by incomplete orders, but the 8 delivered orders
without an actual delivery date should be excluded from analyses that
require confirmed delivery timestamps.

2. Customers

---

* Missing values:
  None detected in the fields checked.

* Duplicate customer_id:
  None detected.

* State values:
  No invalid or unexpected state values were detected.

Conclusion:
The customer table has good overall data quality.

Note:
customer_id identifies the customer record associated with an order,
while customer_unique_id should be used later when identifying the
same customer across multiple orders.

3. Order Items

---

* Missing values:
  None detected in the main analytical fields checked.

* Duplicate candidate key:
  No duplicates detected for (order_id, order_item_id).

* Price validity:
  No negative price values were detected.

* Freight validity:
  No negative freight values were detected.

* Zero freight:
  383 order-item records have freight_value = 0.

Conclusion:
The order-items table has strong data quality.
Zero freight values should not automatically be treated as errors,
because they may represent free-shipping orders or promotions.
These records should therefore be retained unless later evidence
suggests otherwise.

4. Payments

---

* Missing values:
  None detected in the main payment fields checked.

* Invalid payment values:
  No negative payment values were detected.

* Payment types:
  The main payment methods are:
  credit_card
  boleto
  voucher
  debit_card

  There are also 3 records where payment_type = 'not_defined'.

* The 3 not_defined payment records have payment_value = 0.

* Multiple payment records per order are possible because an order
  may be paid using more than one payment method.

Conclusion:
The payment table is generally reliable.
The 3 not_defined payment records represent a small anomaly and should
normally be excluded from payment-method or revenue analysis.

Payment data should be aggregated at order level before joining to
other one-to-many tables when order-level metrics are required.

5. Products

---

* product_id:
  No missing values detected.

* product_category_name:
  610 products have no product category.

* Product descriptive fields:
  The same group of products also contains missing values in fields
  such as product name length, description length, and photo quantity.

* Physical dimensions:
  2 products have missing values in product weight and dimension fields.

Conclusion:
Product IDs are complete, so products can still be linked to order
items reliably.

Products with missing category information should be retained but
classified as Unknown/Uncategorised during category-level analysis.

The 2 products with missing physical dimensions should be excluded
only from analyses that specifically depend on weight or dimensions.

6. Reviews

---

* review_id:
  No missing values detected.

* order_id:
  No missing values detected.

* review_score:
  No missing values detected.

* Review score validity:
  Review scores fall within the expected range of 1 to 5.

* review_comment_title:
  87,656 missing values.

* review_comment_message:
  58,247 missing values.

Conclusion:
Missing review text is not considered a data-quality error because
customers are able to submit a rating without writing a title or
comment.

Review scores can therefore be used independently of written review
content.

For future text or sentiment analysis, only reviews containing
review_comment_message should be included.

7. Sellers

---

* Missing values:
  None detected in the main seller fields checked.

* seller_id:
  No duplicate seller IDs detected.

* seller states:
  No major validity issues detected.

Conclusion:
The seller table is suitable for seller-level and geographic analysis.

8. Geolocation

---

* Missing latitude/longitude values:
  No major missing-value issue was detected in the fields checked.

* ZIP code prefixes:
  geolocation_zip_code_prefix is not unique.

* Multiple coordinates may exist for the same ZIP code prefix.

* Duplicate or repeated geographic observations are present in the
  raw geolocation dataset.

Conclusion:
The geolocation table should NOT be joined directly to customers or
sellers at its raw grain because one ZIP prefix can match many
geolocation rows.

Doing so may multiply rows and inflate analytical results.

Before geographic analysis, the table should be aggregated to one
representative location per ZIP code prefix, for example using the
average or median latitude and longitude.

9. Product Category Translation

---

* Missing values:
  None detected.

* Duplicate product_category_name:
  None detected.

* The lookup table contains one translation record per category.

Conclusion:
The translation table has good data quality and can be used to convert
Portuguese product-category names into English.

===============================
OVERALL DATA QUALITY CONCLUSION
===============================

The Olist dataset has generally strong structural and logical quality.

No major integrity problems were identified in core identifiers,
prices, review scores, or customer/seller records.

The main issues that need to be considered in later analysis are:

1. Missing delivery timestamps, including a small number of delivered
   orders without confirmed delivery dates.

2. Missing product-category and product-dimension information.

3. Large amounts of missing written review content, which represent
   optional customer behaviour rather than invalid records.

4. A very small number of undefined payment records.

5. Multiple records per ZIP code in the geolocation table, which can
   cause row multiplication during joins.

6. One-to-many relationships in order_items and order_payments, which
   require careful aggregation before calculating order-level metrics.

Based on these checks, the dataset is suitable for further analysis,
provided these issues are handled appropriately in downstream queries.
*/

