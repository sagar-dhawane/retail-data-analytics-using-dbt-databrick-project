# 🛍️ Retail Data Platform — dbt + Databricks

> **Medallion Architecture · SCD Type 2 · Incremental Models · Data Quality Testing**

[![dbt](https://img.shields.io/badge/dbt-1.7-FF694B?style=flat-square&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![Databricks](https://img.shields.io/badge/Databricks-Runtime%2013.x-FF3621?style=flat-square&logo=databricks&logoColor=white)](https://databricks.com/)
[![Delta Lake](https://img.shields.io/badge/Delta%20Lake-Enabled-003366?style=flat-square&logo=apachespark&logoColor=white)](https://delta.io/)
[![License](https://img.shields.io/badge/License-MIT-22C55E?style=flat-square)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Passing-22C55E?style=flat-square)]()

---

## 📌 Project Overview

An end-to-end **retail data engineering pipeline** built on **dbt + Databricks**, transforming raw transactional data into analytics-ready gold tables using the **Medallion Architecture** pattern. The pipeline handles millions of retail records across customers, products, orders, and inventory — with full historical tracking, automated data quality checks, and incremental processing for production-grade performance.

```
Raw Source Data  →  Bronze (Ingestion)  →  Silver (Cleansed)  →  Gold (Aggregated)
     ↓                    ↓                       ↓                      ↓
  CSV / APIs          Delta Tables           SCD Type 2             Business KPIs
                     (Immutable)          (History Tracked)       (BI-Ready Models)
```

---

## 🏗️ Architecture

### Medallion Layers

| Layer | Purpose | Models | Strategy |
|-------|---------|--------|----------|
| 🟫 **Bronze** | Raw ingestion, no transformation | `bronze_orders`, `bronze_customers`, `bronze_products`, `bronze_inventory` | Full load + append |
| 🥈 **Silver** | Cleansed, standardized, deduplicated | `silver_orders`, `silver_customers`, `silver_products` | Incremental + SCD Type 2 |
| 🥇 **Gold** | Aggregated KPIs, business-ready | `gold_sales_summary`, `gold_customer_360`, `gold_product_performance` | Incremental |

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATABRICKS LAKEHOUSE                      │
│                                                                   │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────┐           │
│  │  BRONZE  │    │    SILVER    │    │     GOLD     │           │
│  │          │    │              │    │              │           │
│  │ Raw data │───▶│  Cleansed +  │───▶│  Aggregated  │           │
│  │ as-is    │    │  SCD Type 2  │    │  KPIs & dims │           │
│  │          │    │  Incremental │    │  Incremental │           │
│  └──────────┘    └──────────────┘    └──────────────┘           │
│       ↑                                      ↓                   │
│  ┌─────────┐                        ┌──────────────┐            │
│  │  Seeds  │                        │  Databricks  │            │
│  │ (lookup │                        │  SQL Warehouse│            │
│  │  data)  │                        │  / BI Tools  │            │
│  └─────────┘                        └──────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

---

## ⚙️ Key Features

### 🔄 Incremental Processing
Models are designed with `incremental` materialization to process only **new or changed records**, drastically reducing compute costs on Databricks.

```sql
-- Example: Silver Orders incremental strategy
{{
  config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge',
    on_schema_change='sync_all_columns'
  )
}}

SELECT * FROM {{ ref('bronze_orders') }}
{% if is_incremental() %}
  WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```

### 🕰️ SCD Type 2 — Customer History Tracking
Full Slowly Changing Dimension tracking on the `silver_customers` table captures every change to customer attributes with validity windows.

```sql
-- SCD Type 2 columns tracked
customer_id        -- natural key
email, address,    -- tracked attributes
loyalty_tier       -- (Bronze → Silver → Gold tier changes)
effective_from     -- when this record became active
effective_to       -- when this record was superseded (NULL = current)
is_current         -- boolean flag for active record
dbt_scd_id         -- surrogate key
```

### 🌱 Seeds — Reference Data
Static lookup tables loaded via `dbt seed`:

| Seed File | Description |
|-----------|-------------|
| `region_mapping.csv` | Store region to zone mapping |
| `product_category_hierarchy.csv` | Category → subcategory tree |
| `holiday_calendar.csv` | Retail holiday flags for seasonality |

### 🧪 Data Quality Tests

**Generic Tests** (applied across all layers):
```yaml
- not_null
- unique
- accepted_values
- relationships (referential integrity)
```

**Singular Tests** (custom business logic):
```sql
-- test: orders_total_cannot_be_negative.sql
SELECT order_id FROM {{ ref('silver_orders') }}
WHERE order_total < 0

-- test: scd_no_overlapping_windows.sql
SELECT customer_id FROM {{ ref('silver_customers') }}
GROUP BY customer_id, effective_from, effective_to
HAVING COUNT(*) > 1

-- test: gold_revenue_matches_silver.sql
-- Ensures gold aggregations reconcile with silver transaction totals
```

### 📊 Analyses
Exploratory SQL analyses stored in `/analyses`:

- `customer_lifetime_value_analysis.sql` — LTV segmentation
- `product_return_rate_trends.sql` — return rate YoY
- `store_performance_benchmarking.sql` — regional comparisons

---

## 🗂️ Project Structure

```
retail-data-analytics-using-dbt-databricks-project
├── analyses/
├── dbt_packages/
├── logs/
├── macros/
├── models/
│   ├── bronze/
│   │   ├── bronze_orders.sql
│   │   ├── bronze_products.sql
│   │   ├── bronze_properties.sql
│   │   ├── bronze_reviews.sql
│   │   ├── bronze_users.sql
│   │
│   ├── gold/
│   │   ├── gold_avg_rating_daily.sql
│   │   ├── gold_sales_daily.sql
│   │
│   ├── silver/
│   │   ├── silver_orders.sql
│   │   ├── silver_product.sql
│   │   ├── silver_users.sql
│   │
│   ├── Sources/
│       ├── properties.yml
│
├── seeds/
│   ├── product_categories.csv
│
├── snapshots/
│   ├── product_snapshot.yml
│
├── target/
│
├── tests/
│   ├── source_orders_singular_tests.sql
│
├── .gitignore
├── dbt_project.yml
├── packages.yml
├── package-lock.yml
├── package.json
├── README.md
---

## 🚀 Getting Started

### Prerequisites
- Python 3.8+
- dbt-databricks adapter
- Databricks workspace + SQL Warehouse

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/retail-dbt-databricks.git
cd retail-dbt-databricks

# Install dependencies
pip install dbt-databricks

# Verify connection
dbt debug
```

### Configure `profiles.yml`

```yaml
retail_dbt_project:
  target: dev
  outputs:
    dev:
      type: databricks
      host: <your-databricks-host>.azuredatabricks.net
      http_path: /sql/1.0/warehouses/<warehouse-id>
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      schema: retail_dev
      threads: 4
```

### Run the Pipeline

```bash
# Load seed data
dbt seed

# Run all models (full pipeline)
dbt run

# Run specific layer
dbt run --select bronze
dbt run --select silver
dbt run --select gold

# Run tests
dbt test

# Run tests + models together
dbt build

# Generate & serve documentation
dbt docs generate
dbt docs serve
```

---

## 📈 Gold Layer — Business KPIs

### `gold_sales_summary`
Daily sales aggregations with YoY comparison, avg order value, and revenue by category/region.

### `gold_customer_360`
Customer-level view joining order history, SCD Type 2 attributes, and loyalty tier transitions.

### `gold_product_performance`
Product-level metrics: sell-through rate, return rate, revenue contribution, and inventory turnover.

---

## 🧠 Technical Highlights

| Concept | Implementation |
|---------|---------------|
| **Incremental Strategy** | `merge` on unique keys, watermark-based filtering |
| **SCD Type 2** | dbt snapshots with `timestamp` strategy |
| **Data Lineage** | Full DAG tracked via dbt docs |
| **Databricks Integration** | Unity Catalog + Delta Lake format |
| **Test Coverage** | Generic + singular tests on all 3 layers |
| **Seeds** | Reference/lookup data version-controlled in Git |
| **Analyses** | Ad-hoc SQL compiled but not materialized |

---

## 📦 Tech Stack

| Tool | Role |
|------|------|
| **dbt Core 1.7** | Transformation framework |
| **Databricks** | Cloud data platform + compute |
| **Delta Lake** | ACID-compliant storage layer |
| **Apache Spark** | Distributed processing engine |
| **Unity Catalog** | Governance & data catalog |
| **GitHub Actions** | CI/CD pipeline (dbt build on PR) |

---

## 👤 Author

**Sagar Dhawane**
📧 de.sdhawane@gmail.com
🔗  | [GitHub](https://github.com/sagar-dhawane)

---

> *Built to demonstrate production-grade data engineering patterns using modern lakehouse tooling.*
