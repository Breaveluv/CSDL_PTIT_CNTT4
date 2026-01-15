
CREATE DATABASE social_network;
USE social_network;


CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    posts_count INT DEFAULT 0
);


CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_posts_users
        FOREIGN KEY (user_id) REFERENCES users(user_id)
);


INSERT INTO users (username) VALUES
('alice'),
('bob');


START TRANSACTION;

INSERT INTO posts (user_id, content)
VALUES (1, 'Bài viết đầu tiên của Alice');

UPDATE users
SET posts_count = posts_count + 1
WHERE user_id = 1;

COMMIT;

SELECT * FROM posts;
SELECT * FROM users;

-- ================================
-- 6. TRƯỜNG HỢP 2: TRANSACTION GÂY LỖI (ROLLBACK)
-- ================================
START TRANSACTION;

-- Lỗi cố ý: user_id không tồn tại (vi phạm khóa ngoại)
INSERT INTO posts (user_id, content)
VALUES (999, 'Bài viết lỗi');

UPDATE users
SET posts_count = posts_count + 1
WHERE user_id = 999;

ROLLBACK;


SELECT * FROM posts;
SELECT * FROM users;


-- Bài 2

   

ALTER TABLE posts
ADD COLUMN likes_count INT DEFAULT 0;

CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    CONSTRAINT fk_likes_posts
        FOREIGN KEY (post_id) REFERENCES posts(post_id),
    CONSTRAINT fk_likes_users
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT unique_like UNIQUE (post_id, user_id)
);

START TRANSACTION;

INSERT INTO likes (post_id, user_id)
VALUES (1, 2);

UPDATE posts
SET likes_count = likes_count + 1
WHERE post_id = 1;

COMMIT;

START TRANSACTION;

INSERT INTO likes (post_id, user_id)
VALUES (1, 2);

UPDATE posts
SET likes_count = likes_count + 1
WHERE post_id = 1;

ROLLBACK;


-- Bài 3


ALTER TABLE users
ADD COLUMN following_count INT DEFAULT 0,
ADD COLUMN followers_count INT DEFAULT 0;

CREATE TABLE  followers (
    follower_id INT NOT NULL,
    followed_id INT NOT NULL,
    PRIMARY KEY (follower_id, followed_id),
    CONSTRAINT fk_followers_follower
        FOREIGN KEY (follower_id) REFERENCES users(user_id),
    CONSTRAINT fk_followers_followed
        FOREIGN KEY (followed_id) REFERENCES users(user_id)
);

DELIMITER //

CREATE PROCEDURE sp_follow_user(
    IN p_follower_id INT,
    IN p_followed_id INT
)
proc: BEGIN
    DECLARE v_count INT DEFAULT 0;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count
    FROM users
    WHERE user_id IN (p_follower_id, p_followed_id);

    IF v_count < 2 THEN
        ROLLBACK;
        LEAVE proc;
    END IF;

    IF p_follower_id = p_followed_id THEN
        ROLLBACK;
        LEAVE proc;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM followers
    WHERE follower_id = p_follower_id
      AND followed_id = p_followed_id;

    IF v_count > 0 THEN
        ROLLBACK;
        LEAVE proc;
    END IF;

    INSERT INTO followers (follower_id, followed_id)
    VALUES (p_follower_id, p_followed_id);

    UPDATE users
    SET following_count = following_count + 1
    WHERE user_id = p_follower_id;

    UPDATE users
    SET followers_count = followers_count + 1
    WHERE user_id = p_followed_id;

    COMMIT;
END //

DELIMITER ;

CALL sp_follow_user(1, 2);
CALL sp_follow_user(1, 2);
CALL sp_follow_user(1, 1);
CALL sp_follow_user(1, 999);


-- Bài 4


ALTER TABLE posts
ADD COLUMN comments_count INT DEFAULT 0;

CREATE TABLE  comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_posts
        FOREIGN KEY (post_id) REFERENCES posts(post_id),
    CONSTRAINT fk_comments_users
        FOREIGN KEY (user_id) REFERENCES users(user_id)
);

DELIMITER //

CREATE PROCEDURE sp_post_comment(
    IN p_post_id INT,
    IN p_user_id INT,
    IN p_content TEXT
)
proc: BEGIN
    START TRANSACTION;

    INSERT INTO comments (post_id, user_id, content)
    VALUES (p_post_id, p_user_id, p_content);

    SAVEPOINT after_insert;

    -- gây lỗi cố ý khi test
    IF p_post_id = -1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Force error at UPDATE';
    END IF;

    UPDATE posts
    SET comments_count = comments_count + 1
    WHERE post_id = p_post_id;

    COMMIT;
