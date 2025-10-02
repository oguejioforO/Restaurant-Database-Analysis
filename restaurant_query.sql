-- Create database
CREATE DATABASE IF NOT EXISTS restaurant;
USE restaurant;

-- Create menu_items table
CREATE TABLE menu_items(
    menu_item_id INT PRIMARY KEY,
    item_name VARCHAR(30),
    category VARCHAR(30),
    price DECIMAL(8,2)
);

-- Create orders table
CREATE TABLE orders(
    order_details_id INT PRIMARY KEY,
    order_id INT,
    order_date DATE,
    order_time TIME,
    item_id INT
);

-- Load CSV data (optional)
-- LOAD DATA INFILE 'C:/order_details.csv'
-- INTO TABLE orders
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- View menu items
SELECT * FROM menu_items;

-- Count number of items on the menu
SELECT COUNT(menu_item_id) AS total_menu_items FROM menu_items;

-- Least and most expensive items
SELECT item_name, price FROM menu_items WHERE price = (SELECT MIN(price) FROM menu_items);
SELECT item_name, price FROM menu_items WHERE price = (SELECT MAX(price) FROM menu_items);

-- Italian dishes count and extremes
SELECT COUNT(*) AS italian_count FROM menu_items WHERE category = 'Italian';
SELECT item_name, price FROM menu_items WHERE category = 'Italian' ORDER BY price ASC LIMIT 1;
SELECT item_name, price FROM menu_items WHERE category = 'Italian' ORDER BY price DESC LIMIT 1;

-- Number of dishes per category
SELECT category, COUNT(*) AS num_dishes FROM menu_items GROUP BY category;

-- Average price per category
SELECT category, AVG(price) AS avg_price FROM menu_items GROUP BY category;

-- Orders date range
SELECT MIN(order_date) AS start_date, MAX(order_date) AS end_date FROM orders;

-- Total orders and unique items in date range
SELECT COUNT(DISTINCT order_id) AS total_orders, COUNT(DISTINCT item_id) AS total_items
FROM orders
WHERE order_date BETWEEN (SELECT MIN(order_date) FROM orders) AND (SELECT MAX(order_date) FROM orders);

-- Orders with most items
SELECT order_id, COUNT(item_id) AS num_items
FROM orders
GROUP BY order_id
ORDER BY num_items DESC;

-- Orders with more than 12 items
SELECT COUNT(*) AS order_count
FROM (
    SELECT order_id
    FROM orders
    GROUP BY order_id
    HAVING COUNT(item_id) > 12
) AS subquery;

-- Join menu_items and orders
SELECT o.order_details_id, m.item_name, m.category, m.price, o.order_id, o.order_date, o.order_time
FROM orders o
INNER JOIN menu_items m ON o.item_id = m.menu_item_id
ORDER BY o.order_details_id;

-- Least and most ordered items
SELECT m.category, m.item_name, COUNT(o.order_id) AS order_count
FROM orders o
INNER JOIN menu_items m ON o.item_id = m.menu_item_id
GROUP BY m.category, m.item_name
ORDER BY order_count ASC LIMIT 1;

SELECT m.category, m.item_name, COUNT(o.order_id) AS order_count
FROM orders o
INNER JOIN menu_items m ON o.item_id = m.menu_item_id
GROUP BY m.category, m.item_name
ORDER BY order_count DESC LIMIT 1;

-- Top 5 highest spend orders
SELECT o.order_id, SUM(m.price) AS total_spent
FROM orders o
INNER JOIN menu_items m ON o.item_id = m.menu_item_id
GROUP BY o.order_id
ORDER BY total_spent DESC
LIMIT 5;

-- Details of highest spend order
SELECT o.order_id, m.item_name, m.category, o.order_date, o.order_time, SUM(m.price) AS total_spent
FROM orders o
INNER JOIN menu_items m ON o.item_id = m.menu_item_id
WHERE o.order_id = (
    SELECT order_id
    FROM orders o2
    INNER JOIN menu_items m2 ON o2.item_id = m2.menu_item_id
    GROUP BY order_id
    ORDER BY SUM(m2.price) DESC
    LIMIT 1
)
GROUP BY o.order_id, m.item_name, m.category, o.order_date, o.order_time
ORDER BY total_spent DESC;
