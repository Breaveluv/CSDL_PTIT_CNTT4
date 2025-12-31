CREATE DATABASE SRS;
USE SRS;

CREATE TABLE Teacher (
    TeacherID VARCHAR(20) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Student (
    StudentID VARCHAR(20) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    BirthDate DATE,
    Email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Course (
    CourseID VARCHAR(20) PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    Description TEXT,
    SessionCount INT CHECK (SessionCount > 0),
    TeacherID VARCHAR(20),
    CONSTRAINT FK_Course_Teacher FOREIGN KEY (TeacherID) REFERENCES Teacher(TeacherID)
);


CREATE TABLE Enrollment (
    StudentID VARCHAR(20),
    CourseID VARCHAR(20),
    EnrollDate DATE DEFAULT (CURRENT_DATE),
    PRIMARY KEY (StudentID, CourseID), 
    CONSTRAINT FK_Enroll_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_Enroll_Course FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

CREATE TABLE Score (
    StudentID VARCHAR(20),
    CourseID VARCHAR(20),
    MidtermScore DECIMAL(4,2) CHECK (MidtermScore BETWEEN 0 AND 10),
    FinalScore DECIMAL(4,2) CHECK (FinalScore BETWEEN 0 AND 10),
    PRIMARY KEY (StudentID, CourseID), 
    CONSTRAINT FK_Score_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_Score_Course FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);


INSERT INTO Teacher (TeacherID, FullName, Email) VALUES
('T001', 'Nguyen Van A', 'a@example.com'),
('T002', 'Tran Thi B', 'b@example.com'),
('T003', 'Le Van C', 'c@example.com'),
('T004', 'Pham Thi D', 'd@example.com'),
('T005', 'Hoang Van E', 'e@example.com');

INSERT INTO Student (StudentID, FullName, BirthDate, Email) VALUES
('S001', 'Nguyen Van F', '2000-01-01', 'f@example.com'),
('S002', 'Tran Thi G', '2000-02-02', 'g@example.com'),
('S003', 'Le Van H', '2000-03-03', 'h@example.com'),
('S004', 'Pham Thi I', '2000-04-04', 'i@example.com'),
('S005', 'Hoang Van J', '2000-05-05', 'j@example.com');

INSERT INTO Course (CourseID, CourseName, Description, SessionCount, TeacherID) VALUES
('C001', 'Math 101', 'Basic Math', 10, 'T001'),
('C002', 'Physics 101', 'Basic Physics', 12, 'T002'),
('C003', 'Chemistry 101', 'Basic Chemistry', 8, 'T003'),
('C004', 'Biology 101', 'Basic Biology', 15, 'T004'),
('C005', 'History 101', 'Basic History', 20, 'T005');

INSERT INTO Enrollment (StudentID, CourseID, EnrollDate) VALUES
('S001', 'C001', '2023-09-01'),
('S001', 'C002', '2023-09-01'),
('S002', 'C002', '2023-09-01'),
('S002', 'C003', '2023-09-01'),
('S003', 'C003', '2023-09-01'),
('S003', 'C004', '2023-09-01'),
('S004', 'C004', '2023-09-01'),
('S004', 'C005', '2023-09-01'),
('S005', 'C005', '2023-09-01'),
('S005', 'C001', '2023-09-01');

INSERT INTO Score (StudentID, CourseID, MidtermScore, FinalScore) VALUES
('S001', 'C001', 7.5, 8.0),
('S001', 'C002', 6.0, 7.0),
('S002', 'C002', 8.0, 8.5),
('S002', 'C003', 7.0, 7.5),
('S003', 'C003', 9.0, 9.0),
('S003', 'C004', 8.5, 8.0),
('S004', 'C004', 6.5, 7.0),
('S004', 'C005', 7.0, 7.5),
('S005', 'C005', 8.0, 8.5),
('S005', 'C001', 7.5, 8.0);


UPDATE Student SET Email = 'newf@example.com' WHERE StudentID = 'S001';

UPDATE Course SET Description = 'Advanced Basic Math' WHERE CourseID = 'C001';

UPDATE Score SET FinalScore = 9.5 WHERE StudentID = 'S001' AND CourseID = 'C001';


DELETE FROM Enrollment WHERE StudentID = 'S001' AND CourseID = 'C002';

DELETE FROM Score WHERE StudentID = 'S001' AND CourseID = 'C002';


SELECT * FROM Student;

SELECT * FROM Teacher;

SELECT * FROM Course;

SELECT * FROM Enrollment;

SELECT * FROM Score;





















































































