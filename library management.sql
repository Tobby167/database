-- ====================================================
-- 1. Create Schema (User)
-- ====================================================
CREATE USER library_user IDENTIFIED BY lib123
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
  QUOTA 50M ON users;

GRANT CONNECT, RESOURCE TO library_user;

-- ====================================================
-- 2. Create Core Tables
-- ====================================================
-- Members
CREATE TABLE members (
    member_id     NUMBER PRIMARY KEY,
    full_name     VARCHAR2(100) NOT NULL,
    email         VARCHAR2(100) UNIQUE,
    phone         VARCHAR2(20),
    join_date     DATE DEFAULT SYSDATE
);

-- Books
CREATE TABLE books (
    book_id       NUMBER PRIMARY KEY,
    title         VARCHAR2(150) NOT NULL,
    author        VARCHAR2(100),
    isbn          VARCHAR2(20) UNIQUE,
    published_year NUMBER,
    available_copies NUMBER DEFAULT 1
);

-- Loans
CREATE TABLE loans (
    loan_id       NUMBER PRIMARY KEY,
    member_id     NUMBER REFERENCES members(member_id),
    book_id       NUMBER REFERENCES books(book_id),
    loan_date     DATE DEFAULT SYSDATE,
    return_date   DATE,
    status        VARCHAR2(20) DEFAULT 'ON LOAN'
);

-- ====================================================
-- 3. Sequences for Auto IDs
-- ====================================================
CREATE SEQUENCE seq_member START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_book START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE seq_loan START WITH 500 INCREMENT BY 1;

-- ====================================================
-- 4. Trigger for Auto-Inserting IDs
-- ====================================================
CREATE OR REPLACE TRIGGER trg_member_id
BEFORE INSERT ON members
FOR EACH ROW
BEGIN
  :NEW.member_id := seq_member.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER trg_book_id
BEFORE INSERT ON books
FOR EACH ROW
BEGIN
  :NEW.book_id := seq_book.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER trg_loan_id
BEFORE INSERT ON loans
FOR EACH ROW
BEGIN
  :NEW.loan_id := seq_loan.NEXTVAL;
END;
/

-- ====================================================
-- 5. Views
-- ====================================================
-- Show active loans with member and book info
CREATE OR REPLACE VIEW v_active_loans AS
SELECT l.loan_id, m.full_name, b.title, l.loan_date, l.status
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.status = 'ON LOAN';

-- ====================================================
-- 6. Synonyms (for easy access)
-- ====================================================
CREATE SYNONYM active_loans FOR v_active_loans;

-- ====================================================
-- 7. Package (for borrowing/returning books)
-- ====================================================
CREATE OR REPLACE PACKAGE pkg_library AS
  PROCEDURE borrow_book(p_member_id NUMBER, p_book_id NUMBER);
  PROCEDURE return_book(p_loan_id NUMBER);
END pkg_library;
/

CREATE OR REPLACE PACKAGE BODY pkg_library AS
  PROCEDURE borrow_book(p_member_id NUMBER, p_book_id NUMBER) IS
  BEGIN
    INSERT INTO loans(member_id, book_id)
    VALUES (p_member_id, p_book_id);
    
    UPDATE books SET available_copies = available_copies - 1
    WHERE book_id = p_book_id;
  END;
  
  PROCEDURE return_book(p_loan_id NUMBER) IS
  BEGIN
    UPDATE loans
    SET status = 'RETURNED', return_date = SYSDATE
    WHERE loan_id = p_loan_id;
    
    UPDATE books b
    SET available_copies = available_copies + 1
    WHERE b.book_id = (SELECT book_id FROM loans WHERE loan_id = p_loan_id);
  END;
END pkg_library;
/

-- ====================================================
-- 8. Security & Privileges
-- ====================================================
-- Suppose another user (report_user) only needs to read
CREATE USER report_user IDENTIFIED BY rep123;
GRANT CONNECT TO report_user;

-- Give only SELECT privilege on views
GRANT SELECT ON v_active_loans TO report_user;

-- ====================================================
-- 9. Auditing (track logins on this schema)
-- ====================================================
AUDIT SESSION BY library_user BY ACCESS;
