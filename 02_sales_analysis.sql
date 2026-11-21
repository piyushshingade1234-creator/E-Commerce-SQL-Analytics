-- Phase 2: Sales & Revenue Analysis (Q6-Q12)
USE ecommerce_analytics;

-- Revenue formula used throughout:
-- quantity * unit_price * (1 - discount_pct / 100)
-- Note: Unless filtered by status, this is order-item value across all statuses,
-- not necessarily recognized/realized sales revenue.

-- Q6. Calculate total item revenue after discounts across all orders.
SELECT ROUND(SUM(quantity * unit_price * (1 - discount_pct / 100)), 2) AS total_revenue
FROM order_items;

-- Q7. Calculate monthly revenue, keeping different years separate.
SELECT
    YEAR(o.order_date) AS years,
    MONTH(o.order_date) AS month_no,
    MONTHNAME(o.order_date) AS month_name,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS monthly_revenue
FROM orders o
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY years, month_no;

-- Q8. Calculate revenue by order status.
SELECT
    o.status,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS total_revenue
FROM orders o
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY o.status
ORDER BY total_revenue DESC;

-- Q9. Calculate average order value (AOV) across orders.
WITH order_revenue AS (
    SELECT
        o.order_id,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS order_revenue
    FROM orders o
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY o.order_id
)
SELECT ROUND(AVG(order_revenue), 2) AS average_order_value
FROM order_revenue;

-- Q10. Calculate revenue from delivered orders only.
SELECT
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS delivered_revenue
FROM orders o
JOIN order_items ot ON o.order_id = ot.order_id
WHERE o.status = 'Delivered';

-- Q11. Calculate revenue by year.
SELECT
    YEAR(o.order_date) AS years,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS yearly_revenue
FROM orders o
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY YEAR(o.order_date)
ORDER BY years;

-- Q12. Calculate month-over-month revenue growth.
-- LAG compares with the previous month that has recorded orders.
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
    SELECT
        years,
        month_no,
        revenue,
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
