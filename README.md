# Olist E-Commerce Data Analysis

**SQL + Python analysis of 96K+ delivered orders from the Brazilian E-Commerce Public Dataset by Olist.**

This project explores sales performance, product mix, customer experience, delivery performance, and customer retention using a relational e-commerce dataset.

---

## Project Snapshot

| Metric | Result |
|---|---:|
| Product Sales | **13.22M** |
| Delivered Orders | **96,478** |
| Unique Customers | **93,358** |
| Average Order Value | **137.04** |
| Items per Order | **1.14** |
| One-Time Customers | **~97%** |

### Key takeaway

> Olist's sales performance was driven primarily by **transaction volume and customer acquisition**, while repeat purchasing remained extremely low.

---

## Business Questions

This analysis focuses on five practical questions:

1. **How did sales performance change over time?**
2. **Which states and product categories generated the most value?**
3. **Was growth driven by more orders or higher order values?**
4. **How was customer satisfaction associated with delivery performance?**
5. **Were customers returning after their first purchase?**

---

## Tech Stack

`SQL` · `SQLite` · `Python` · `pandas` · `matplotlib` · `Jupyter Notebook` · `VS Code` · `Git`

---

## Repository Structure

```text
olist-ecommerce-analysis/
├── notebook/
│   └── 01_cohort_analysis.ipynb
│
├── sql/
│   ├── 01_data_understanding.sql
│   ├── 02_data_quality.sql
│   ├── 03_sales_analysis.sql
│   ├── 04_product_analysis.sql
│   ├── 05_review_analysis.sql
│   ├── 06_customer_analysis.sql
│   └── 07_rfm_analysis.sql
│
├── load_data.py
├── .gitignore
└── README.md
```

---

# Analysis

## 1. Data Understanding

Before calculating metrics, I first established the **grain, candidate keys, and relationships** of each table.

Examples:

- `orders`: one row per order
- `order_items`: one row per item within an order
- `payments`: one row per payment record
- `products`: one row per product

This was important because several Olist tables have **one-to-many relationships**.

For example:

```text
orders
  1
  │
  └── N order_items
```

A direct join can duplicate order-level data, so metrics such as order count use:

```sql
COUNT(DISTINCT order_id)
```

and some tables are aggregated before joining.

---

## 2. Data Quality

The dataset was checked for:

- missing values
- duplicate identifiers
- invalid numeric values
- inconsistent dates
- categorical anomalies
- foreign-key mismatches

### Notable findings

- **2,965 orders** had no customer delivery date.
- Missing delivery dates were mostly associated with incomplete orders.
- Product categories contained some missing values.
- Review text was often missing, but review scores were still usable.
- Geolocation ZIP prefixes were not unique and require aggregation before joining.

The analysis therefore distinguishes between **true data-quality issues** and **valid business missingness**.

---

## 3. Sales Performance

Only delivered orders were included in completed-sales metrics.

```sql
WHERE order_status = 'delivered'
```

Product sales were calculated using:

```sql
SUM(order_items.price)
```

### Overall performance

- **13.22M** in product sales
- **96,478** delivered orders
- **93,358** unique customers
- **137.04** average order value
- **1.14** items per order

### Monthly trend

Sales increased strongly through 2017 before stabilising at a higher level during 2018.

A particularly strong month was **November 2017**:

- Sales increased **52.37% MoM**
- Order volume increased sharply
- AOV decreased from **144.76 to 135.51**

**Interpretation:** the sales increase was primarily **volume-driven**, not caused by customers spending more per order.

August 2018 showed the opposite pattern:

- Orders increased
- Customers increased
- Sales decreased **3.38%**
- AOV fell from **140.92 to 132.04**

**Interpretation:** higher transaction volume was not enough to offset lower spending per order.

---

## 4. Regional Performance

São Paulo was the dominant market.

| State | Product Sales | Orders | AOV |
|---|---:|---:|---:|
| SP | 5.07M | 40,501 | 125.12 |
| RJ | 1.76M | 12,350 | 142.48 |
| MG | 1.55M | 11,354 | 136.73 |

São Paulo generated approximately **38% of total product sales**, despite having an AOV below the overall average.

**Interpretation:** SP's strength came mainly from **scale and transaction volume**.

---

## 5. Product & Category Performance

The analysis compared:

- total product sales
- order volume
- order-item volume
- sales per order
- sales share
- cumulative sales share

### Leading categories

| Category | Product Sales | Orders | Sales / Order |
|---|---:|---:|---:|
| health_beauty | 1.23M | 8,647 | 142.61 |
| watches_gifts | 1.17M | 5,495 | 212.23 |
| bed_bath_table | 1.02M | 9,272 | 110.38 |
| sports_leisure | 954.9K | 7,530 | 126.81 |
| computers_accessories | 888.7K | 6,530 | 136.10 |

