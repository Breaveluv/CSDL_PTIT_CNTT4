create database btth_02;
use btth_02;

create table categories (
    category_id int primary key auto_increment,
    category_name varchar(255) not null unique
);

create table customers (
    customer_id int primary key auto_increment,
    customer_name varchar(100) not null,
    email varchar(100) not null unique,
    phone varchar(10) not null unique
);

create table products (
    product_id int primary key auto_increment,
    product_name varchar(255) not null unique,
    price decimal(10,2) not null,
    category_id int not null,
    constraint chk_product_price check (price > 0),
    constraint fk_product_category foreign key (category_id) references categories(category_id)
);

create table orders (
    order_id int primary key auto_increment,
    customer_id int not null,
    order_date datetime default current_timestamp,
    status enum('pending', 'completed', 'cancel') default 'pending',
    constraint fk_order_customer foreign key (customer_id) references customers(customer_id)
);

create table order_items (
    order_item_id int primary key auto_increment,
    order_id int not null,
    product_id int not null,
    quantity int not null,
    constraint chk_item_quantity check (quantity > 0),
    constraint fk_item_order foreign key (order_id) references orders(order_id),
    constraint fk_item_product foreign key (product_id) references products(product_id)
);

insert into customers (customer_name, email, phone) values 
('phạm thành đạt', 'ptd@gmail.com', '0912345678'),
('trần việt anh', 'vat@gmail.com', '0987654321'),
('nguyễn tuyết mai', 'ntm@gmail.com', '0905123456'),
('lê hoàng long', 'lhl@gmail.com', '0934567890');

insert into categories (category_name) values 
('điện thoại'),
('laptop'),
('phụ kiện');

insert into products (product_name, price, category_id) values 
('iphone 15 pro max', 34000000.00, 1),
('samsung s24 ultra', 29500000.00, 1),
('macbook pro m3', 45000000.00, 2),
('dell xps 13', 32000000.00, 2),
('airpods pro 2', 5500000.00, 3),
('sạc anker 65w', 1200000.00, 3),
('chuột logitech mx', 2500000.00, 3);

insert into orders (customer_id, status) values 
(1, 'completed'),
(2, 'completed'),
(1, 'pending'),
(3, 'cancel'),
(2, 'completed');

insert into order_items (order_id, product_id, quantity) values 
(1, 1, 1),
(1, 5, 2),
(2, 3, 1),
(3, 2, 1),
(5, 6, 3),
(5, 7, 1);

-- Phần A
select * from categories;
select * from orders where status = 'completed';
select * from products order by price desc;
select * from products order by price desc limit 5 offset 2;

-- Phần B
select p.product_name, c.category_name, p.price from products p join categories c on p.category_id = c.category_id;
select o.order_id, o.order_date, cu.customer_name, o.status from orders o join customers cu on o.customer_id = cu.customer_id;
select order_id, sum(quantity) as total_quantity from order_items group by order_id;

select cu.customer_name, count(o.order_id) as total_orders from customers cu 
left join orders o on cu.customer_id = o.customer_id group by cu.customer_id;

select cu.customer_name, count(o.order_id) as total_orders from customers cu join orders o 
on cu.customer_id = o.customer_id group by cu.customer_id having total_orders >= 2;

select c.category_name, avg(p.price), min(p.price), max(p.price) from categories c join products p 
on c.category_id = p.category_id group by c.category_id;

-- Phần C
select product_name, price from products
where price > (
    select avg(price) from products
);

select * from customers 
where customer_id in (
    select distinct customer_id from orders
);

select order_id, SUM(quantity) as tong_so_luong
from order_items
group by order_id
having SUM(quantity) >= all (
    select SUM(quantity) 
    from order_items 
    group by order_id
);

select distinct c.customer_name
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
where p.category_id = (
    select category_id 
    from products 
    group by category_id 
    order by avg(price) desc 
    limit 1
);

select customer_name, sum(quantity) as tong_san_pham_da_mua
from (
    select c.customer_name, oi.quantity
    from customers c
    join orders o on c.customer_id = o.customer_id
    join order_items oi on o.order_id = oi.order_id
) as bang_tam
group by customer_name;

select product_name, price
from products
where price = (
    select max(price) from products
);