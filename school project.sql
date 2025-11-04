-- creating database
(
CREATE DATABASE school_app CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE school_app;
)

-- class table
CREATE TABLE classes (
  class_code VARCHAR(10) PRIMARY KEY,
  class_name VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Students table
CREATE TABLE students (
  student_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  age TINYINT UNSIGNED NOT NULL,
  class_code VARCHAR(10) NOT NULL,
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  CONSTRAINT fk_students_class
    FOREIGN KEY (class_code)
    REFERENCES classes(class_code)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT ck_age_valid CHECK (age BETWEEN 3 AND 120)
) ENGINE=InnoDB;

-- indexes for searching
(
CREATE INDEX idx_students_name ON students(name);
CREATE INDEX idx_students_class ON students(class_code);
CREATE INDEX idx_students_isdel ON students(is_deleted);
)

-- Generic audit log for triggers + procedures
CREATE TABLE audit_log (
  audit_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Uploaded_by VARCHAR(100) NULL,      -- who did it (optional; pass from procedure)
  Uploaders_action VARCHAR(50) NOT NULL,  -- e.g., INSERT/UPDATE/DELETE/SOFT_DELETE/RESTORE
  entity VARCHAR(50) NOT NULL,  -- e.g., students
  entity_id VARCHAR(64) NULL,
  details JSON NULL
) ENGINE=InnoDB;

-- =====================
-- UTILITY FUNCTION(S)
-- =====================

-- Clean up names: trim and collapse inner whitespace
DROP FUNCTION IF EXISTS fx_clean_name;
DELIMITER //
CREATE FUNCTION fx_clean_name(p_name VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE v VARCHAR(255);
  SET v = TRIM(p_name);
  -- collapse multiple whitespace to single space (MySQL 8.0+)
  SET v = REGEXP_REPLACE(v, '\\s+', ' ');
  RETURN v;
END //
DELIMITER ;