### Different category economics

**bed_bath_table**
- high order volume
- relatively lower sales per order
- **volume-driven**

**watches_gifts**
- fewer orders
- much higher sales per order
- **value-driven**

**computers**
- only 177 orders
- sales per order of **1,235.50**
- **low-volume, high-value niche**

### Sales concentration

- Top 3 categories: **~25.9%** of sales
- Top 5 categories: **~39.8%**
- Top 10 categories: **~62.4%**

---

## 6. Customer Experience

Review data was first aggregated to **order level** before being combined with order-item data.

This avoids row multiplication from joining multiple one-to-many tables.

The analysis compared:

- average review score
- low-rating rate
- five-star rate
- review coverage
- delivery delay

### Delivery vs review

Delivery performance was grouped into:

- On Time / Early
- 1–3 Days Late
- 4–7 Days Late
- 8+ Days Late

The goal was to test whether increasing delivery delay was **associated with** poorer customer satisfaction.

Because this is observational data, the project avoids making causal claims.

---

## 7. Customer Behaviour & Retention

Customer purchase frequency showed a highly unusual pattern:

| Orders per Customer | Customers |
|---:|---:|
| 1 | **90,557** |
| 2 | 2,573 |
| 3 | 181 |
| 4+ | very small |

Approximately **97% of customers placed only one delivered order**.

### Why I did not force traditional RFM segmentation

Traditional RFM relies heavily on meaningful variation in purchase frequency.

In this dataset:

```text
~97% of customers → Frequency = 1
```

This makes Frequency a weak segmentation variable.

Instead of mechanically applying RFM, I treated this as a business finding and focused on **first-purchase behaviour and retention**.

---

## 8. Cohort Retention

Customers were grouped by their first purchase month and tracked across subsequent months.

```text
M0 = first purchase month
M1 = one month later
M2 = two months later
...
```

For meaningful cohorts from 2017 onward:

- M1 retention was generally **below 1%**
- repeat activity remained very low in later months
- some late-2017 cohorts performed slightly better
- there was no consistent long-term improvement

**Interpretation:** the business appears to rely much more on **new customer acquisition** than repeat purchasing.

---

# Key Findings

### 1. Sales growth was mainly volume-driven
Strong growth periods were more closely associated with increases in order count than higher AOV.

### 2. São Paulo dominated through scale
SP generated the largest share of sales despite below-average order value.

### 3. Category performance had different drivers
Some categories succeeded through volume, while others relied on higher value per order.

### 4. Sales were moderately concentrated
The top 10 categories generated roughly **62% of product sales**.

### 5. Repeat purchasing was extremely weak
Approximately **97% of customers purchased only once**.

### 6. Traditional RFM was not a good fit
The analysis was adapted based on the observed data rather than forcing a standard framework.

---

# Business Recommendations

Based on the analysis:

**Improve second-purchase conversion**  
With ~97% one-time customers, converting recent first-time buyers into a second purchase may be more valuable than traditional loyalty segmentation.

**Protect high-volume categories**  
Categories such as `bed_bath_table` depend heavily on transaction volume, so availability and fulfilment reliability are important.

**Grow high-value categories carefully**  
Categories such as `watches_gifts` and `computers` show strong value per order and may benefit from targeted acquisition.

**Monitor delivery experience**  
Delivery-delay analysis should be used alongside review scores to identify operational issues associated with poor customer experience.

**Track both volume and value**  
Sales should always be interpreted together with order count and AOV; either can materially change overall performance.

---

# Skills Demonstrated

### SQL
- JOINs
- CTEs
- `CASE WHEN`
- aggregation
- date functions
- window functions
- `LAG()`
- `ROW_NUMBER()`
- cumulative sums
- cohort calculations

### Data Analysis
- KPI design
- sales-driver analysis
- data-quality validation
- customer behaviour
- cohort retention
- category concentration
- customer experience analysis

### Data Modelling
- table grain
- candidate keys
- foreign keys
- one-to-many relationships
- avoiding row multiplication

### Python
- pandas
- pivot tables
- cohort matrices
- matplotlib

---

## Next Steps

Potential extensions:

- exploratory data analysis (EDA)
- first-order experience vs repeat purchase
- seller performance analysis
- geographic visualisation
- Power BI executive dashboard

---

## Dataset

**Brazilian E-Commerce Public Dataset by Olist**

The dataset contains anonymised Brazilian e-commerce orders, customers, products, payments, sellers, reviews, and delivery information.
