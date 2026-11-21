-- Phase 6: Advanced SQL Analysis & Business Insights (Q41-Q50)
USE ecommerce_analytics;

-- Q41. Calculate month-over-month revenue growth.
-- Compares each month with the previous month that has recorded orders.
WITH monthly_revenue AS (
    SELECT
        YEAR(o.order_date) AS years,
        MONTH(o.order_date) AS month_no,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS revenue
    FROM orders o
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
),
previous_revenue AS (
    SELECT *,
        LAG(revenue) OVER (ORDER BY years, month_no) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    years,
    month_no,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(previous_revenue, 2) AS previous_month_revenue,
    ROUND((revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100, 2) AS growth_pct
FROM previous_revenue
ORDER BY years, month_no;

-- Q42. Calculate a running total of monthly revenue.
WITH monthly_revenue AS (
    SELECT
        YEAR(o.order_date) AS years,
        MONTH(o.order_date) AS month_no,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS revenue
    FROM orders o
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
)
SELECT
    years,
    month_no,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(SUM(revenue) OVER (
        ORDER BY years, month_no
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS running_revenue
FROM monthly_revenue
ORDER BY years, month_no;

-- Q43. Find the top 3 products in each category by revenue.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS revenue
    FROM products p
    JOIN order_items ot ON p.product_id = ot.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(revenue, 2) AS revenue,
    category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY category, category_rank, product_name;

-- Q44. Find customer-months where the customer also ordered in the immediately previous calendar month.
WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        YEAR(order_date) AS years,
        MONTH(order_date) AS month_no
    FROM orders
),
previous_month AS (
    SELECT
        customer_id,
        years,
        month_no,
        LAG(years) OVER (PARTITION BY customer_id ORDER BY years, month_no) AS previous_year,
        LAG(month_no) OVER (PARTITION BY customer_id ORDER BY years, month_no) AS previous_month_no
    FROM customer_months
)
SELECT customer_id, years, month_no
FROM previous_month
WHERE years * 12 + month_no = previous_year * 12 + previous_month_no + 1
ORDER BY customer_id, years, month_no;

-- Q45. Rank customers by revenue within each city.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY c.customer_id, c.customer_name, c.city
)
SELECT
    customer_id,
    customer_name,
    city,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (PARTITION BY city ORDER BY revenue DESC) AS city_rank
FROM customer_revenue
ORDER BY city, city_rank;

-- Q46. Calculate the percentage distribution of orders by status.
SELECT
    status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM orders
GROUP BY status
ORDER BY total_orders DESC;

-- Q47. Find employees whose revenue is above their department's average employee revenue.
WITH employee_revenue AS (
    SELECT
        e.employee_id,
        e.employee_name,
        e.department,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS revenue
    FROM employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY e.employee_id, e.employee_name, e.department
),
department_average AS (
    SELECT *,
        AVG(revenue) OVER (PARTITION BY department) AS avg_department_revenue
    FROM employee_revenue
)
SELECT
    employee_id,
    employee_name,
    department,
    ROUND(revenue, 2) AS revenue,
    ROUND(avg_department_revenue, 2) AS avg_department_revenue
FROM department_average
WHERE revenue > avg_department_revenue
ORDER BY department, revenue DESC;

-- Q48. Find each customer's first and last order date and total order count.
SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

-- Q49. Identify products making up the first 80% of cumulative revenue.
-- The last included product may take cumulative revenue slightly above 80%.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS revenue
    FROM products p
    JOIN order_items ot ON p.product_id = ot.product_id
    GROUP BY p.product_id, p.product_name
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_revenue,
        SUM(revenue) OVER () AS total_revenue
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(running_revenue, 2) AS running_revenue,
    ROUND(running_revenue / NULLIF(total_revenue, 0) * 100, 2) AS cumulative_pct
FROM ranked_products
WHERE running_revenue - revenue < total_revenue * 0.80
ORDER BY revenue DESC;

-- Q50. Create a high-level business performance summary.
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS customers_with_orders,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS total_item_revenue,
    ROUND(
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100))
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value,
    COUNT(DISTINCT ot.product_id) AS distinct_products_sold,
    COUNT(DISTINCT o.employee_id) AS employees_handling_orders
FROM orders o
JOIN order_items ot ON o.order_id = ot.order_id;
