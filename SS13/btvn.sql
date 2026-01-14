create database ss13;
use ss13;


CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATE,
    follower_count INT DEFAULT 0,
    post_count INT DEFAULT 0
);

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content TEXT,
    created_at DATETIME,
    like_count INT DEFAULT 0,
    CONSTRAINT fk_posts_users 
        FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE
);

-- ==========================================
-- 2. TẠO CÁC TRIGGER CẬP NHẬT TỰ ĐỘNG
-- ==========================================

-- Trigger tăng post_count khi thêm bài mới
DELIMITER //
CREATE TRIGGER after_post_insert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    UPDATE users 
    SET post_count = post_count + 1 
    WHERE user_id = NEW.user_id;
END;
//

-- Trigger giảm post_count khi xóa bài
CREATE TRIGGER after_post_delete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    UPDATE users 
    SET post_count = post_count - 1 
    WHERE user_id = OLD.user_id;
END;
//
DELIMITER ;



INSERT INTO users (username, email, created_at) VALUES
('alice', 'alice@example.com', '2025-01-01'),
('bob', 'bob@example.com', '2025-01-02'),
('charlie', 'charlie@example.com', '2025-01-03');



INSERT INTO posts (user_id, content, created_at) VALUES
(1, 'Hello world from Alice!', '2025-01-10 10:00:00'),
(1, 'Second post by Alice', '2025-01-10 12:00:00'),
(2, 'Bob first post', '2025-01-11 09:00:00'),
(3, 'Charlie sharing thoughts', '2025-01-12 15:00:00');

SELECT 'Kiem tra sau khi Insert' AS Message;
SELECT * FROM users;


DELETE FROM posts WHERE post_id = 2;

SELECT 'Kiem tra sau khi Delete post_id = 2' AS Message;
SELECT * FROM users; 
-- bai 2
CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    post_id INT,
    liked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

DELIMITER //

-- Trigger tăng like_count khi có lượt thích mới
CREATE TRIGGER after_like_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts 
    SET like_count = like_count + 1 
    WHERE post_id = NEW.post_id;
END;
//

-- Trigger giảm like_count khi xóa lượt thích
CREATE TRIGGER after_like_delete
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts 
    SET like_count = like_count - 1 
    WHERE post_id = OLD.post_id;
END;
//

DELIMITER ;

CREATE OR REPLACE VIEW user_statistics AS
SELECT 
    u.user_id, 
    u.username, 
    u.post_count, 
    SUM(IFNULL(p.like_count, 0)) AS total_likes
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username, u.post_count;


INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');

SELECT * FROM user_statistics;


INSERT INTO likes (user_id, post_id, liked_at) VALUES (2, 4, NOW());

SELECT * FROM posts WHERE post_id = 4;

SELECT * FROM user_statistics;

DELETE FROM likes WHERE user_id = 2 AND post_id = 4;

SELECT * FROM user_statistics;

-- Bài 3
DELIMITER //

CREATE TRIGGER trg_likes_before_insert
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
    DECLARE post_owner INT;

    SELECT user_id INTO post_owner
    FROM posts
    WHERE post_id = NEW.post_id;

    IF NEW.user_id = post_owner THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không được like bài đăng của chính mình';
    END IF;
END;
//
DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_likes_after_insert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
END;
//
DELIMITER ;


DELIMITER //

CREATE TRIGGER trg_likes_after_delete
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count - 1
    WHERE post_id = OLD.post_id;
END;
//
DELIMITER ;




-- Câu 4
CREATE TABLE post_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME,
    changed_by_user_id INT,
    CONSTRAINT fk_post_history_post
        FOREIGN KEY (post_id)
        REFERENCES posts(post_id)
        ON DELETE CASCADE
);

INSERT INTO posts (post_id, user_id, content, like_count)
VALUES
(10, 1, 'Nội dung ban đầu của bài 10', 0),
(11, 2, 'Nội dung ban đầu của bài 11', 0);

UPDATE posts
SET content = 'Nội dung đã chỉnh sửa lần 1'
WHERE post_id = 10;

