-- Phase 3: Product Analysis (Q13-Q17)
USE ecommerce_analytics;

-- Q13. Find the top 5 products by quantity sold.
SELECT
    p.product_id,
    p.product_name,
    SUM(ot.quantity) AS total_quantity_sold
FROM products p
JOIN order_items ot ON p.product_id = ot.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- Q14. Find the top 5 products by revenue after discounts.
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS total_revenue
FROM products p
JOIN order_items ot ON p.product_id = ot.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Q15. Calculate revenue by product category.
SELECT
    p.category,
    ROUND(SUM(ot.quantity * ot.unit_price * (1 - ot.discount_pct / 100)), 2) AS category_revenue
FROM products p
JOIN order_items ot ON p.product_id = ot.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Q16. Find products that have never been ordered.
SELECT
    p.product_id,
    p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items ot
    WHERE ot.product_id = p.product_id
);

-- Q17. Find products with stock below 10 units.
SELECT product_id, product_name, stock
FROM products
WHERE stock < 10
ORDER BY stock ASC;
