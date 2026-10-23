## Customer Retention & Cohort Analysis Using MySQL

**A Data Analytics Project | SQL | Customer Behavior | Revenue Analysis | Cohort Retention**

## 📌 Project Overview

This project analyzes e-commerce customer purchasing behavior, revenue, repeat purchases, and customer retention using **MySQL**.

Using four datasets — customers, orders, products, and order items — this project explores purchasing patterns, identifies repeat customers, analyzes revenue, and measures monthly customer retention through cohort analysis.

## 🎯 Business Problem

Businesses need to understand whether customers return after their first purchase, how purchasing behavior changes over time, and which customer cohorts demonstrate stronger retention.

This project uses SQL to analyze these patterns and support data-driven business decisions.

## 🎯 Project Objectives

- Analyze customer purchasing behavior and transaction performance.
- Calculate revenue from completed orders.
- Identify repeat customers and one-time customers.
- Measure the repeat customer rate.
- Analyze revenue by product and product category.
- Calculate monthly customer retention using cohort analysis.
- Identify customer retention trends and improvement opportunities.

## 🛠️ Tools & Technologies

- **Database:** MySQL
- **SQL Environment:** MySQL Workbench
- **Query Language:** SQL
- **SQL Concepts:** JOINs, aggregate functions, subqueries, CTEs, window functions, and date functions.

## 📂 Dataset Description

| Dataset | Description |
|---|---|
| Customers | Customer details and identifiers |
| Orders | Order dates, customer relationships, and order statuses |
| Products | Product details and categories |
| Order Items | Product-level order details, quantities, and prices |

## 🔍 Analysis Performed

- **Data Quality Analysis:** Checked missing values, duplicate records, invalid values, and table relationships.
- **Business Performance Analysis:** Analyzed order statuses, revenue, monthly revenue, and product performance.
- **Customer Behavior Analysis:** Identified repeat customers, one-time customers, and customer-level revenue.
- **Purchase Analysis:** Examined first and most recent purchase dates and time between consecutive purchases.
- **Cohort Analysis:** Grouped customers by their first completed purchase month and calculated monthly retention rates.
- **Advanced SQL Analysis:** Used CTEs, `DENSE_RANK()`, `LAG()`, and window functions.

## 📊 Key Findings

The SQL analysis generates results for:

- Total customers and orders.
- Revenue from completed orders.
- Repeat customer count and rate.
- Revenue by product and category.
- Monthly revenue and active customers.
- Monthly cohort retention percentages.
- Customer rankings and purchase intervals.

*Add actual numerical findings after validating the SQL query results.*

## 💡 Business Recommendations

- **Encourage Repeat Purchases:** Investigate opportunities to improve repeat purchasing.
- **Improve Customer Retention:** Examine cohorts with lower retention rates.
- **Optimize Product Performance:** Identify products and categories contributing the most revenue.
- **Monitor Customer Engagement:** Evaluate purchasing frequency and retention trends.

## ▶️ How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Import the four datasets into MySQL.
3. Create or select the database `customer_retention_db`.
4. Open the `SQL` file in MySQL Workbench.
5. Execute the queries in the documented order.
6. Review the customer behavior, revenue, and cohort retention results.

## ⚠️ Limitations

- Results depend on the quality and completeness of the source data.
- Revenue calculations may exclude discounts, refunds, or other adjustments not included in the queries.
- Recent cohorts may have shorter observation periods than older cohorts.
- Historical retention patterns do not guarantee future customer behavior.

## 🚀 Future Improvements

- Create a cohort retention heatmap.
- Build an interactive dashboard using Power BI.
- Organize SQL queries into separate files.
- Add screenshots of key results and business insights.

## 👩‍💻 Author

**M. S. Madhumitha**

Aspiring Data Analyst

**GitHub:** [msmadhumitha11](https://github.com/msmadhumitha11)

**Project Repository:** [Customer Retention & Cohort Analysis](https://github.com/msmadhumitha11/customer-retention-cohort-analysis)
