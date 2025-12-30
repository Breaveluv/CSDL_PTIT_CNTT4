create DATABASE StudentManagement;
USE StudentManagement;

-- Bài 1
CREATE TABLE Student (
    student_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(100) UNIQUE
);
INSERT INTO Student (student_id, full_name, date_of_birth, email)
VALUES
('SV001', 'Nguyễn Văn A', '2002-05-10', 'nguyenvana@gmail.com'),
('SV002', 'Trần Thị B', '2001-11-22', 'tranthib@gmail.com'),
('SV003', 'Lê Văn C', '2003-03-15', 'levanc@gmail.com');
SELECT * FROM Student;

-- Bài 2
UPDATE Student
SET email = 'nguyenvana_new@gmail.com'
WHERE student_id = 'SV001';

UPDATE Student
SET email = 'student3_new@gmail.com'
WHERE student_id = 'SV003';
DELETE FROM Student
WHERE student_id = 5;
SELECT * FROM Student;

-- Bài 3
CREATE TABLE Subject (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    credit INT CHECK (credit > 0)
);
INSERT INTO Subject (subject_id, subject_name, credit)
VALUES
(1, 'Cơ sở dữ liệu', 3),
(2, 'Lập trình Java', 4),
(3, 'Mạng máy tính', 3);

UPDATE Subject
SET credit = 5
WHERE subject_id = 2;

UPDATE Subject
SET subject_name = 'Mạng máy tính nâng cao'
WHERE subject_id = 3;

SELECT * FROM Subject;

-- Bài 4
CREATE TABLE Enrollment (
    student_id VARCHAR(20),
    subject_id INT,
    enroll_date DATE,
    
    PRIMARY KEY (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subject(subject_id)
);

INSERT INTO Enrollment (student_id, subject_id, enroll_date)
VALUES
('SV001', 1, '2024-09-01'),
('SV001', 2, '2024-09-01'),
('SV002', 1, '2024-09-02'),
('SV003', 3, '2024-09-03');

SELECT * FROM Enrollment;
SELECT *
FROM Enrollment
WHERE student_id = 'SV001';

--Bài 5
CREATE TABLE Score (
    student_id VARCHAR(20),
    subject_id INT,
    mid_score FLOAT CHECK (mid_score BETWEEN 0 AND 10),
    final_score FLOAT CHECK (final_score BETWEEN 0 AND 10),

    PRIMARY KEY (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subject(subject_id)
);

INSERT INTO Score (student_id, subject_id, mid_score, final_score)
VALUES
('SV001', 1, 7.5, 8.0),
('SV002', 2, 6.0, 7.5),
('SV003', 1, 8.5, 9.0);

UPDATE Score
SET final_score = 8.5
WHERE student_id = 'SV001'
  AND subject_id = 1;

SELECT * FROM Score;

SELECT *
FROM Score
WHERE final_score >= 8;
-- Bài 6
INSERT INTO Student (student_id, full_name, date_of_birth, email)
VALUES ('SV010', 'Phạm Minh Tuấn', '2003-06-15', 'tuanpm@gmail.com');

INSERT INTO Enrollment (student_id, subject_id, enroll_date)
VALUES
('SV010', 1, '2024-09-10'),
('SV010', 2, '2024-09-10');


INSERT INTO Score (student_id, subject_id, mid_score, final_score)
VALUES
('SV010', 1, 7.5, 8.0),
('SV010', 2, 6.5, 7.0);

UPDATE Score
SET final_score = 8.5
WHERE student_id = 'SV010'
  AND subject_id = 2;

DELETE FROM Enrollment
WHERE student_id = 'SV010'
  AND subject_id = 2;

SELECT 
    s.student_id,
    s.full_name,
    sub.subject_name,
    sc.mid_score,
    sc.final_score
FROM Student s
JOIN Score sc ON s.student_id = sc.student_id
JOIN Subject sub ON sc.subject_id = sub.subject_id
ORDER BY s.student_id;
