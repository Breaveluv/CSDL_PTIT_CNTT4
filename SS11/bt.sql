-- Khởi tạo Database

USE social_network_pro;



DELIMITER //

CREATE PROCEDURE GetUserPosts(IN p_user_id INT)
BEGIN
    SELECT 
        post_id, 
        content, 
        created_at
    FROM posts
    WHERE user_id = p_user_id;
END //

DELIMITER ;

CALL GetUserPosts(1);

DROP PROCEDURE IF EXISTS GetUserPosts;

-- Bài 2

DELIMITER //

CREATE PROCEDURE CalculatePostLikes(
    IN p_post_id INT,
    OUT total_likes INT
)
BEGIN
    -- Đếm số lượt like của bài viết cụ thể dựa trên post_id
    SELECT COUNT(*) INTO total_likes
    FROM likes
    WHERE post_id = p_post_id;
END //

DELIMITER ;

-- 1. Gọi thủ tục và truyền kết quả vào biến @likes_count
CALL CalculatePostLikes(1, @likes_count);

-- 2. Truy vấn giá trị của biến để xem kết quả
SELECT @likes_count AS 'Tổng số lượt like của bài viết';

DROP PROCEDURE IF EXISTS CalculatePostLikes;

-- Bài 3
DELIMITER //

CREATE PROCEDURE CalculateBonusPoints(
    IN p_user_id INT,
    INOUT p_bonus_points INT
)
BEGIN
    DECLARE v_post_count INT DEFAULT 0;

    -- Đếm số lượng bài viết của user và gán vào biến tạm v_post_count
    SELECT COUNT(*) INTO v_post_count
    FROM posts
    WHERE user_id = p_user_id;

    -- Kiểm tra điều kiện để cộng điểm thưởng
    IF v_post_count >= 20 THEN
        SET p_bonus_points = p_bonus_points + 100;
    ELSEIF v_post_count >= 10 THEN
        SET p_bonus_points = p_bonus_points + 50;
    END IF;
    
    -- Tham số p_bonus_points (INOUT) tự động mang giá trị mới sau khi SET
END //

DELIMITER ;


-- Bước 3: Khởi tạo biến điểm thưởng ban đầu là 100
SET @current_bonus = 100;

-- Gọi procedure cho user_id = 1 (Ví dụ: Nguyễn Văn An)
CALL CalculateBonusPoints(1, @current_bonus);

-- Bước 4: Truy vấn giá trị điểm thưởng sau khi đã tính toán
SELECT 
    full_name AS 'Tên người dùng',
    @current_bonus AS 'Tổng điểm thưởng sau cập nhật'
FROM users 
WHERE user_id = 1;

DROP PROCEDURE IF EXISTS CalculateBonusPoints;

-- Bài 4
DELIMITER //

CREATE PROCEDURE CreatePostWithValidation(
    IN p_user_id INT,
    IN p_content TEXT,
    OUT result_message VARCHAR(255)
)
BEGIN
    -- Kiểm tra độ dài nội dung bài viết
    IF CHAR_LENGTH(p_content) < 5 THEN
        SET result_message = 'Thất bại: Nội dung quá ngắn (tối thiểu 5 ký tự).';
    ELSE
        -- Nếu hợp lệ thì tiến hành Insert
        INSERT INTO posts (user_id, content, created_at)
        VALUES (p_user_id, p_content, NOW());
        
        SET result_message = 'Thành công: Bài viết đã được đăng.';
    END IF;
END //

DELIMITER ;

-- Trường hợp 1: Nội dung quá ngắn (3 ký tự)
CALL CreatePostWithValidation(1, 'Hi!', @msg1);
SELECT @msg1 AS 'Kết quả Test 1';

-- Trường hợp 2: Nội dung hợp lệ
CALL CreatePostWithValidation(1, 'Học SQL thật là thú vị!', @msg2);
SELECT @msg2 AS 'Kết quả Test 2';


-- Chỉ những bài viết có nội dung >= 5 ký tự mới xuất hiện ở đây
SELECT post_id, user_id, content, created_at 
FROM posts 
WHERE user_id = 1 
ORDER BY created_at DESC;

DROP PROCEDURE IF EXISTS CreatePostWithValidation;

-- Bài 5
DELIMITER //