UPDATE posts
SET content = 'Nội dung đã chỉnh sửa lần 2'
WHERE post_id = 10;

DELIMITER //

CREATE TRIGGER trg_posts_before_update
BEFORE UPDATE ON posts
FOR EACH ROW
BEGIN
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_history (
            post_id,
            old_content,
            new_content,
            changed_at,
            changed_by_user_id
        )
        VALUES (
            OLD.post_id,
            OLD.content,
            NEW.content,
            NOW(),
            OLD.user_id
        );
    END IF;
END;
//
DELIMITER ;

SELECT
    history_id,
    post_id,
    old_content,
    new_content,
    changed_at,
    changed_by_user_id
FROM post_history
WHERE post_id = 10
ORDER BY changed_at;

SELECT post_id, content, like_count
FROM posts
WHERE post_id = 10;

-- bai 5

DELIMITER $$

CREATE PROCEDURE add_user(
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_created_at DATETIME
)
BEGIN
    INSERT INTO users(username, email, created_at)
    VALUES (p_username, p_email, p_created_at);
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER before_users_insert
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    -- Kiểm tra email
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email khong hop le';
    END IF;

    -- Kiểm tra username (chỉ chữ, số, _)
    IF NEW.username NOT REGEXP '^[a-zA-Z0-9_]+$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username chi duoc chua chu, so va dau gach duoi';
    END IF;
END$$

DELIMITER ;


CALL add_user(
   'nam_dev','nam@gmail.com', NOW() );

CALL add_user(
     'nam123', 'namgmail.com',   NOW());

-- Bài 6
CREATE TABLE friendships (
    follower_id INT,
    followee_id INT,
    status ENUM('pending', 'accepted') DEFAULT 'accepted',

    PRIMARY KEY (follower_id, followee_id),

    CONSTRAINT fk_follower
        FOREIGN KEY (follower_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_followee
        FOREIGN KEY (followee_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);


DELIMITER $$

CREATE TRIGGER trg_friendships_after_insert
AFTER INSERT ON friendships
FOR EACH ROW
BEGIN
    IF NEW.status = 'accepted' THEN
        UPDATE users
        SET follower_count = follower_count + 1
        WHERE user_id = NEW.followee_id;
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_friendships_after_delete
AFTER DELETE ON friendships
FOR EACH ROW
BEGIN
    IF OLD.status = 'accepted' THEN
        UPDATE users
        SET follower_count = follower_count - 1
        WHERE user_id = OLD.followee_id;
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE follow_user(
    IN p_follower_id INT,
    IN p_followee_id INT,
    IN p_status ENUM('pending','accepted')
)
BEGIN
    -- Không cho tự follow
    IF p_follower_id = p_followee_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong the tu follow chinh minh';
    END IF;

    -- Kiểm tra trùng
    IF EXISTS (
        SELECT 1
        FROM friendships
        WHERE follower_id = p_follower_id
          AND followee_id = p_followee_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Da ton tai quan he follow';
    END IF;

    -- Thêm follow
    INSERT INTO friendships(follower_id, followee_id, status)
    VALUES (p_follower_id, p_followee_id, p_status);
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE unfollow_user(
    IN p_follower_id INT,
    IN p_followee_id INT
)
BEGIN
    DELETE FROM friendships
    WHERE follower_id = p_follower_id
      AND followee_id = p_followee_id;
END$$

DELIMITER ;


CREATE VIEW user_profile AS
SELECT 
    u.user_id,
    u.username,
    u.follower_count,

    COUNT(DISTINCT p.post_id) AS post_count,

    COUNT(l.like_id) AS total_likes

FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN likes l ON p.post_id = l.post_id

GROUP BY u.user_id, u.username, u.follower_count;


SELECT 
    p.post_id,
    p.content,
    p.created_at
FROM posts p
WHERE p.user_id = 1
ORDER BY p.created_at DESC
LIMIT 5;


CALL follow_user(1, 2, 'accepted');
CALL follow_user(3, 2, 'accepted');


SELECT * FROM users;
SELECT * FROM friendships;
SELECT * FROM user_profile;