END//

DELIMITER ;

-- test thành công
CALL sp_post_comment(1, 1, 'Bình luận hợp lệ');

-- test gây lỗi ở bước UPDATE (rollback partial)
CALL sp_post_comment(-1, 1, 'Bình luận gây lỗi');




-- Bài 5


CREATE TABLE  delete_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    deleted_by INT NOT NULL,
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE sp_delete_post(
    IN p_post_id INT,
    IN p_user_id INT
)
proc: BEGIN
    DECLARE v_owner_id INT;

    START TRANSACTION;

    -- kiểm tra bài viết tồn tại và đúng chủ
    SELECT user_id INTO v_owner_id
    FROM posts
    WHERE post_id = p_post_id;

    IF v_owner_id IS NULL OR v_owner_id <> p_user_id THEN
        ROLLBACK;
        LEAVE proc;
    END IF;

    -- xóa likes
    DELETE FROM likes
    WHERE post_id = p_post_id;

    -- xóa comments
    DELETE FROM comments
    WHERE post_id = p_post_id;

    -- xóa post
    DELETE FROM posts
    WHERE post_id = p_post_id;

    -- giảm posts_count
    UPDATE users
    SET posts_count = posts_count - 1
    WHERE user_id = p_user_id;

    -- ghi log
    INSERT INTO delete_log (post_id, deleted_by)
    VALUES (p_post_id, p_user_id);

    COMMIT;
END//

DELIMITER ;

-- test hợp lệ (đúng chủ bài viết)
CALL sp_delete_post(1, 1);

-- test không hợp lệ (không phải chủ bài viết)
CALL sp_delete_post(2, 1);

-- Bài 6


ALTER TABLE users
ADD COLUMN friends_count INT DEFAULT 0;

CREATE TABLE  friend_requests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    status ENUM('pending','accepted','rejected') DEFAULT 'pending',
    CONSTRAINT fk_fr_from
        FOREIGN KEY (from_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_fr_to
        FOREIGN KEY (to_user_id) REFERENCES users(user_id)
);

CREATE TABLE  friends (
    user_id INT NOT NULL,
    friend_id INT NOT NULL,
    PRIMARY KEY (user_id, friend_id),
    CONSTRAINT fk_friends_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_friends_friend
        FOREIGN KEY (friend_id) REFERENCES users(user_id)
);

DELIMITER $$

CREATE PROCEDURE sp_accept_friend_request(
    IN p_request_id INT,
    IN p_to_user_id INT
)
proc: BEGIN
    DECLARE v_from_user_id INT;
    DECLARE v_status VARCHAR(10);

    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION;

    -- lấy thông tin request
    SELECT from_user_id, status
    INTO v_from_user_id, v_status
    FROM friend_requests
    WHERE request_id = p_request_id
      AND to_user_id = p_to_user_id
    FOR UPDATE;

    IF v_from_user_id IS NULL OR v_status <> 'pending' THEN
        ROLLBACK;
        LEAVE proc;
    END IF;

    -- kiểm tra đã là bạn chưa
    IF EXISTS (
        SELECT 1 FROM friends
        WHERE user_id = v_from_user_id
          AND friend_id = p_to_user_id
    ) THEN
        ROLLBACK;
        LEAVE proc;
    END IF;

    -- thêm bạn 2 chiều
    INSERT INTO friends (user_id, friend_id)
    VALUES (v_from_user_id, p_to_user_id),
           (p_to_user_id, v_from_user_id);

    -- cập nhật số lượng bạn
    UPDATE users
    SET friends_count = friends_count + 1
    WHERE user_id IN (v_from_user_id, p_to_user_id);

    -- cập nhật trạng thái request
    UPDATE friend_requests
    SET status = 'accepted'
    WHERE request_id = p_request_id;

    COMMIT;
END$$

DELIMITER ;

-- dữ liệu test
INSERT INTO friend_requests (from_user_id, to_user_id)
VALUES (1, 2);

-- chấp nhận hợp lệ
CALL sp_accept_friend_request(1, 2);

-- gọi lại lần nữa (sẽ rollback)
CALL sp_accept_friend_request(1, 2);