CREATE PROCEDURE CalculateUserActivityScore(
    IN p_user_id INT,
    OUT activity_score INT,
    OUT activity_level VARCHAR(50)
)
BEGIN
    DECLARE v_post_count INT DEFAULT 0;
    DECLARE v_comment_count INT DEFAULT 0;
    DECLARE v_like_count INT DEFAULT 0;

    -- 1. Đếm số bài viết (mỗi bài +10 điểm)
    SELECT COUNT(*) INTO v_post_count FROM posts WHERE user_id = p_user_id;

    -- 2. Đếm số bình luận (mỗi bình luận +5 điểm)
    SELECT COUNT(*) INTO v_comment_count FROM comments WHERE user_id = p_user_id;

    -- 3. Đếm số lượt like nhận được trên các bài viết của mình (mỗi like +3 điểm)
    SELECT COUNT(*) INTO v_like_count 
    FROM likes l
    JOIN posts p ON l.post_id = p.post_id
    WHERE p.user_id = p_user_id;

    -- Tính tổng điểm
    SET activity_score = (v_post_count * 10) + (v_comment_count * 5) + (v_like_count * 3);

    -- Phân loại mức độ hoạt động bằng CASE
    SET activity_level = CASE 
        WHEN activity_score > 500 THEN 'Rất tích cực'
        WHEN activity_score BETWEEN 200 AND 500 THEN 'Tích cực'
        ELSE 'Bình thường'
    END;
END //

DELIMITER ;

-- Gọi thủ tục và truyền kết quả vào 2 biến session
CALL CalculateUserActivityScore(1, @score, @level);

-- Hiển thị kết quả kèm tên người dùng để dễ theo dõi
SELECT 
    full_name AS 'Người dùng',
    @score AS 'Tổng điểm hoạt động',
    @level AS 'Phân loại'
FROM users 
WHERE user_id = 1;

DROP PROCEDURE IF EXISTS CalculateUserActivityScore;

-- Bài 6

DELIMITER //

CREATE PROCEDURE NotifyFriendsOnNewPost(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    DECLARE v_sender_name VARCHAR(100);
    DECLARE v_friend_id INT;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor để lấy tất cả bạn bè đã accepted (cả 2 chiều)
    DECLARE friend_cursor CURSOR FOR 
        SELECT friend_id FROM friends WHERE user_id = p_user_id AND status = 'accepted'
        UNION
        SELECT user_id FROM friends WHERE friend_id = p_user_id AND status = 'accepted';
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 1. Lấy tên người đăng bài
    SELECT full_name INTO v_sender_name FROM users WHERE user_id = p_user_id;

    IF v_sender_name IS NOT NULL THEN
        -- 2. Thêm bài viết mới
        INSERT INTO posts (user_id, content, created_at) 
        VALUES (p_user_id, p_content, NOW());

        -- 3. Gửi thông báo cho bạn bè bằng Cursor
        OPEN friend_cursor;
        
        read_loop: LOOP
            FETCH friend_cursor INTO v_friend_id;
            IF done THEN
                LEAVE read_loop;
            END IF;
            
            -- Chèn thông báo cho từng người bạn
            INSERT INTO notifications (user_id, type, content, is_read, created_at)
            VALUES (
                v_friend_id, 
                'new_post', 
                CONCAT(v_sender_name, ' đã đăng một bài viết mới'), 
                0, 
                NOW()
            );
        END LOOP;

        CLOSE friend_cursor;
        
        SELECT 'Thành công' AS status, 'Bài viết và thông báo đã được tạo' AS message;
    ELSE
        SELECT 'Lỗi' AS status, 'Người dùng không tồn tại' AS message;
    END IF;
END //

DELIMITER ;

-- Thực hiện đăng bài
CALL NotifyFriendsOnNewPost(1, 'Chào buổi sáng cả nhà! Chúc mọi người một ngày làm việc hiệu quả.');


SELECT 
    n.notification_id,
    u.full_name AS 'Người nhận thông báo',
    n.content AS 'Nội dung thông báo',
    n.created_at
FROM notifications n
JOIN users u ON n.user_id = u.user_id
WHERE n.type = 'new_post'
ORDER BY n.created_at DESC;


DROP PROCEDURE IF EXISTS NotifyFriendsOnNewPost;