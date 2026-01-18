/*
 * DATABASE SETUP - SESSION 15 EXAM
 * Database: StudentManagement
 */

DROP DATABASE IF EXISTS StudentManagement;
CREATE DATABASE StudentManagement;
USE StudentManagement;

-- =============================================
-- 1. TABLE STRUCTURE
-- =============================================

-- Table: Students
CREATE TABLE Students (
    StudentID CHAR(5) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    TotalDebt DECIMAL(10,2) DEFAULT 0
);

-- Table: Subjects
CREATE TABLE Subjects (
    SubjectID CHAR(5) PRIMARY KEY,
    SubjectName VARCHAR(50) NOT NULL,
    Credits INT CHECK (Credits > 0)
);

-- Table: Grades
CREATE TABLE Grades (
    StudentID CHAR(5),
    SubjectID CHAR(5),
    Score DECIMAL(4,2) CHECK (Score BETWEEN 0 AND 10),
    PRIMARY KEY (StudentID, SubjectID),
    CONSTRAINT FK_Grades_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    CONSTRAINT FK_Grades_Subjects FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
);

-- Table: GradeLog
CREATE TABLE GradeLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID CHAR(5),
    OldScore DECIMAL(4,2),
    NewScore DECIMAL(4,2),
    ChangeDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 2. SEED DATA
-- =============================================

-- Insert Students
INSERT INTO Students (StudentID, FullName, TotalDebt) VALUES 
('SV01', 'Ho Khanh Linh', 5000000),
('SV03', 'Tran Thi Khanh Huyen', 0);

-- Insert Subjects
INSERT INTO Subjects (SubjectID, SubjectName, Credits) VALUES 
('SB01', 'Co so du lieu', 3),
('SB02', 'Lap trinh Java', 4),
('SB03', 'Lap trinh C', 3);

-- Insert Grades
INSERT INTO Grades (StudentID, SubjectID, Score) VALUES 
('SV01', 'SB01', 8.5), -- Passed
('SV03', 'SB02', 3.0); -- Failed

-- Câu 1

DELIMITER //

CREATE TRIGGER tg_CheckScore
BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
    IF NEW.Score < 0 THEN
        SET NEW.Score = 0;
    ELSEIF NEW.Score > 10 THEN
        SET NEW.Score = 10;
    END IF;
END;
//

DELIMITER ;


-- Câu 2

START TRANSACTION;


INSERT INTO Students (StudentID, FullName)
VALUES (1, 'Bich Ngoc');


UPDATE Students
SET TotalDebt = 5000000
WHERE StudentID = 1;

COMMIT;


-- Câu 3 
CREATE TABLE ScoreLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    GradeID INT,
    OldScore FLOAT,
    NewScore FLOAT,
    ChangeTime DATETIME
);

DELIMITER //

CREATE TRIGGER tg_LogScoreUpdate
AFTER UPDATE ON Grades
FOR EACH ROW
BEGIN
    IF OLD.Score <> NEW.Score THEN
        INSERT INTO ScoreLog (GradeID, OldScore, NewScore, ChangeTime)
        VALUES (OLD.GradeID, OLD.Score, NEW.Score, NOW());
    END IF;
END;
//

DELIMITER ;

-- Câu 4


DELIMITER //

CREATE PROCEDURE sp_PayTuition(IN p_StudentID INT)
BEGIN
    DECLARE v_TotalDebt INT;

    START TRANSACTION;

    UPDATE Students
    SET TotalDebt = TotalDebt - 2000000
    WHERE StudentID = p_StudentID;

    SELECT TotalDebt INTO v_TotalDebt
    FROM Students
    WHERE StudentID = p_StudentID;

    IF v_TotalDebt < 0 THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END;
//

DELIMITER ;

CALL sp_PayTuition(1);


-- Câu 5

DELIMITER //

create trigger tg_PreventPassUpdate
before update on Grades
for each row
begin
    IF OLD.Score>=4.0 then
		signal sqlstate '45000'
        set message_text = ' sinh vien da qua mon , khong duoc sua diem ';
        end if;
	end;
//
    
DELIMITER ;


-- Câu 6
 DELIMITER //

CREATE PROCEDURE sp_DeleteStudentGrade(
    IN p_StudentID INT,
    IN p_SubjectID INT
)
BEGIN
    DECLARE v_OldScore FLOAT;

    START TRANSACTION;

   
    SELECT Score INTO v_OldScore
    FROM Grades
    WHERE StudentID = p_StudentID
      AND SubjectID = p_SubjectID;

    INSERT INTO GradeLog (StudentID, SubjectID, OldScore, NewScore, LogTime)
    VALUES (p_StudentID, p_SubjectID, v_OldScore, NULL, NOW());

    DELETE FROM Grades
    WHERE StudentID = p_StudentID
      AND SubjectID = p_SubjectID;

    IF ROW_COUNT() = 0 THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END;
//

DELIMITER ;


CALL sp_DeleteStudentGrade(1, 101);


    
    




