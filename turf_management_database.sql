

-- =====================================================================
-- 1. DATABASE KEYWORDS
-- =====================================================================
DROP DATABASE IF EXISTS turf_management;
CREATE DATABASE IF NOT EXISTS turf_management;
USE turf_management;

-- =====================================================================
-- 2, 3, 4. TABLE KEYWORDS + CONSTRAINTS + DATA TYPES
-- =====================================================================

-- ---------- TURFS ----------
CREATE TABLE turfs (
    turf_id         INT AUTO_INCREMENT PRIMARY KEY,
    turf_name       VARCHAR(60)  NOT NULL UNIQUE,
    sport_type      ENUM('Football','Cricket','Badminton','Multi') NOT NULL DEFAULT 'Multi',
    location        VARCHAR(100) NOT NULL,
    capacity        INT          NOT NULL DEFAULT 10,
    price_per_hour  DECIMAL(8,2) NOT NULL,
    status          ENUM('Active','Maintenance','Closed') NOT NULL DEFAULT 'Active',
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_turf_price    CHECK (price_per_hour > 0),
    CONSTRAINT chk_turf_capacity CHECK (capacity > 0)
);

-- ---------- CUSTOMERS ----------
CREATE TABLE customers (
    customer_id  INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(60) NOT NULL,
    phone        VARCHAR(20) NOT NULL UNIQUE,
    email        VARCHAR(80) NULL,
    city         VARCHAR(40) NOT NULL DEFAULT 'Chennai',
    joined_date  DATE        NOT NULL
);

-- ---------- STAFF ----------
CREATE TABLE staff (
    staff_id    INT AUTO_INCREMENT PRIMARY KEY,
    staff_name  VARCHAR(60)  NOT NULL,
    role        ENUM('Manager','Groundskeeper','Coach','Receptionist') NOT NULL,
    salary      DECIMAL(10,2) NOT NULL,
    phone       VARCHAR(20)  NOT NULL UNIQUE,
    hire_date   DATE         NOT NULL,
    CONSTRAINT chk_salary CHECK (salary >= 0)
);

