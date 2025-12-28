
DROP DATABASE IF EXISTS SchoolManagement;
CREATE DATABASE SchoolManagement;
USE SchoolManagement;
CREATE TABLE Class (
    ClassID VARCHAR(20) NOT NULL,
    ClassName VARCHAR(100) NOT NULL,
    AcademicYear INT,
    PRIMARY KEY (ClassID)
);


CREATE TABLE Student (
    StudentID VARCHAR(20) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    BirthDate DATE,
    ClassID VARCHAR(20),
    PRIMARY KEY (StudentID),
    

    CONSTRAINT FK_Student_Class 
    FOREIGN KEY (ClassID) REFERENCES Class(ClassID)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
);


INSERT INTO Class (ClassID, ClassName, AcademicYear) VALUES 
('CNTT01', 'Cong nghe thong tin 1', 2024),
('KT02', 'Ke toan 2', 2024);

INSERT INTO Student (StudentID, FullName, BirthDate, ClassID) VALUES 
('SV001', 'Nguyen Van A', '2005-01-15', 'CNTT01'),
('SV002', 'Tran Thi B', '2005-06-20', 'CNTT01'),
('SV003', 'Le Van C', '2005-11-05', 'KT02');

-- 7. Truy vấn kiểm tra kết quả
SELECT * FROM Class;
SELECT * FROM Student;