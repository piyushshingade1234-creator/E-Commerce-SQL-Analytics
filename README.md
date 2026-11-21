# E-Commerce SQL Analytics

## Project overview
An end-to-end SQL analysis project using a fictional e-commerce database and MySQL. The project explores order activity, revenue, products, customers, employee performance, and business-level KPIs.

## Tools
- MySQL / MySQL Workbench
- SQL: joins, aggregation, subqueries, CTEs, CASE, window functions, date functions

## Database
Database name: `ecommerce_analytics`

Tables:
- `customers`: customer details and signup information
- `employees`: employee details, department, city, hire date, salary
- `products`: product name, category, unit price, stock
- `orders`: customer, employee, order date, status, payment method, shipping city
- `order_items`: product, quantity, unit price, discount

## Project analysis
| Phase | Questions | Focus |
|---|---:|---|
| Data Exploration | Q1-Q5 | Order volume, statuses, dates, payment methods |
| Sales Analysis | Q6-Q12 | Revenue, AOV, delivered revenue, yearly and monthly trends |
| Product Analysis | Q13-Q17 | Best-selling products, category revenue, stock |
| Customer Analysis | Q18-Q31 | Customer activity, spending, segmentation, retention patterns |
| Employee Analysis | Q32-Q40 | Employee revenue, ranking, monthly performance |
| Advanced Analysis | Q41-Q50 | Growth, running totals, rankings, Pareto-style analysis, KPIs |

## How to use
1. Create or select the `ecommerce_analytics` database.
2. Ensure the five tables and their data are loaded.
3. Open the SQL scripts in the `sql/` folder in MySQL Workbench.
4. Run each phase script in order.
5. Save selected query result screenshots in `results/`.
6. Replace or supplement `business_insights.md` with findings from your actual query outputs.

## Important metric note
The revenue formula is:

`quantity * unit_price * (1 - discount_pct / 100)`

Unless a query filters by order status, the resulting value is the discounted order-item value associated with all recorded orders. It should not automatically be described as recognized revenue, because cancelled and returned orders may be included.

## Repository contents
- `sql/`: six phase-wise SQL scripts containing Q1-Q50
- `results/`: place for screenshots or exported result samples
- `business_insights.md`: template for documenting findings

## Data note
This is a learning/portfolio project using synthetic practice data. Do not add real customer information, credentials, or confidential company data.
