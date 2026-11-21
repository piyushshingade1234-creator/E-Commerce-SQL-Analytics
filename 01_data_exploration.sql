-- E-Commerce SQL Analytics
-- Phase 1: Data Exploration (Q1-Q5)
-- Database: ecommerce_analytics
USE ecommerce_analytics;

-- Q1. Find the total number of orders.
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q2. List all distinct order statuses.
SELECT DISTINCT status
FROM orders
ORDER BY status;

-- Q3. Count orders by status.
SELECT status, COUNT(*) AS total_orders
FROM orders
GROUP BY status
ORDER BY total_orders DESC;

-- Q4. Find the first and latest order dates.
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS latest_order_date
FROM orders;

-- Q5. Count orders by payment method.
SELECT payment_method, COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;