-- ---------- BOOKINGS ----------
CREATE TABLE bookings (
    booking_id    INT AUTO_INCREMENT PRIMARY KEY,
    turf_id       INT          NOT NULL,
    customer_id   INT          NOT NULL,
    booking_date  DATE         NOT NULL,
    start_time    TIME         NOT NULL,
    end_time      TIME         NOT NULL,
    hours         INT          NOT NULL,
    total_amount  DECIMAL(10,2) NOT NULL,
    status        ENUM('Pending','Confirmed','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_turf     FOREIGN KEY (turf_id)     REFERENCES turfs(turf_id),
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT chk_time_order      CHECK (end_time > start_time),
    CONSTRAINT chk_hours           CHECK (hours > 0)
);

-- ---------- PAYMENTS ----------
CREATE TABLE payments (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    booking_id      INT           NOT NULL,
    amount          DECIMAL(10,2) NOT NULL,
    payment_mode    ENUM('Cash','UPI','Card') NOT NULL DEFAULT 'UPI',
    payment_date    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status  ENUM('Paid','Partial','Pending','Refunded') NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT chk_amount CHECK (amount >= 0)
);

-- ---------- MAINTENANCE ----------
CREATE TABLE maintenance (
    maintenance_id   INT AUTO_INCREMENT PRIMARY KEY,
    turf_id          INT NOT NULL,
    staff_id         INT NULL,
    maintenance_type ENUM('Grass Cutting','Watering','Net Repair','Floodlight Fix','Cleaning') NOT NULL,
    maintenance_date DATE NOT NULL,
    cost             DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    notes            VARCHAR(150) NULL,
    CONSTRAINT fk_maint_turf  FOREIGN KEY (turf_id)  REFERENCES turfs(turf_id),
    CONSTRAINT fk_maint_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

-- ---------- FEEDBACK (created small, then altered & renamed) ----------
CREATE TABLE feedback (
    feedback_id  INT AUTO_INCREMENT PRIMARY KEY,
    booking_id   INT NOT NULL,
    comments     VARCHAR(100),
    CONSTRAINT fk_feedback_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- ---------- ALTER TABLE: ADD / MODIFY / COLUMN / RENAME ----------
ALTER TABLE feedback ADD COLUMN rating INT NOT NULL DEFAULT 5;
ALTER TABLE feedback MODIFY COLUMN comments VARCHAR(255) NULL;
ALTER TABLE feedback ADD CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5);
ALTER TABLE feedback RENAME TO customer_feedback;

ALTER TABLE customers ADD COLUMN loyalty_points INT NOT NULL DEFAULT 0;
ALTER TABLE customers MODIFY COLUMN full_name VARCHAR(80) NOT NULL;
ALTER TABLE turfs     ADD COLUMN floodlights VARCHAR(3) NOT NULL DEFAULT 'Yes';

-- ---------- Scratch table to demo TRUNCATE and DROP ----------
CREATE TABLE temp_log (
    log_id   INT AUTO_INCREMENT PRIMARY KEY,
    message  VARCHAR(100) NULL
);
INSERT INTO temp_log (message) VALUES ('first log'), ('second log');
TRUNCATE TABLE temp_log;
DROP TABLE IF EXISTS temp_log;

-- ---------- SHOW / DESCRIBE ----------
SHOW TABLES;
DESCRIBE turfs;
DESCRIBE bookings;
DESCRIBE customer_feedback;

-- =====================================================================
-- 5. INSERT / UPDATE / DELETE
-- =====================================================================

INSERT INTO turfs (turf_name, sport_type, location, capacity, price_per_hour, status, floodlights) VALUES
('Green Arena',      'Football',  'Anna Nagar, Chennai',   14, 1500.00, 'Active', 'Yes'),
('Strike Box Cricket','Cricket',  'Velachery, Chennai',    12, 1200.00, 'Active', 'Yes'),
('Multi Sports Hub', 'Multi',     'Tambaram, Chennai',     20, 1000.00, 'Active', 'No'),
('Royal Pitch',      'Football',  'OMR, Chennai',          16, 1800.00, 'Active', 'Yes');

INSERT INTO customers (full_name, phone, email, city, joined_date) VALUES
('Arun Kumar',   '+91-98765-43210', 'arun.kumar@gmail.com',  'Chennai',    '2026-01-15'),
('Priya Sharma', '+91-91234-56789', 'priya.s@yahoo.com',     'Chennai',    '2026-02-20'),
('Rahul Verma',  '+91-99887-76655', 'rahul.v@outlook.com',   'Coimbatore', '2026-03-05'),
('Sneha Reddy',  '+91-90000-12345', NULL,                    'Chennai',    '2026-04-18'),
('Vikram Singh', '+91-95555-44444', 'vikram.singh@gmail.com','Tiruppur',   '2026-06-01'),
('Divya Nair',   '+91-97777-88888', 'divya.nair@gmail.com',  'Chennai',    '2026-08-12');

INSERT INTO staff (staff_name, role, salary, phone, hire_date) VALUES
('Suresh Babu',  'Manager',       45000.00, '+91-94444-11111', '2024-01-10'),
('Murugan',      'Groundskeeper', 18000.00, '+91-94444-22222', '2024-06-15'),
('Karthik Raja', 'Coach',         25000.00, '+91-94444-33333', '2025-02-01'),
('Lakshmi',      'Receptionist',  16000.00, '+91-94444-44444', '2025-07-20');

INSERT INTO bookings (turf_id, customer_id, booking_date, start_time, end_time, hours, total_amount, status) VALUES
(1, 1, '2026-10-05', '18:00:00', '20:00:00', 2, 3000.00, 'Completed'),
(2, 2, '2026-10-12', '19:00:00', '21:00:00', 2, 2400.00, 'Completed'),
(1, 3, '2026-10-18', '06:00:00', '07:00:00', 1, 1500.00, 'Completed'),
(3, 4, '2026-10-25', '17:00:00', '20:00:00', 3, 3000.00, 'Completed'),
(4, 5, '2026-11-02', '20:00:00', '22:00:00', 2, 3600.00, 'Completed'),
(2, 1, '2026-11-08', '18:00:00', '19:00:00', 1, 1200.00, 'Cancelled'),
(1, 2, '2026-11-15', '19:00:00', '21:00:00', 2, 3000.00, 'Completed'),
(3, 6, '2026-11-22', '07:00:00', '09:00:00', 2, 2000.00, 'Confirmed'),
(4, 3, '2026-11-28', '21:00:00', '23:00:00', 2, 3600.00, 'Confirmed'),
(2, 5, '2026-12-05', '18:00:00', '20:00:00', 2, 2400.00, 'Pending');

INSERT INTO payments (booking_id, amount, payment_mode, payment_date, payment_status) VALUES
(1, 3000.00, 'UPI',  '2026-10-05 17:30:00', 'Paid'),
(2, 2400.00, 'Cash', '2026-10-12 18:45:00', 'Paid'),
(3, 1500.00, 'UPI',  '2026-10-17 21:10:00', 'Paid'),
(4, 3000.00, 'Card', '2026-10-25 16:40:00', 'Paid'),
(5, 3600.00, 'UPI',  '2026-11-02 19:30:00', 'Paid'),
(6, 1200.00, 'UPI',  '2026-11-07 20:00:00', 'Refunded'),
(7, 3000.00, 'UPI',  '2026-11-15 18:20:00', 'Paid'),
(8, 1000.00, 'Cash', '2026-11-20 10:00:00', 'Partial'),
(9, 1800.00, 'UPI',  '2026-11-20 11:15:00', 'Partial');

INSERT INTO maintenance (turf_id, staff_id, maintenance_type, maintenance_date, cost, notes) VALUES
(1, 2, 'Grass Cutting',  '2026-10-01', 1500.00, 'Monthly trimming'),
(2, 2, 'Net Repair',     '2026-10-10', 2200.00, 'Replaced torn side net'),
(3, 2, 'Cleaning',       '2026-10-20',  800.00, 'Deep clean after tournament'),
(4, 2, 'Floodlight Fix', '2026-11-01', 4500.00, 'Two LED lamps replaced'),
(1, 2, 'Watering',       '2026-11-10',  600.00, NULL);

INSERT INTO customer_feedback (booking_id, comments, rating) VALUES
(1, 'Great turf quality',          5),
(2, 'Net needs repair',            3),
(3, 'Early morning slot was calm', 4),
(5, 'Floodlights were excellent',  5),
(7, 'Parking is limited',          4);

-- ---------- UPDATE ----------
UPDATE bookings  SET status = 'Confirmed'  WHERE booking_id = 10;
UPDATE customers SET city = 'Chennai', loyalty_points = loyalty_points + 50 WHERE customer_id = 5;
UPDATE customers SET loyalty_points = 120 WHERE customer_id = 1;
UPDATE staff     SET salary = salary + 2000 WHERE role = 'Groundskeeper';
UPDATE bookings  SET status = 'Pending'    WHERE booking_id = 10;

-- ---------- DELETE ----------
INSERT INTO customers (full_name, phone, email, joined_date)
VALUES ('Test User', '+91-90000-00000', 'test@example.com', CURDATE());
DELETE FROM customers WHERE full_name = 'Test User';

-- =====================================================================
-- 6. SELECT KEYWORDS
-- =====================================================================

-- Basic SELECT, DISTINCT, AS
SELECT * FROM turfs;
SELECT DISTINCT sport_type AS sport FROM turfs;
SELECT turf_name AS Turf, price_per_hour AS 'Price/Hour' FROM turfs;

-- WHERE, AND, OR, NOT
SELECT * FROM turfs WHERE sport_type = 'Football' AND price_per_hour > 1500;
SELECT * FROM turfs WHERE sport_type = 'Cricket' OR sport_type = 'Multi';
SELECT * FROM turfs WHERE NOT status = 'Closed';

-- IN, IS NULL, IS NOT NULL
SELECT * FROM bookings  WHERE status IN ('Confirmed', 'Pending');
SELECT * FROM customers WHERE email IS NULL;
SELECT * FROM customers WHERE email IS NOT NULL;

-- BETWEEN
SELECT * FROM bookings WHERE booking_date BETWEEN '2026-11-01' AND '2026-11-30';
SELECT * FROM turfs    WHERE price_per_hour BETWEEN 1000 AND 1500;

-- LIKE
SELECT * FROM customers WHERE full_name LIKE 'A%';
SELECT * FROM customers WHERE email LIKE '%gmail.com';
SELECT * FROM turfs     WHERE location LIKE '%Chennai%';

-- EXISTS / NOT EXISTS
SELECT c.full_name
FROM customers c
WHERE EXISTS (SELECT 1 FROM bookings b WHERE b.customer_id = c.customer_id);

SELECT t.turf_name
FROM turfs t
WHERE NOT EXISTS (SELECT 1 FROM maintenance m WHERE m.turf_id = t.turf_id);

-- =====================================================================
-- 7. SORTING AND GROUPING
-- =====================================================================
SELECT turf_name, price_per_hour FROM turfs ORDER BY price_per_hour DESC;
SELECT full_name, joined_date    FROM customers ORDER BY joined_date ASC;

SELECT turf_id, COUNT(*) AS total_bookings, SUM(total_amount) AS revenue
FROM bookings
GROUP BY turf_id
HAVING COUNT(*) >= 2
ORDER BY revenue DESC;

SELECT * FROM bookings ORDER BY total_amount DESC LIMIT 3;

-- =====================================================================
-- 8. JOINS
-- =====================================================================

-- INNER JOIN / JOIN ... ON
SELECT b.booking_id, c.full_name, t.turf_name, b.booking_date, b.total_amount
FROM bookings b
INNER JOIN customers c ON b.customer_id = c.customer_id
JOIN turfs t           ON b.turf_id     = t.turf_id
ORDER BY b.booking_date;

-- LEFT JOIN : all turfs, even those without maintenance
SELECT t.turf_name, m.maintenance_type, m.maintenance_date
FROM turfs t
LEFT JOIN maintenance m ON t.turf_id = m.turf_id;

-- LEFT JOIN : customers who never booked
SELECT c.full_name
FROM customers c
LEFT JOIN bookings b ON c.customer_id = b.customer_id
WHERE b.booking_id IS NULL;

-- RIGHT JOIN : all bookings, even without payment
SELECT p.payment_id, b.booking_id, b.status, p.payment_status
FROM payments p
RIGHT JOIN bookings b ON p.booking_id = b.booking_id;

-- Multi-table JOIN : booking + customer + turf + payment
SELECT b.booking_id, c.full_name, t.turf_name, b.total_amount,
       p.amount AS paid, p.payment_mode, p.payment_status
FROM bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN turfs t     ON b.turf_id     = t.turf_id
LEFT JOIN payments p ON b.booking_id = p.booking_id;

-- =====================================================================
-- 9. SET OPERATORS
-- =====================================================================
SELECT full_name AS person_name, 'Customer' AS person_type FROM customers
UNION
SELECT staff_name, 'Staff' FROM staff;

SELECT DATE(payment_date) AS activity_date, 'Payment' AS activity FROM payments
UNION ALL
SELECT booking_date, 'Booking' FROM bookings
ORDER BY activity_date;

-- =====================================================================
-- 10. AGGREGATE FUNCTIONS
-- =====================================================================
SELECT COUNT(*)            AS total_bookings,
       SUM(total_amount)   AS total_revenue,
       AVG(total_amount)   AS avg_booking_value,
       MIN(total_amount)   AS smallest_booking,
       MAX(total_amount)   AS largest_booking
FROM bookings
WHERE status <> 'Cancelled';

SELECT t.turf_name, COUNT(b.booking_id) AS bookings, SUM(b.total_amount) AS revenue
FROM turfs t
LEFT JOIN bookings b ON t.turf_id = b.turf_id AND b.status <> 'Cancelled'
GROUP BY t.turf_name;

-- =====================================================================
-- 11. STRING FUNCTIONS
-- =====================================================================
SELECT CONCAT(full_name, ' (', city, ')')            AS customer_label,
       UPPER(full_name)                              AS name_upper,
       LOWER(email)                                  AS email_lower,
       TRIM(CONCAT('   ', full_name, '   '))         AS trimmed_name,
       LENGTH(full_name)                             AS name_length,
       SUBSTRING(full_name, 1, 3)                    AS first_3_letters,
       SUBSTRING_INDEX(email, '@', 1)                AS email_username,
       SUBSTRING_INDEX(email, '@', -1)               AS email_domain,
       RIGHT(phone, 4)                               AS last_4_digits,
       REGEXP_REPLACE(phone, '[^0-9]', '')           AS phone_digits_only
FROM customers
WHERE email IS NOT NULL;

-- =====================================================================
-- 12. DATE AND TIME FUNCTIONS
-- =====================================================================
SELECT NOW() AS current_datetime, CURDATE() AS today, CURTIME() AS current_time_now;

SELECT booking_id,
       booking_date,
       DATE_FORMAT(booking_date, '%d-%b-%Y')    AS formatted_date,
       DAYNAME(booking_date)                    AS day_name,
       DAYOFWEEK(booking_date)                  AS day_number,
       MONTH(booking_date)                      AS month_no,
       MONTHNAME(booking_date)                  AS month_name,
       YEAR(booking_date)                       AS year_no,
       QUARTER(booking_date)                    AS quarter_no,
       DATEDIFF('2026-12-31', booking_date)     AS days_to_year_end,
       TIMESTAMPDIFF(MINUTE,
           CONCAT(booking_date, ' ', start_time),
           CONCAT(booking_date, ' ', end_time)) / 60 AS duration_hours
FROM bookings;

SELECT STR_TO_DATE('05-10-2026', '%d-%m-%Y') AS converted_date;

SELECT full_name, joined_date,
       TIMESTAMPDIFF(MONTH, joined_date, CURDATE()) AS months_since_joining
FROM customers;

-- Weekend bookings (Saturday = 7, Sunday = 1)
SELECT booking_id, booking_date, DAYNAME(booking_date) AS day_name
FROM bookings
WHERE DAYOFWEEK(booking_date) IN (1, 7);

-- =====================================================================
-- 13. MATHEMATICAL FUNCTIONS
-- =====================================================================
SELECT booking_id,
       total_amount,
       ABS(total_amount - 3000)       AS diff_from_3000,
       ROUND(total_amount * 0.18, 2)  AS gst_18_percent,
       CEIL(total_amount / 1000)      AS thousand_blocks_up,
       FLOOR(total_amount / 1000)     AS thousand_blocks_down,
       MOD(hours, 2)                  AS odd_even_hours,
       POWER(hours, 2)                AS hours_squared,
       ROUND(SQRT(total_amount), 2)   AS sqrt_amount
FROM bookings;

-- =====================================================================
-- 14. NULL HANDLING FUNCTIONS
-- =====================================================================
SELECT full_name,
       COALESCE(email, 'Not Provided')        AS email_or_default,
       COALESCE(NULLIF(email, ''), 'No Email') AS email_clean
FROM customers;

SELECT maintenance_id, COALESCE(notes, 'No notes') AS notes_display
FROM maintenance;

SELECT booking_id,
       NULLIF(total_amount, 0) AS safe_amount      -- avoids divide-by-zero
FROM bookings;

-- =====================================================================
-- 15. CONDITIONAL KEYWORDS
-- =====================================================================
SELECT booking_id, total_amount,
       CASE
           WHEN total_amount >= 3500 THEN 'Premium'
           WHEN total_amount >= 2000 THEN 'Standard'
           ELSE 'Basic'
       END AS booking_category,
       IF(status = 'Completed', 'Yes', 'No') AS is_completed
FROM bookings;

SELECT turf_name,
       CASE sport_type
           WHEN 'Football' THEN 'Kick off!'
           WHEN 'Cricket'  THEN 'Play ball!'
           ELSE 'Game on!'
       END AS slogan
FROM turfs;

-- Pivot-style summary using CASE
SELECT turf_id,
       SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed,
       SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
       SUM(CASE WHEN status IN ('Pending','Confirmed') THEN 1 ELSE 0 END) AS upcoming
FROM bookings
GROUP BY turf_id;

-- =====================================================================
-- 16. COMMON TABLE EXPRESSIONS (WITH)
-- =====================================================================
WITH customer_spend AS (
    SELECT customer_id, COUNT(*) AS bookings, SUM(total_amount) AS spent
    FROM bookings
    WHERE status <> 'Cancelled'
    GROUP BY customer_id
)
SELECT c.full_name, cs.bookings, cs.spent
FROM customer_spend cs
JOIN customers c ON c.customer_id = cs.customer_id
ORDER BY cs.spent DESC;

WITH turf_revenue AS (
    SELECT turf_id, SUM(total_amount) AS revenue
    FROM bookings
    WHERE status <> 'Cancelled'
    GROUP BY turf_id
),
turf_cost AS (
    SELECT turf_id, SUM(cost) AS maintenance_cost
    FROM maintenance
    GROUP BY turf_id
)
SELECT t.turf_name,
       COALESCE(r.revenue, 0)          AS revenue,
       COALESCE(c.maintenance_cost, 0) AS maintenance_cost,
       COALESCE(r.revenue, 0) - COALESCE(c.maintenance_cost, 0) AS net_profit
FROM turfs t
LEFT JOIN turf_revenue r ON t.turf_id = r.turf_id
LEFT JOIN turf_cost    c ON t.turf_id = c.turf_id
ORDER BY net_profit DESC;

-- =====================================================================
-- 17. WINDOW FUNCTIONS
-- =====================================================================

-- ROW_NUMBER / RANK / DENSE_RANK
SELECT booking_id, turf_id, total_amount,
       ROW_NUMBER() OVER (ORDER BY total_amount DESC)                      AS row_num,
       RANK()       OVER (ORDER BY total_amount DESC)                      AS rank_no,
       DENSE_RANK() OVER (ORDER BY total_amount DESC)                      AS dense_rank_no,
       RANK()       OVER (PARTITION BY turf_id ORDER BY total_amount DESC) AS rank_in_turf
FROM bookings;

-- Latest booking per turf (ROW_NUMBER + PARTITION BY inside CTE)
WITH ranked AS (
    SELECT b.*,
           ROW_NUMBER() OVER (PARTITION BY turf_id ORDER BY booking_date DESC) AS rn
    FROM bookings b
)
SELECT booking_id, turf_id, booking_date, total_amount
FROM ranked
WHERE rn = 1;

-- LAG / LEAD
SELECT booking_id, turf_id, booking_date, total_amount,
       LAG(total_amount)  OVER (PARTITION BY turf_id ORDER BY booking_date) AS previous_amount,
       LEAD(total_amount) OVER (PARTITION BY turf_id ORDER BY booking_date) AS next_amount,
       total_amount - LAG(total_amount) OVER (PARTITION BY turf_id ORDER BY booking_date) AS change_from_prev
FROM bookings;

-- =====================================================================
-- 18. WINDOW FRAME KEYWORDS
-- =====================================================================

-- Running total per turf
SELECT booking_id, turf_id, booking_date, total_amount,
       SUM(total_amount) OVER (
           PARTITION BY turf_id
           ORDER BY booking_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_revenue
FROM bookings
WHERE status <> 'Cancelled';

-- Moving average of the last 2 bookings
SELECT booking_id, booking_date, total_amount,
       ROUND(AVG(total_amount) OVER (
           ORDER BY booking_date
           ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
       ), 2) AS moving_avg_2
FROM bookings;

-- =====================================================================
-- 19. OTHER KEYWORDS
-- =====================================================================
-- CURRENT_TIMESTAMP used in DEFAULT (see tables) and in DML:
INSERT INTO bookings (turf_id, customer_id, booking_date, start_time, end_time, hours, total_amount, status, created_at)
VALUES (3, 2, '2026-12-10', '06:00:00', '07:00:00', 1, 1000.00, 'Pending', CURRENT_TIMESTAMP);

UPDATE bookings SET created_at = CURRENT_TIMESTAMP WHERE booking_id = 10;

SELECT CURRENT_TIMESTAMP AS right_now;

-- Final check
SELECT 'Turf Management database ready' AS message;