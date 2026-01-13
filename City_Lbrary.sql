CREATE DATABASE city_library;
USE city_library;

-- user
CREATE TABLE user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL
);

-- address
CREATE TABLE address (
    address_id INT UNIQUE PRIMARY KEY,
    street VARCHAR(255) NOT NULL
);


-- status
CREATE TABLE status (
    status_id INT PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

-- item
CREATE TABLE item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100),
    ISBN VARCHAR(20) UNIQUE,
    published_year INT,
    status_id INT NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES address(address_id),
    FOREIGN KEY (status_id) REFERENCES status(status_id)
);

-- cart
CREATE TABLE cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- cart item
CREATE TABLE cart_item (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item(item_id),
    UNIQUE KEY uq_cart_item (cart_id, item_id)
);

-- ordering
CREATE TABLE ordering (
    ordering_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    status_id INT NOT NULL,
    ordering_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id),
    FOREIGN KEY (status_id) REFERENCES status(status_id)
);

-- transport
CREATE TABLE transport (
    transport_id INT AUTO_INCREMENT PRIMARY KEY,
    ordering_id INT NOT NULL UNIQUE,
    address_id INT NOT NULL,
    FOREIGN KEY (ordering_id) REFERENCES ordering(ordering_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

-- dummy data
-- 10 dummy users
INSERT INTO user (name, email, password)
VAlUES
('Alice Akem','alice@example.com', 'pass1123'),
('Bob Bubbley','bob@example.com', 'pass1122'),
('Cindy Criket','cin@example.com', 'pass1111'),
('Duce Dogmatic','duce@example.com', 'pass2222'),
('Eve Evans','eve@example.com', 'pass3333'),
('Fifi Faraway','fifi@example.com', 'pass4444'),
('Gale Giving','gale@example.com', 'pass5555'),
('Hen Holloway','hen@example.com', 'pass6666'),
('Ike Irving','ike@example.com', 'pass7777'),
('Jacks Joyfull','jacks@example.com', 'pass8888');

INSERT INTO address (address_id, street)
VALUES
(1, '123 Main St, Cityville'),
(2, '456 Oak Ave, Townsville'),
(3, '789 Pine Rd, Villagetown');

INSERT INTO status (status_id, description)
VALUES
(1, '予約可能'),
(2, '貸出中'),
(3, '予約済み'),
(4, '修理中'),
(5, '運搬中');

-- 8 dummy items
INSERT INTO item (owner_id, title, author, ISBN, published_year, status_id)
VALUES
(1, 'The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 1925, 1),
(3, 'The Great Gatsby', 'F. Scott Fitzgerald', '9780745673565', 2002, 1),
(2, 'To Kill a Mockingbird', 'Harper Lee', '9780061120084', 1960, 2),
(3, '1984', 'George Orwell', '9780451524935', 1949, 1),
(3, 'Pride and Prejudice', 'Jane Austen', '9781503290563', 1813, 3),
(3, 'The Catcher in the Rye', 'J.D. Salinger', '9780316769488', 1951, 1),
(2, 'The Hobbit', 'J.R.R. Tolkien', '9780547928227', 1937, 4),
(1, 'Fahrenheit 451', 'Ray Bradbury', '9781451673319', 1953, 1);


INSERT INTO cart (user_id)
VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

INSERT INTO cart_item (cart_id, item_id, quantity)
VALUES
(1, 1, 1),
(1, 2, 1),
(2, 3, 1),
(3, 4, 1),
(4, 5, 1),
(5, 6, 1),
(6, 7, 1),
(7, 3, 1),
(8, 2, 1),
(9, 7, 1)
ON DUPLICATE KEY UPDATE quantity = quantity + 1;

-- 8 dummy orders
-- cart_idとuser_idが4のデータはorderingデータに除外されている（＝user4はorderしなかった）
INSERT INTO ordering (cart_id, status_id)
VALUES
(1, 3),
(2, 1),
(3, 4),
(5, 5),
(6, 3),
(7, 1),
(8, 1),
(9, 1);

INSERT INTO transport (ordering_id, address_id)
VALUES
(1, 1),
(2, 3),
(3, 3),
(4, 3),
(5, 1),
(6, 3),
(7, 2),
(8, 1);

-- example queries
-- 1. 全利用者の予約数を降順で確認する
WITH accepted_orders AS (
    SELECT ci.cart_id, SUM(ci.quantity) AS total_quantity
    FROM cart_item AS ci
    JOIN ordering AS o ON ci.cart_id = o.cart_id
    GROUP BY ci.cart_id
),
ranked AS (
    SELECT * FROM accepted_orders
    WHERE total_quantity > 1
    ORDER BY total_quantity DESC
)
SELECT * FROM ranked;

-- 2.ある館が現在所蔵している本を確認する
SELECT * FROM item
WHERE owner_id = 1;

-- 3. 予約を受けてitemのステータスを「貸出中」に更新する
-- 結果：これまでダミーデータに追加で編集していなければ、'1984', 'Pride and Prejudice', 'Fahrenheit 451'のステータスが1から3に更新される
UPDATE item AS i
JOIN cart_item AS cim ON i.item_id = cim.item_id
JOIN ordering AS o ON cim.cart_id = o.cart_id
SET i.status_id = 3
WHERE o.status_id = 1
AND i.status_id = 1;


