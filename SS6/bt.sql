CREATE DATABASE EcommerceDB;
USE EcommerceDB;

-- EX1
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    city VARCHAR(255)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status ENUM('pending', 'completed', 'cancelled'),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers (customer_id, full_name, city) VALUES
(1, 'Nguyễn Văn A', 'Hà Nội'),
(2, 'Trần Thị B', 'TP. Hồ Chí Minh'),
(3, 'Lê Văn C', 'Đà Nẵng'),
(4, 'Phạm Minh D', 'Cần Thơ'),
(5, 'Hoàng Anh E', 'Hải Phòng');

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(101, 1, '2025-01-01', 'completed'),
(102, 1, '2025-01-02', 'pending'),
(103, 2, '2025-01-03', 'completed'),
(104, 3, '2025-01-04', 'cancelled'),
(105, 5, '2025-01-05', 'completed'),
(106, 2, '2025-01-06', 'pending');


SELECT 
    o.order_id, 
    c.full_name, 
    o.order_date, 
    o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;


SELECT 
    c.full_name, 
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;


SELECT DISTINCT 
    c.customer_id, 
    c.full_name, 
    c.city
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;


-- Ex2

ALTER TABLE orders 
ADD COLUMN total_amount DECIMAL(10,2);

UPDATE orders SET total_amount = 150.00 WHERE order_id = 101;
UPDATE orders SET total_amount = 200.50 WHERE order_id = 102;
UPDATE orders SET total_amount = 500.00 WHERE order_id = 103;
UPDATE orders SET total_amount = 120.00 WHERE order_id = 104;
UPDATE orders SET total_amount = 350.75 WHERE order_id = 105;
UPDATE orders SET total_amount = 100.00 WHERE order_id = 106;

-- Truy vấn 1: Tổng tiền mỗi khách hàng đã chi tiêu
SELECT 
    c.full_name, 
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

-- Truy vấn 2: Giá trị đơn hàng cao nhất của từng khách
SELECT 
    c.full_name, 
    MAX(o.total_amount) AS highest_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name;

-- Truy vấn 3: Sắp xếp khách hàng theo tổng tiền giảm dần
SELECT 
    c.full_name, 
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC;
-- Ex3
SELECT 
    order_date AS 'Ngày',
    COUNT(order_id) AS 'Số lượng đơn hàng',
    SUM(total_amount) AS 'Tổng doanh thu'
FROM orders
WHERE status = 'completed' 
GROUP BY order_date
HAVING SUM(total_amount) > 10000000
ORDER BY order_date DESC;

-- Ex4







CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);



CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers (customer_id, full_name, city) VALUES
(1, 'Nguyễn Văn A', 'Hà Nội'),
(2, 'Trần Thị B', 'TP. Hồ Chí Minh'),
(3, 'Lê Văn C', 'Đà Nẵng'),
(4, 'Phạm Minh D', 'Cần Thơ'),
(5, 'Hoàng Anh E', 'Hải Phòng');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Laptop Dell XPS', 25000000.00),
(2, 'Chuột không dây', 500000.00),
(3, 'Bàn phím cơ', 1200000.00),
(4, 'Màn hình 24 inch', 4500000.00),
(5, 'Tai nghe Sony', 3500000.00);


INSERT INTO orders (order_id, customer_id, order_date, status, total_amount) VALUES
(101, 1, '2025-01-01', 'completed', 25000000.00),
(102, 1, '2025-01-02', 'pending', 1500000.00),
(103, 2, '2025-01-03', 'completed', 9000000.00),
(104, 3, '2025-01-04', 'cancelled', 1200000.00),
(105, 5, '2025-01-05', 'completed', 7000000.00);

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(101, 1, 1), 
(102, 2, 3), 
(103, 4, 2), 
(104, 3, 1), 
(105, 5, 2); 




SELECT 
    p.product_name, 
    SUM(oi.quantity) AS total_sold, 
    SUM(oi.quantity * p.price) AS product_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING product_revenue > 5000000
ORDER BY product_revenue DESC;

SELECT 
    c.full_name, 
    SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC;

-- Ex5
SELECT 
    order_date, 
    COUNT(order_id) AS total_orders, 
    SUM(total_amount) AS daily_revenue
FROM orders
WHERE status = 'completed'
GROUP BY order_date
HAVING SUM(total_amount) > 10000000;

-- Ex6

INSERT INTO orders (order_id, customer_id, order_date, status, total_amount) VALUES
(107, 1, '2025-01-07', 'completed', 50000000.00),
(108, 2, '2025-01-08', 'completed', 30000000.00),
(109, 3, '2025-01-09', 'completed', 40000000.00);

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(107, 1, 5), 
(107, 2, 10), 
(108, 4, 8),  
(108, 5, 12), 
(109, 3, 15), 
(109, 1, 3);  


SELECT 
    p.product_name AS 'Tên sản phẩm',
    SUM(oi.quantity) AS 'Tổng số lượng bán',
    SUM(oi.quantity * p.price) AS 'Tổng doanh thu',
    AVG(p.price) AS 'Giá bán trung bình'
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) >= 10
ORDER BY SUM(oi.quantity * p.price) DESC
LIMIT 5;


