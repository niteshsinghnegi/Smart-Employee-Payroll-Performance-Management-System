----- Smart Employee Payroll & Performance Management System---------
---author --- Nitesh Singh Negi 
--ER diagram or structure 
DEPARTMENTS
    |
    | 1
    |
    |----< EMPLOYEES
                |
                | 1
                |----< ATTENDANCE
                |
                | 1
                |----< PERFORMANCE
                |
                | 1
                |----< PAYROLL
--🧱 Entities (Tables)
--1️⃣ DEPARTMENTS

--dept_id (PK)

--dept_name

--2️⃣ EMPLOYEES

--emp_id (PK)

--name

--email

-- gender

-- join_date

-- base_salary

-- dept_id (FK)

-- 3️⃣ ATTENDANCE

-- att_id (PK)

-- emp_id (FK)

-- att_date

-- status

-- 4️⃣ PERFORMANCE

-- perf_id (PK)

-- emp_id (FK)

-- rating

-- review_date

-- 5️⃣ PAYROLL

-- payroll_id (PK)

-- emp_id (FK)

-- month

-- total_salary

-- bonus

-- net_salary

--------------------query-----------------------------
----------------------------------------------------------------------------------------------
-- DEPARTMENT TABLE 
CREATE TABLE department (
dept_id  SERIAL PRIMARY KEY ,
dept_name VARCHAR(100) NOT NULL
);

-- EMPLOYEE TABLE 
CREATE TABLE employee(
emp_id  SERIAL PRIMARY KEY ,
emp_name VARCHAR(100) NOT NULL ,
email VARCHAR UNIQUE NOT NULL ,
gender VARCHAR(10) CHECK (gender IN ('male','female','other')),
join_date DATE NOT NULL ,
base_salary NUMERIC(10,2) NOT NULL ,
FOREIGN KEY (emp_id) REFERENCES employee (emp_id)
);

ALTER TABLE EMPLOYEE 
ADD COLUMN DEPT_ID INT ;

ALTER TABLE EMPLOYEE 
ADD FOREIGN KEY (dept_id) REFERENCES department (dept_id) ;


ALTER TABLE employee
DROP CONSTRAINT employee_gender_check;

ALTER TABLE employee
ADD CONSTRAINT employee_gender_check
CHECK (UPPER(gender) IN ('MALE','FEMALE'));


--ATTENDENCE TABLE 
CREATE TABLE attendence(
att_id SERIAL PRIMARY KEY ,
emp_id int not null ,
FOREIGN KEY (emp_id) REFERENCES employee(emp_id) on delete cascade ,
att_date date UNIQUE NOT NULL ,
status VARCHAR(10) CHECK (STATUS IN ('PRESENT','ABSENT'))
);

--PERFORMANCE TABLE 

CREATE TABLE performance (
perf_id SERIAL PRIMARY KEY ,
emp_id INT NOT NULL ,
rating int CHECK (RATING BETWEEN 1 AND 5),
review_date DATE ,
FOREIGN KEY(emp_id)REFERENCES employee (emp_id)
);

-- PAYROLL TABLE 
CREATE TABLE payroll (
payroll_id  SERIAL PRIMARY KEY,
emp_id INT NOT NULL ,
month  VARCHAR(20),
toatal_salary NUMERIC  (10,2),
bonus_salary NUMERIC (10,2),
net_salary NUMERIC (10,2),
FOREIGN KEY(emp_id) REFERENCES employee (emp_id)
);

ALTER TABLE PAYROLL 
RENAME COLUMN BONUS_SALARY TO BONUS;

--inserting data in department 
INSERT INTO department (dept_name) VALUES
('HR'),('IT'),('Finance'),('Sales');

