-- Phase 4: Customer Analysis (Q18-Q31)
USE ecommerce_analytics;

-- Q18. Count customers by city.
SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

-- Q19. Find customers who have never placed an order.
SELECT c.customer_id, c.customer_name, c.city
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);

-- Q20. Find the top 5 customers by spending after discounts.
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Q21. Find repeat customers (more than one order).
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- Q22. Show each ordering customer's total orders and total spending.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC;

-- Q23. Classify every customer as No Orders, One Order, or Repeat Customer.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    CASE
        WHEN COUNT(o.order_id) = 0 THEN 'No Orders'
        WHEN COUNT(o.order_id) = 1 THEN 'One Order'
        ELSE 'Repeat Customer'
    END AS customer_type
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Q24. Rank customers by total spending.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_revenue, 2) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank, customer_id;

-- Q25. Calculate each customer's spending by year and month.
SELECT
    c.customer_id,
    c.customer_name,
    YEAR(o.order_date) AS years,
    MONTH(o.order_date) AS month_no,
    MONTHNAME(o.order_date) AS month_name,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS monthly_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY
    c.customer_id, c.customer_name,
    YEAR(o.order_date), MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY c.customer_id, years, month_no;

-- Q26. Find the highest-spending customer(s) in each city.
WITH customer_revenue AS (
    SELECT
        c.city,
        c.customer_id,
        c.customer_name,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY c.city, c.customer_id, c.customer_name
),
ranked_customers AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY city ORDER BY total_revenue DESC) AS city_rank
    FROM customer_revenue
)
SELECT city, customer_id, customer_name, ROUND(total_revenue, 2) AS total_revenue, city_rank
FROM ranked_customers
WHERE city_rank = 1
ORDER BY total_revenue DESC;

-- Q27. Calculate average days between consecutive orders for each customer.
WITH customer_order_dates AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_date,
        LAG(o.order_date) OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date, o.order_id
        ) AS previous_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
),
order_gaps AS (
    SELECT
        customer_id,
        customer_name,
        DATEDIFF(order_date, previous_order_date) AS days_between_orders
    FROM customer_order_dates
    WHERE previous_order_date IS NOT NULL
)
SELECT
    customer_id,
    customer_name,
    ROUND(AVG(days_between_orders), 1) AS average_days_between_orders
FROM order_gaps
GROUP BY customer_id, customer_name
ORDER BY average_days_between_orders;

-- Q28. Find customers who placed orders in both 2024 and 2025.
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING
    COUNT(DISTINCT CASE WHEN YEAR(o.order_date) = 2024 THEN YEAR(o.order_date) END) > 0
    AND
    COUNT(DISTINCT CASE WHEN YEAR(o.order_date) = 2025 THEN YEAR(o.order_date) END) > 0;

-- Q29. Find customers with lifetime spending greater than 50,000.
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items ot ON o.order_id = ot.order_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) > 50000
ORDER BY lifetime_value DESC;

-- Q30. Segment customers by spending: High > 50,000; Medium >= 20,000; otherwise Low.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_revenue, 2) AS total_revenue,
    CASE
        WHEN total_revenue > 50000 THEN 'High Value'
        WHEN total_revenue >= 20000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_revenue
ORDER BY total_revenue DESC;

-- Q31. Calculate each customer's contribution to total customer spending.
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items ot ON o.order_id = ot.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_spending, 2) AS total_spending,
    ROUND(total_spending / NULLIF(SUM(total_spending) OVER (), 0) * 100, 2) AS contribution_pct
FROM customer_spending
ORDER BY contribution_pct DESC;
