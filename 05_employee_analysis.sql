-- Phase 5: Employee Performance Analysis (Q32-Q40)
USE ecommerce_analytics;

-- Q32. Calculate total orders and revenue handled by each employee.
-- COUNT(DISTINCT) prevents an order being counted once per item row.
SELECT
    e.employee_id,
    e.employee_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS total_revenue
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY e.employee_id, e.employee_name
ORDER BY total_revenue DESC;

-- Q33. Find the top 5 employees by revenue.
SELECT
    e.employee_id,
    e.employee_name,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS total_revenue
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY e.employee_id, e.employee_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Q34. Count orders by employee and order status.
-- Query orders directly so each order is counted exactly once.
SELECT
    e.employee_id,
    e.employee_name,
    o.status,
    COUNT(o.order_id) AS total_orders
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
GROUP BY e.employee_id, e.employee_name, o.status
ORDER BY e.employee_id, o.status;

-- Q35. Calculate average revenue per order for each employee.
WITH order_revenue AS (
    SELECT
        o.employee_id,
        o.order_id,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS total_revenue
    FROM orders o
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY o.employee_id, o.order_id
)
SELECT
    e.employee_id,
    e.employee_name,
    ROUND(AVG(r.total_revenue), 2) AS average_order_revenue
FROM employees e
JOIN order_revenue r ON e.employee_id = r.employee_id
GROUP BY e.employee_id, e.employee_name
ORDER BY average_order_revenue DESC;

-- Q36. Rank employees by total revenue.
WITH employee_revenue AS (
    SELECT
        e.employee_id,
        e.employee_name,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS total_revenue
    FROM employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY e.employee_id, e.employee_name
)
SELECT
    employee_id,
    employee_name,
    ROUND(total_revenue, 2) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS employee_rank
FROM employee_revenue
ORDER BY employee_rank;

-- Q37. Find the highest-revenue employee(s) in each department.
WITH employee_revenue AS (
    SELECT
        e.employee_id,
        e.employee_name,
        e.department,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS total_revenue
    FROM employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY e.employee_id, e.employee_name, e.department
),
ranked_employees AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY department
            ORDER BY total_revenue DESC
        ) AS department_rank
    FROM employee_revenue
)
SELECT
    department,
    employee_id,
    employee_name,
    ROUND(total_revenue, 2) AS total_revenue,
    department_rank
FROM ranked_employees
WHERE department_rank = 1
ORDER BY total_revenue DESC;

-- Q38. Calculate monthly revenue for each employee.
SELECT
    e.employee_id,
    e.employee_name,
    YEAR(o.order_date) AS years,
    MONTH(o.order_date) AS month_no,
    MONTHNAME(o.order_date) AS month_name,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS monthly_revenue
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY
    e.employee_id, e.employee_name,
    YEAR(o.order_date), MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY e.employee_id, years, month_no;

-- Q39. Calculate each employee's contribution to total employee revenue.
WITH employee_revenue AS (
    SELECT
        e.employee_id,
        e.employee_name,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS total_revenue
    FROM employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY e.employee_id, e.employee_name
)
SELECT
    employee_id,
    employee_name,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_revenue / NULLIF(SUM(total_revenue) OVER (), 0) * 100, 2) AS contribution_pct
FROM employee_revenue
ORDER BY contribution_pct DESC;

-- Q40. Find employees whose revenue is above the average revenue per ordering employee.
WITH employee_revenue AS (
    SELECT
        e.employee_id,
        e.employee_name,
        e.department,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS total_revenue
    FROM employees e
    JOIN orders o ON e.employee_id = o.employee_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY e.employee_id, e.employee_name, e.department
)
SELECT
    employee_id,
    employee_name,
    department,
    ROUND(total_revenue, 2) AS total_revenue
FROM employee_revenue
WHERE total_revenue > (SELECT AVG(total_revenue) FROM employee_revenue)
ORDER BY total_revenue DESC;
