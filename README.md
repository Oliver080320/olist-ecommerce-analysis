Brazilian E-Commerce Analysis — Olist

Project Overview

This project analyses the Brazilian E-Commerce Public Dataset by Olist using SQL and Python. The objective is to move beyond dashboard-style reporting and answer practical business questions around:

overall sales performance,

product-category performance,

regional performance,

customer satisfaction,

delivery experience,

repeat purchasing,

and customer retention.

The analysis was completed primarily in SQLite / SQL inside VS Code, with Python, pandas, and matplotlib used for cohort analysis and visualisation.

Business Questions

The project was structured around the following questions:

How has completed product sales performance changed over time?

Is sales growth driven mainly by order volume or by higher spending per order?

Which states contribute most to sales?

Which product categories are high-volume versus high-value?

How concentrated are sales across product categories?

How does customer satisfaction vary across product categories?

Is delivery delay associated with lower review scores?

How often do customers return after their first purchase?

Does the business appear to rely more on repeat purchasing or customer acquisition?

Dataset

The Olist dataset contains multiple relational tables covering customers, orders, order items, payments, reviews, products, sellers, category translations, and geolocation.

Main tables

Table

Grain

Candidate key

olist_customers_dataset

One row per customer record

customer_id

olist_orders_dataset

One row per order

order_id

olist_order_items_dataset

One row per item within an order

(order_id, order_item_id)

olist_order_payments_dataset

One row per payment record within an order

(order_id, payment_sequential)

olist_order_reviews_dataset

One row per review record associated with an order

review_id / verified at source level

olist_products_dataset

One row per product

product_id

olist_sellers_dataset

One row per seller

seller_id

olist_geolocation_dataset

Multiple geographic observations per ZIP-code prefix

No single confirmed raw-table key

product_category_name_translation

One row per category translation

product_category_name

Core relationships

