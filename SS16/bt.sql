


CREATE DATABASE quanlybanhang;
USE quanlybanhang;



CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    address VARCHAR(255),
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    category VARCHAR(50) NOT NULL
);

CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    revenue DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);



INSERT INTO Customers (customer_name, phone, address, email) VALUES
('Nguyen Van A','0901111111','Ha Noi','a@gmail.com'),
('Tran Van B','0902222222','Hai Phong','b@gmail.com'),
('Le Van C','0903333333','Da Nang','c@gmail.com'),
('Pham Van D','0904444444','Hue','d@gmail.com'),
('Hoang Van E','0905555555','TP HCM','e@gmail.com');

INSERT INTO Products (product_name, price, quantity, category) VALUES
('Laptop HP',1200,200,'Laptop'),
('Mouse Logitech',25,500,'Accessory'),
('Keyboard Dell',45,300,'Accessory'),
('Monitor Samsung',300,150,'Monitor'),
('Laptop Asus',1000,180,'Laptop');

INSERT INTO Employees (employee_name, position, salary) VALUES
('Nguyen An','Sales',800),
('Tran Binh','Sales',850),
('Le Cuong','Manager',1200),
('Pham Dung','Sales',780),
('Hoang Em','Sales',820);

INSERT INTO Orders (customer_id, employee_id) VALUES
(1,1),(2,2),(3,3),(1,2),(4,1);



DELIMITER $$

CREATE TRIGGER trigger_after_insert_order_details
BEFORE INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE stock INT;

    SELECT quantity INTO stock
    FROM Products
    WHERE product_id = NEW.product_id;

    IF stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số lượng sản phẩm trong kho không đủ';
    ELSE
        UPDATE Products
        SET quantity = quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END$$

DELIMITER ;



INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES
(1,1,2,1200),
(1,2,5,25),
(2,3,10,45),
(3,4,1,300),
(4,5,3,1000);



UPDATE Orders o
SET total_amount = (
    SELECT SUM(quantity * unit_price)
    FROM OrderDetails od
    WHERE od.order_id = o.order_id
);



-- 5.1
SELECT customer_id, customer_name, email, phone, address
FROM Customers;

-- 5.2
UPDATE Products
SET product_name = 'Laptop Dell XPS',
    price = 99.99
WHERE product_id = 1;

-- 5.3
SELECT o.order_id, c.customer_name, e.employee_name,
       o.total_amount, o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id;

-- 6.1
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 6.2
SELECT e.employee_id, e.employee_name,
       SUM(o.total_amount) AS revenue
FROM Employees e
JOIN Orders o ON e.employee_id = o.employee_id
WHERE YEAR(o.order_date) = YEAR(CURRENT_DATE)
GROUP BY e.employee_id, e.employee_name;

-- 6.3
SELECT p.product_id, p.product_name,
       SUM(od.quantity) AS total_quantity
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
JOIN Orders o ON od.order_id = o.order_id
WHERE MONTH(o.order_date) = MONTH(CURRENT_DATE)
  AND YEAR(o.order_date) = YEAR(CURRENT_DATE)
GROUP BY p.product_id, p.product_name
HAVING total_quantity > 100
ORDER BY total_quantity DESC;

-- 7.1
SELECT c.customer_id, c.customer_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 7.2
SELECT *
FROM Products
WHERE price > (SELECT AVG(price) FROM Products);

-- 7.3
SELECT c.customer_id, c.customer_name,
       SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING total_spent = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(total_amount) AS total
        FROM Orders
        GROUP BY customer_id
    ) t
);


CREATE VIEW view_order_list AS
SELECT o.order_id, c.customer_name, e.employee_name,
       o.total_amount, o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id
ORDER BY o.order_date DESC;

CREATE VIEW view_order_detail_product AS
SELECT od.order_detail_id, p.product_name,
       od.quantity, od.unit_price
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
ORDER BY od.quantity DESC;



DELIMITER $$

CREATE PROCEDURE proc_insert_employee(
    IN p_name VARCHAR(100),
    IN p_position VARCHAR(50),
    IN p_salary DECIMAL(10,2),
    OUT p_employee_id INT
)
BEGIN
    INSERT INTO Employees(employee_name, position, salary)
    VALUES (p_name, p_position, p_salary);

    SET p_employee_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE proc_get_orderdetails(IN p_order_id INT)
BEGIN
    SELECT *
    FROM OrderDetails
    WHERE order_id = p_order_id;
END$$

CREATE PROCEDURE proc_cal_total_amount_by_order(
    IN p_order_id INT,
    OUT total_products INT
)
BEGIN
    SELECT COUNT(DISTINCT product_id)
    INTO total_products
    FROM OrderDetails
    WHERE order_id = p_order_id;
END$$

CREATE PROCEDURE proc_insert_order_details(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_price DECIMAL(10,2)
)
BEGIN
    DECLARE v_exists INT;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_exists
    FROM Orders
    WHERE order_id = p_order_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'không tồn tại mã hóa đơn';
    END IF;

    INSERT INTO OrderDetails(order_id, product_id, quantity, unit_price)
    VALUES (p_order_id, p_product_id, p_quantity, p_price);

    UPDATE Orders
    SET total_amount = total_amount + (p_quantity * p_price)
    WHERE order_id = p_order_id;

    COMMIT;
END$$

DELIMITER ;
