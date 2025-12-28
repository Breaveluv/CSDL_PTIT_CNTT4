-- 1. Tạo database
CREATE DATABASE SchoolDB;
USE SchoolDB;

-- 2. Tạo bảng Student
CREATE TABLE Student (
    student_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);

-- 3. Tạo bảng Subject
CREATE TABLE Subject (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    credit INT CHECK (credit > 0)
);

-- 4. Tạo bảng Enrollment (bảng trung gian)
CREATE TABLE Enrollment (
    student_id INT,
    subject_id INT,
    register_date DATE,

    PRIMARY KEY (student_id, subject_id),

    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subject(subject_id)
);

-- 5. Thêm dữ liệu mẫu
INSERT INTO Student VALUES
(1, 'Nguyễn Văn A'),
(2, 'Trần Thị B');

INSERT INTO Subject VALUES
(101, 'Cơ sở dữ liệu', 3),
(102, 'Lập trình Java', 4);

INSERT INTO Enrollment VALUES
(1, 101, '2025-01-10'),
(1, 102, '2025-01-12'),
(2, 101, '2025-01-15');
