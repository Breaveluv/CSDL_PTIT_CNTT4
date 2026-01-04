--Ex1
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10,2),
    stock INT,
    status ENUM('active', 'inactive')
);

INSERT INTO products VALUES
(1, 'Sản phẩm A', 500000, 10, 'active'),
(2, 'Sản phẩm B', 1500000, 5, 'active'),
(3, 'Sản phẩm C', 200000, 20, 'inactive'),
(4, 'Sản phẩm D', 2500000, 2, 'active');

SELECT * FROM products;

SELECT * FROM products WHERE status = 'active';

SELECT * FROM products WHERE price > 1000000;

SELECT * FROM products WHERE status = 'active' ORDER BY price ASC;

-- EX2
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255),
    city VARCHAR(255),
    status ENUM('active', 'inactive')
);

-- Thêm dữ liệu mẫu cho customers
INSERT INTO customers VALUES
(1, 'Nguyễn Văn A', 'a@example.com', 'TP.HCM', 'active'),
(2, 'Trần Thị B', 'b@example.com', 'Hà Nội', 'active'),
(3, 'Lê Văn C', 'c@example.com', 'TP.HCM', 'inactive'),
(4, 'Phạm Thị D', 'd@example.com', 'Hà Nội', 'active');

-- Các truy vấn cho customers
-- 1. Lấy danh sách tất cả khách hàng
SELECT * FROM customers;

-- 2. Lấy khách hàng ở TP.HCM
SELECT * FROM customers WHERE city = 'TP.HCM';

-- 3. Lấy khách hàng đang hoạt động và ở Hà Nội
SELECT * FROM customers WHERE status = 'active' AND city = 'Hà Nội';

-- 4. Sắp xếp danh sách khách hàng theo tên (A → Z)
SELECT * FROM customers ORDER BY full_name ASC;

--EX3

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    status ENUM('active', 'inactive') DEFAULT 'active'
);

-- Tạo bảng orders (Đơn hàng)
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    order_date DATE NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending'
);

-
INSERT INTO Product (product_name, price, stock, status) VALUES
('iPhone 15 Pro', 28000000, 10, 'active'),
('Samsung Galaxy S23', 19000000, 5, 'active'),
('Laptop Dell XPS', 35000000, 3, 'active'),
('Chuột Logitech', 500000, 50, 'active'),
('Bàn phím cơ', 1200000, 20, 'active'),
('Tai nghe cũ', 300000, 0, 'inactive');


INSERT INTO orders (customer_id, total_amount, order_date, status) VALUES
(1, 28000000, '2024-01-01', 'completed'),
(2, 500000, '2024-01-02', 'completed'),
(3, 15000000, '2024-01-03', 'pending'),
(1, 1200000, '2024-01-04', 'cancelled'),
(4, 35000000, '2024-01-05', 'completed'),
(2, 8000000, '2024-01-06', 'completed'),
(5, 1000000, '2024-01-07', 'completed');



SELECT * FROM Product;


SELECT * FROM Product WHERE status = 'active';


SELECT * FROM Product WHERE price > 1000000;


SELECT * FROM Product 
WHERE status = 'active' 
ORDER BY price ASC;




SELECT * FROM orders WHERE status = 'completed';


SELECT * FROM orders WHERE total_amount > 5000000;


SELECT * FROM orders 
ORDER BY order_date DESC 
LIMIT 5;


SELECT * FROM orders 
WHERE status = 'completed' 
ORDER BY total_amount DESC;


--EX4

-- Thêm cột sold_quantity vào bảng products
ALTER TABLE products ADD COLUMN sold_quantity INT DEFAULT 0;

-- Cập nhật số lượng đã bán cho các sản phẩm
UPDATE products SET sold_quantity = 100 WHERE product_id = 1;
UPDATE products SET sold_quantity = 50 WHERE product_id = 2;
UPDATE products SET sold_quantity = 200 WHERE product_id = 3;
UPDATE products SET sold_quantity = 30 WHERE product_id = 4;

-- 1. Lấy 10 sản phẩm bán chạy nhất
SELECT * FROM products ORDER BY sold_quantity DESC LIMIT 10;

-- 2. Lấy 5 sản phẩm bán chạy tiếp theo (bỏ qua 10 sản phẩm đầu)
SELECT * FROM products ORDER BY sold_quantity DESC LIMIT 5 OFFSET 10;

-- 3. Hiển thị danh sách sản phẩm giá < 2.000.000, sắp xếp theo số lượng bán giảm dần
SELECT * FROM products WHERE price < 2000000 ORDER BY sold_quantity DESC;

--EX5

-- Trang 1: hiển thị 5 đơn hàng mới nhất (chưa bị hủy)
SELECT * FROM orders 
WHERE status != 'cancelled' 
ORDER BY order_date DESC 
LIMIT 5 OFFSET 0;

-- Trang 2: hiển thị 5 đơn hàng tiếp theo (chưa bị hủy)
SELECT * FROM orders 
WHERE status != 'cancelled' 
ORDER BY order_date DESC 
LIMIT 5 OFFSET 5;

-- Trang 3: hiển thị 5 đơn hàng tiếp theo (chưa bị hủy)
SELECT * FROM orders 
WHERE status != 'cancelled' 
ORDER BY order_date DESC 
LIMIT 5 OFFSET 10;

--EX6

-- Tìm sản phẩm: status = 'active', price từ 1.000.000 đến 3.000.000, sắp xếp theo giá tăng dần, 10 sản phẩm mỗi trang

-- Trang 1
SELECT * FROM products 
WHERE status = 'active' AND price BETWEEN 1000000 AND 3000000 
ORDER BY price ASC 
LIMIT 10 OFFSET 0;

-- Trang 2
SELECT * FROM products 
WHERE status = 'active' AND price BETWEEN 1000000 AND 3000000 
ORDER BY price ASC 
LIMIT 10 OFFSET 10;
