-- --------------------------
create database SocialNetworkDB;
use SocialNetworkDB;
create table users(
	user_id int auto_increment primary key,
    username  varchar(100) not null unique,
    total_posts int default 0
);

create table posts(
	post_id int auto_increment primary key,
    user_id int references users(user_id),
    content text,
    created_at  datetime
);

create table post_audits(	
	audit_id int auto_increment primary key,
    post_id int references posts(post_id),
    old_content text,
    new_content  text,
	changed_at  datetime
);

/*
Task 1 (BEFORE INSERT): Viết trigger tg_CheckPostContent trên bảng posts.
Nhiệm vụ: Kiểm tra nội dung bài viết (content). Nếu nội dung trống hoặc chỉ toàn khoảng trắng,
hãy ngăn chặn hành động chèn và thông báo lỗi: "Nội dung bài viết không được để trống!".
*/
delimiter //
create trigger tg_CheckPostContent
before insert on posts
for each row
begin
	if New.content = ' ' or length(New.content)=0 or New.content is null then
		signal sqlstate '45000' set message_text = 'Nội dung bài viết không được để trống!';
    end if;
end //
delimiter ;
-- test
-- insert users
insert into users(username) values
('cuongbg'),('dunghn'),('binhnt');

select * from posts;

insert into posts(user_id,content,created_at) values
(1,'',current_date());
insert into posts(user_id,created_at) values
(1,current_date());

/*
Task 2 (AFTER INSERT): Viết trigger tg_UpdatePostCountAfterInsert trên bảng posts.
Nhiệm vụ: Mỗi khi một bài viết được thêm mới thành công, hãy tự động tăng giá trị cột 
total_posts của người dùng đó trong bảng users lên 1 đơn vị.
*/


insert into posts(user_id,content,created_at) values
(1,'Bài viết 1 của bạn Cường',current_date()),
(1,'Bài viết 2 của bạn Cường',current_date()),
(2,'Bài viết 1 của bạn Dũng',current_date());

select * from users;

/*
Task 3 (AFTER UPDATE): Viết trigger tg_LogPostChanges trên bảng posts.
Nhiệm vụ: Khi nội dung (content) của một bài viết bị thay đổi, hãy tự động chèn một dòng 
vào bảng post_audits để lưu lại nội dung cũ, nội dung mới và thời điểm chỉnh sửa.
*/


select * from posts;
update posts set content = 'Bài viết 2 đã được cập nhật lại của bạn Cường' where post_id=5;

select * from post_audits;

/*
Task 4 (AFTER DELETE): Viết trigger tg_UpdatePostCountAfterDelete trên bảng posts.
Nhiệm vụ: Khi một bài viết bị xóa, hãy tự động giảm giá trị cột total_posts của người 
dùng đó trong bảng users xuống 1 đơn vị.
*/


select * from users;

delete from posts where post_id = 5;