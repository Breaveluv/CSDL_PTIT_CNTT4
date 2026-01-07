--Ex1
CREATE DATABASE ss7_bt;
USE ss7_bt;

CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);
INSERT INTO customers (id, name, email) VALUES
(1, 'Nguyen Van A', 'vanta@gmail.com'),
(2, 'Tran Thi B', 'thib@gmail.com'),
(3, 'Le Van C', 'vanc@gmail.com'),
(4, 'Pham Thi D', 'thid@gmail.com'),
(5, 'Hoang Van E', 'vane@gmail.com'),
(6, 'Doan Thi F', 'thif@gmail.com'),
(7, 'Vu Van G', 'vang@gmail.com');


INSERT INTO orders (id, customer_id, order_date, total_amount) VALUES
(101, 1, '2023-10-01', 500000),
(102, 1, '2023-10-05', 250000),
(103, 2, '2023-10-10', 1200000),
(104, 3, '2023-11-12', 300000),
(105, 4, '2023-11-15', 750000),
(106, 2, '2023-12-01', 450000),
(107, 3, '2023-12-05', 100000);

SELECT * FROM customers 
WHERE id IN (SELECT DISTINCT customer_id FROM orders);

--Ex2
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT DEFAULT 1,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
INSERT INTO products (id, name, price) VALUES
(1, 'iPhone 15 Pro', 28000000),
(2, 'MacBook Air M2', 24000000),
(3, 'AirPods Pro 2', 5500000),
(4, 'iPad Pro M4', 30000000),
(5, 'Samsung S24 Ultra', 26000000),
(6, 'Sony WH-1000XM5', 8000000),
(7, 'Logitech MX Master 3S', 2500000);

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(101, 1, 1),
(101, 3, 2),
(102, 2, 1),
(103, 5, 1),
(104, 1, 1),
(105, 3, 1),
(106, 2, 2);

SELECT * FROM products 
WHERE id IN (SELECT product_id FROM order_items);

--Ex3

INSERT INTO orders (id, customer_id, order_date, total_amount) VALUES
(108, 5, '2024-01-10', 1500000),
(109, 6, '2024-01-12', 200000),
(110, 7, '2024-01-15', 3500000),
(111, 1, '2024-01-20', 100000),
(112, 3, '2024-01-22', 800000);

SELECT * FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders);

--Ex4


INSERT INTO customers (id, name, email) VALUES
(8, 'Hoang Le', 'hoangle@example.com'),
(9, 'Mai Chi', 'maichi@example.com'),
(10, 'Tuan Tu', 'tuantu@example.com'),
(11, 'Thu Thao', 'thuthao@example.com'),
(12, 'Minh Khoa', 'minhkhoa@example.com');


INSERT INTO orders (id, customer_id, order_date, total_amount) VALUES
(113, 8, '2024-02-01', 1200000),
(114, 8, '2024-02-05', 450000),
(115, 9, '2024-02-10', 3000000),
(116, 11, '2024-02-15', 150000),
(117, 8, '2024-02-20', 890000);

SELECT 
    name AS customer_name,
    (SELECT COUNT(*) 
     FROM orders 
     WHERE orders.customer_id = customers.id) AS order_count
FROM customers;

--Ex5
INSERT INTO customers (id, name, email) VALUES
(20, 'Hoàng Long', 'long@gmail.com'),
(21, 'Minh Tú', 'tu@gmail.com'),
(22, 'Lan Anh', 'lananh@gmail.com'),
(23, 'Quốc Bảo', 'bao@gmail.com'),
(24, 'Diệu Nhi', 'nhi@gmail.com');

INSERT INTO orders (id, customer_id, order_date, total_amount) VALUES
(301, 20, '2024-03-01', 5000000), 
(302, 21, '2024-03-02', 2000000), 
(303, 20, '2024-03-03', 1500000), 
(304, 22, '2024-03-04', 3000000), 
(305, 23, '2024-03-05', 1000000); 

SELECT name 
FROM customers 
WHERE (SELECT SUM(total_amount) FROM orders WHERE orders.customer_id = customers.id) = (
   
    SELECT MAX(total_per_customer) 
    FROM (
       
        SELECT SUM(total_amount) AS total_per_customer 
        FROM orders 
        GROUP BY customer_id
    ) AS sub_table
);

--Ex6
SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > (
    
    SELECT AVG(sum_total) 
    FROM (
        SELECT SUM(total_amount) AS sum_total 
        FROM orders 
        GROUP BY customer_id
    ) AS average_table
);