-- E-Commerce SQL Analytics: database schema
-- Compatible with MySQL 8.0+
CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    country VARCHAR(80) NOT NULL,
    signup_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(80) NOT NULL,
    city VARCHAR(80) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(80) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    shipping_city VARCHAR(80) NOT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS order_items (
    item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);
