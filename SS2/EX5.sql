CREATE TABLE Score (
    student_id INT,
    subject_id INT,
    mid_score FLOAT,
final_score FLOAT,
CHECK (mid_score >= 0 AND mid_score <= 10),
CHECK (final_score >= 0 AND final_score <= 10)


    PRIMARY KEY (student_id, subject_id),

    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subject(subject_id)
);