erDiagram
    CUSTOMERS ||--o{ ORDERS : customer_id
    ORDERS ||--o{ ORDER_ITEMS : order_id
    ORDERS ||--o{ PAYMENTS : order_id
    ORDERS ||--o{ REVIEWS : order_id
    PRODUCTS ||--o{ ORDER_ITEMS : product_id
    SELLERS ||--o{ ORDER_ITEMS : seller_id
    CATEGORY_TRANSLATION ||--o{ PRODUCTS : product_category_name

A key modelling decision was to use customer_unique_id when identifying the same underlying customer across multiple orders.

Tools

VS Code

SQLite

SQLTools / SQLite extensions

SQL

Python

pandas

matplotlib

Jupyter Notebook

Git / GitHub

Project Structure

olist-ecommerce-analysis/
│
├── data/
│   └── Olist CSV files
│
├── sql/
│   ├── project.db
│   ├── 01_data_understanding.sql
│   ├── 02_data_quality.sql
│   ├── 03_sales_analysis.sql
│   ├── 04_product_analysis.sql
│   ├── 05_review_analysis.sql
│   └── 06_customer_analysis.sql
│
├── notebooks/
│   └── 01_cohort_analysis.ipynb
│
└── README.md

Analysis Workflow

1. Data Understanding

The first phase focused on understanding table grain, candidate keys, relationships, and one-to-many joins before calculating any business metrics.

This step was important because directly joining tables such as:

orders -> order_items, and

orders -> order_payments

can multiply rows and overstate metrics if the target grain is not controlled.

Examples of safeguards used later in the analysis include:

COUNT(DISTINCT order_id)

and pre-aggregating payment or review records before joining them to other one-to-many tables.

2. Data Quality

Data-quality checks covered:

missing values,

duplicate identifiers,

invalid values,

date consistency,

categorical consistency,

and referential integrity.

Main observations

order_id and customer_id checks did not identify duplicate primary identifiers in the core order/customer tables.

2,965 orders had a missing order_delivered_customer_date.

Missing delivery dates were interpreted in the context of order status rather than automatically treated as invalid data.

Review comments contain substantial missing text, but this is not necessarily an error because customers can submit ratings without comments.

Raw geolocation data contains multiple records for a ZIP-code prefix, so it should not be directly joined to transactional data without prior aggregation.

The dataset was considered suitable for analysis once these structural issues were accounted for.

3. Sales Performance Analysis

For consistent completed-sales analysis, only:

order_status = 'delivered'

was included.

SUM(order_items.price) is described as product sales / GMV-style sales, rather than accounting revenue.

Overall KPIs

KPI

Result

Total product sales

13,221,498.11

Delivered orders

96,478

Unique customers

93,358

Average order value

137.04

Items per order

1.14

Interpretation

The business processed a large number of completed transactions, but the low 1.14 items per order indicates relatively small baskets.

The number of orders is also only slightly above the number of unique customers, which initially suggested weak repeat-purchase behaviour. This was later confirmed in the customer analysis.

Monthly Sales Trend

Monthly sales grew substantially through 2017 and then stabilised at a higher level during 2018.

Notable examples:

January 2017 product sales: 111,798.36

November 2017 product sales: 987,765.37

May 2018 product sales: 977,544.69

November 2017 recorded a strong 52.37% month-over-month increase in product sales.

However, AOV declined from 144.76 to 135.51, while order volume increased sharply.

Insight

The November 2017 sales increase was primarily volume-driven, rather than caused by higher customer spending per order.

August 2018 showed the opposite pattern:

orders increased,

customers increased,

but product sales declined by 3.38%,

while AOV fell from 140.92 to 132.04.

Insight

Higher transaction volume did not automatically create higher sales when average spending per order declined.

4. Regional Performance

São Paulo was the dominant customer market.

State

Product sales

Orders

AOV

SP

5,067,633.16

40,501

125.12

RJ

1,759,651.13

12,350

142.48

MG

1,552,481.83

11,354

136.73

Key observations

São Paulo contributed approximately 38.33% of total product sales.

It also represented approximately 41.98% of delivered orders.

SP's AOV of 125.12 was below the overall AOV of 137.04.

Insight

São Paulo's performance was driven primarily by scale and transaction volume, rather than unusually high spending per order.

Smaller states sometimes recorded much higher AOVs, but their limited order volumes meant they contributed relatively little to total sales.

5. Product & Category Analysis

Category performance was analysed using:

total product sales,

order volume,

order-item volume,

sales per order,

sales share,

and cumulative sales share.

Leading categories

Category

Product sales

Orders

Sales per order

health_beauty

1,233,131.72

8,647

142.61

watches_gifts

1,166,176.98

5,495

212.23

bed_bath_table

1,023,434.76

9,272

110.38

sports_leisure

954,852.55

7,530

126.81

computers_accessories

888,724.61

6,530

136.10

High-volume vs high-value examples

bed_bath_table

highest order volume among the leading categories,

9,272 orders,

lower sales per order of 110.38.

This is primarily a high-volume category.

watches_gifts

fewer orders than several other leading categories,

but sales per order of 212.23.

This is more strongly value-driven.

computers

only 177 orders,

but sales per order of 1,235.50.

This represents a low-volume, high-value niche.

Sales concentration

Top 3 categories generated approximately 25.89% of total product sales.

Top 5 categories generated approximately 39.83%.

Top 10 categories generated approximately 62.43%.

Insight

Olist sales were concentrated in a group of leading categories, but category success was not driven by a single pattern: some categories depended on high transaction volume while others relied on high value per order.

6. Review & Customer Experience Analysis

Review analysis was performed carefully at order level before being associated with product categories.

This avoided multiplying review records when joining them with order-item-level data.

Metrics included:

average review score,

reviewed orders,

low-rating percentage,

five-star percentage,

review coverage,

and delivery performance.

For category-level interpretation, review scores were described as:

reviews for orders containing the category

rather than product-specific satisfaction, because an order can contain multiple product categories.

Delivery Performance vs Reviews

Delivery performance was calculated as:

actual delivery date - estimated delivery date

and grouped into:

On Time / Early

1–3 Days Late

4–7 Days Late

8+ Days Late

The purpose of this analysis was to test whether increasing delivery delay was associated with declining customer satisfaction.

Because the dataset is observational, conclusions are phrased as associations, not causal claims.

7. Customer Behaviour & Retention

Purchase Frequency

Customer purchase-frequency analysis produced a highly imbalanced distribution:

Orders per customer

Customers

1

90,557

2

2,573

3

181

4

28

5

9

6

5

7

3

9

1

15

1

Approximately 97% of customers placed only one delivered order.

Only around 3% made more than one purchase.

Insight

Olist customer behaviour in this dataset is overwhelmingly one-time-purchase driven.

This finding made a traditional RFM loyalty segmentation less useful, because Frequency provides almost no differentiation for the vast majority of customers.

Rather than forcing an RFM framework, the analysis was adapted to focus on customer acquisition, first-purchase experience, and retention.

8. Cohort Retention Analysis

Customers were grouped by their first purchase month and tracked across subsequent months.

The analysis used:

M0 = first purchase month
M1 = one month after first purchase
M2 = two months after first purchase
...

The very small 2016 cohorts were excluded from the main business interpretation.

For meaningful cohorts from 2017 onward:

Month-1 retention generally ranged from approximately 0.18% to 0.72%.

Repeat purchasing remained below 1% in most individual subsequent months.

Some late-2017 cohorts showed relatively stronger short-term retention.

There was no consistent long-term improvement in retention across the full observation period.

Insight

Most customers did not return in the months immediately following their first purchase.

This supports the purchase-frequency result and suggests that Olist sales in this period were much more dependent on customer acquisition and transaction volume than on frequent repeat purchasing.

Key Business Findings

Sales growth was mainly volume-driven.
Major growth periods were more strongly associated with increases in completed orders than with increases in AOV.

AOV still materially influenced monthly performance.
August 2018 showed that increasing order volume could be offset by lower customer spending per order.

São Paulo dominated through scale.
SP generated over 38% of total product sales despite having a below-average AOV.

Category performance followed different business models.
Categories such as bed_bath_table were volume-driven, while categories such as watches_gifts relied more heavily on higher sales per order.

Sales were moderately concentrated.
The top 10 categories accounted for approximately 62.43% of product sales.

Repeat purchasing was exceptionally weak.
Approximately 97% of customers completed only one delivered order.

Traditional RFM segmentation was therefore not an appropriate primary method.
The analysis was adapted instead of mechanically applying a framework that did not fit the observed customer behaviour.

Customer acquisition and first-order experience appear especially important.
Extremely low monthly cohort retention suggests that second-purchase conversion is a more relevant business question than traditional loyalty segmentation.

Analytical Caveats

Product sales vs revenue

This project uses:

SUM(order_items.price)

as product sales.

It should not be interpreted as accounting revenue because the dataset does not provide a complete view of:

commissions,

refunds,

seller payouts,

operating costs,

or other accounting adjustments.

Missing calendar months

Month-over-month calculations using LAG() compare the previous available row, not automatically the previous calendar month.

The very sparse 2016 data was therefore excluded from the main trend interpretation.

Category reviews

Reviews are provided at order level. If an order contains multiple categories, a review cannot be uniquely attributed to one specific product category.

Retention

Monthly cohort retention measures customer activity in each individual month. It is not a survival-retention metric and therefore does not need to decrease monotonically.

What I Learned

This project strengthened practical skills in:

SQL

joins,

grouping and aggregation,

CASE WHEN,

CTEs,

date functions,

window functions,

LAG(),

ROW_NUMBER(),

cumulative sums,

data-grain management,

and preventing row multiplication.

Data Analysis

KPI definition,

sales-driver analysis,

customer behaviour analysis,

cohort retention,

category concentration,

customer-experience analysis,

and distinguishing correlation from causation.

Data Modelling

understanding grain,

candidate keys,

foreign keys,

one-to-many relationships,

and pre-aggregating data before joins.

Python

pandas pivot tables,

cohort matrices,

and matplotlib visualisation.

Future Improvements

Possible extensions include:

first-order experience vs repeat-purchase analysis,

order-value distribution and additional EDA,

delivery-delay distributions,

customer-acquisition analysis,

seller-performance analysis,

geographic visualisation,

and a lightweight Power BI executive dashboard.

Summary

This project demonstrates an end-to-end analytical workflow:

Raw relational data
        ↓
Data understanding
        ↓
Data-quality validation
        ↓
SQL analysis
        ↓
Customer and product insights
        ↓
Python cohort visualisation
        ↓
Business interpretation

The main takeaway is that Olist's completed sales performance was driven largely by transaction volume and customer acquisition, while repeat purchasing remained unusually low. The project therefore prioritised analytical methods that fit the observed business behaviour rather than applying standard customer-segmentation techniques mechanically.