-- inserting data in employee
INSERT INTO employee 
(emp_name, email, gender, dept_id, join_date, base_salary) 
VALUES
('Nitesh Negi','nitesh@gmail.com','MALE',2,'2022-01-10',40000),
('Anjali Sharma','anjali@gmail.com','FEMALE',1,'2021-05-15',35000),
('Rohit Verma','rohit@gmail.com','MALE',2,'2020-03-20',50000),
('Sneha Gupta','sneha@gmail.com','FEMALE',3,'2019-07-11',45000),
('Amit Singh','amit@gmail.com','MALE',4,'2023-02-01',30000),

('Rahul Mehta','rahul@gmail.com','MALE',1,'2021-06-18',42000),
('Priya Kapoor','priya@gmail.com','FEMALE',2,'2020-08-22',48000),
('Vikas Yadav','vikas@gmail.com','MALE',3,'2019-02-10',55000),
('Neha Jain','neha@gmail.com','FEMALE',4,'2022-09-01',38000),
('Suresh Kumar','suresh@gmail.com','MALE',1,'2018-11-30',60000),

('Pooja Mishra','pooja@gmail.com','FEMALE',2,'2023-01-05',32000),
('Arjun Patel','arjun@gmail.com','MALE',3,'2020-04-14',47000),
('Kiran Rao','kiran@gmail.com','FEMALE',4,'2019-12-19',52000),
('Manoj Tiwari','manoj@gmail.com','MALE',1,'2017-10-25',65000),
('Ritika Malhotra','ritika@gmail.com','FEMALE',2,'2021-03-08',41000),

('Deepak Chauhan','deepak@gmail.com','MALE',3,'2022-07-21',36000),
('Simran Kaur','simran@gmail.com','FEMALE',4,'2020-01-16',49000),
('Akash Pandey','akash@gmail.com','MALE',1,'2019-05-09',53000),
('Nidhi Saxena','nidhi@gmail.com','FEMALE',2,'2023-04-12',30000),
('Gaurav Joshi','gaurav@gmail.com','MALE',3,'2018-08-27',62000);

---making a function to calculate bounus 
CREATE OR REPLACE FUNCTION CAL_BONUS(rating int ,salary numeric )
RETURNS NUMERIC as $$
BEGIN 
     IF RATING >=4 THEN 
        RETURN salary *0.20;
		elsif rating =3 then 
		return salary *0.10;
		else return 0;
END IF ;
END;
$$ LANGUAGE PLPGSQL ;
		
-- CREATE TRIGGER 
CREATE OR REPLACE FUNCTION payroll_trigger()
RETURNS TRIGGER AS $$
DECLARE
    emp_salary NUMERIC;
    emp_bonus  NUMERIC;
BEGIN
    -- Fetch employee salary
    SELECT base_salary
    INTO emp_salary
    FROM employee
    WHERE emp_id = NEW.emp_id;

    -- Calculate bonus using function
    emp_bonus := cal_bonus(NEW.rating, emp_salary);

    -- Insert into payroll table
    INSERT INTO payroll (emp_id, pay_month, total_salary, bonus, net_salary)
    VALUES (
        NEW.emp_id,
        'March',
        emp_salary,
        emp_bonus,
        emp_salary + emp_bonus
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_payroll
AFTER INSERT ON performance
FOR EACH ROW
EXECUTE FUNCTION payroll_trigger();

--View – HR Dashboard
CREATE VIEW hr_dashboard AS
select d.dept_name,
count(e.emp_id) as total_employee,
avg(e.base_salary) as avg_salary from employee e
join  department d on e.dept_id=d.dept_id
group by d.dept_name;

--Top Paid Employee Per Department

SELECT DEPT_ID,EMP_NAME,BASE_SALARY

FROM(
SELECT emp_name,dept_id, base_salary,
rank() over(partition by dept_id  order by base_salary desc) rnk 
from employee) t 

where rnk=1;

--- payroll record 
SELECT e.emp_name, p.month, p.net_salary
FROM payroll p
JOIN employee e ON p.emp_id = e.emp_id;