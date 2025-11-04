USE employees; 
CREATE TABLE employees (
employee_id int,
first_name VARCHAR(50),
last_name VARCHAR(50),
hourly_pay DECIMAL(5, 2),
image BLOB
);
DESC TABLE employees;
INSERT INTO employees (id,image) values 
					  (1, load_file('https://1drv.ms/i/c/56914ba667d93d53/EWUWH2LgJVFMgcyP7jhIgYcBQiEBT3KvFrOulhMuUp4hkw?e=lbIrWq'));
SELECT * FROM employees;