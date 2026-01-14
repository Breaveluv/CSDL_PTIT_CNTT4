create database if not exists social_network;
use social_network;

-- bảng users
create table users (
    user_id int auto_increment primary key,
    username varchar(50) unique not null,
    password varchar(255) not null,
    email varchar(100) unique not null,
    created_at datetime default current_timestamp,
    is_active tinyint default 1
);

-- bảng posts
create table posts (
    post_id int auto_increment primary key,
    user_id int,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id)
);

-- bảng comments
create table comments (
    comment_id int auto_increment primary key,
    post_id int,
    user_id int,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id)
);

-- bảng friends
create table friends (
    user_id int,
    friend_id int,
    status varchar(20) check (status in ('pending','accepted')),
    primary key (user_id, friend_id),
    foreign key (user_id) references users(user_id),
    foreign key (friend_id) references users(user_id)
);

-- bảng likes
create table likes (
    user_id int,
    post_id int,
    primary key (user_id, post_id),
    foreign key (user_id) references users(user_id),
    foreign key (post_id) references posts(post_id)
);

-- bài 1: quản lý người dùng (đăng ký tài khoản)
insert into users(username, password, email) values ('an123','123456','an@gmail.com');
insert into users(username, password, email) values ('binh456','123456','binh@gmail.com');
select * from users;

-- bài 2: hiển thị thông tin công khai bằng view (trang hồ sơ công khai)
create view vw_public_users as
select user_id, username, created_at
from users;

select * from vw_public_users;
select user_id, username, created_at from users;

-- bài 3: tối ưu tìm kiếm người dùng bằng index (tìm kiếm bạn bè)
create index idx_users_username on users(username);
select * from users where username = 'an123';

-- bài 4: quản lý bài viết bằng stored procedure (đăng bài viết)
delimiter //
create procedure sp_create_post(
    in p_user_id int,
    in p_content text
)
begin
    declare cnt int;
    select count(*) into cnt from users where user_id = p_user_id;
    if cnt > 0 then
        insert into posts(user_id, content)
        values (p_user_id, p_content);
    end if;
end//
delimiter ;

call sp_create_post(1,'bài viết đầu tiên');

-- bài 5: hiển thị news feed bằng view (trang chủ mạng xã hội)
create view vw_recent_posts as
select * from posts
where created_at >= now() - interval 7 day;

select * from vw_recent_posts;

-- bài 6: tối ưu truy vấn bài viết (xem bài viết của tôi)
create index idx_posts_user on posts(user_id);
create index idx_posts_user_time on posts(user_id, created_at);

select * from posts where user_id = 1 order by created_at desc;

-- bài 7: thống kê hoạt động bằng stored procedure (trang thống kê cá nhân)
delimiter //
create procedure sp_count_posts(
    in p_user_id int,
    out p_total int
)
begin
    select count(*) into p_total
    from posts
    where user_id = p_user_id;
end//
delimiter ;

call sp_count_posts(1,@total_posts);
select @total_posts;

-- bài 8: kiểm soát dữ liệu bằng view with check option (quản trị người dùng)
create view vw_active_users as
select user_id, username, email from users
where is_active = 1
with check option;

-- bài 9: quản lý kết bạn bằng stored procedure (gửi lời mời kết bạn)
delimiter //
create procedure sp_add_friend(
    in p_user_id int,
    in p_friend_id int
)
begin
    if p_user_id <> p_friend_id then
        insert into friends(user_id, friend_id, status)
        values (p_user_id, p_friend_id, 'pending');
    end if;
end//
delimiter ;

call sp_add_friend(1,2);

-- bài 10: gợi ý bạn bè bằng procedure nâng cao (gợi ý bạn bè)
delimiter //
create procedure sp_suggest_friends(
    in p_user_id int,
    inout p_limit int
)
begin
    while p_limit > 0 do
        select friend_id from friends
        where user_id != p_user_id
        limit 1;
        set p_limit = p_limit - 1;
    end while;
end//
delimiter ;

set @lim = 2;
call sp_suggest_friends(1,@lim);

-- bài 11: thống kê tương tác nâng cao (bảng xếp hạng)
create index idx_likes_post on likes(post_id);

create view vw_top_posts as
select post_id, count(*) as total_likes from likes
group by post_id
order by total_likes desc
limit 5;

-- bài 12: quản lý bình luận (người dùng bình luận vào bài viết)
delimiter //
create procedure sp_add_comment(
    in p_user_id int,
    in p_post_id int,
    in p_content text
)
begin
    declare u_cnt int;
    declare p_cnt int;

    select count(*) into u_cnt from users where user_id = p_user_id;
    select count(*) into p_cnt from posts where post_id = p_post_id;

    if u_cnt > 0 and p_cnt > 0 then
        insert into comments(user_id, post_id, content)
        values (p_user_id, p_post_id, p_content);
    end if;
end//
delimiter ;

call sp_add_comment(1,1,'bình luận đầu tiên');

create view vw_post_comments as
select c.content, u.username, c.created_at from comments c
join users u on c.user_id = u.user_id;

-- bài 13: quản lý lượt thích (người dùng thích bài viết)
delimiter //
create procedure sp_like_post(
    in p_user_id int,
    in p_post_id int
)
begin
    declare cnt int;
    select count(*) into cnt from likes
    where user_id = p_user_id and post_id = p_post_id;

    if cnt = 0 then
        insert into likes(user_id, post_id)
        values (p_user_id, p_post_id);
    end if;
end//
delimiter ;

call sp_like_post(1,1);

create view vw_post_likes as
select post_id, count(*) as total_likes from likes
group by post_id;

-- bài 14: tìm kiếm người dùng & bài viết (chức năng tìm kiếm)
delimiter //
create procedure sp_search_social(
    in p_option int,
    in p_keyword varchar(100)
)
begin
    if p_option = 1 then
        select * from users
        where username like concat('%', p_keyword, '%');
    elseif p_option = 2 then
        select * from posts
        where content like concat('%', p_keyword, '%');
    else
        select 'option không hợp lệ' as message;
    end if;
end//
delimiter ;

call sp_search_social(1,'an');
call sp_search_social(2,'database');
