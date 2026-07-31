SELECT * FROM consumer_complaints;
SELECT COUNT(*) FROM consumer_complaints;

--XÓA 2 CỘT dư là date_received_2 và date_resolved_2
ALTER TABLE consumer_complaints
DROP COLUMN  date_received_2;

ALTER TABLE consumer_complaints
DROP COLUMN  date_resolved_2;


--ĐỔI TÊN date_received_1 và date_resolved_1 bỏ số đuôi
ALTER TABLE consumer_complaints
RENAME COLUMN date_received_1 TO date_received;

ALTER TABLE consumer_complaints
RENAME COLUMN date_resolved_1 TO date_resolved;


--Đổi kiểu dữ liệu & định dạng của 2 cột trên thành yyyy-mm-dd
ALTER TABLE consumer_complaints
ALTER COLUMN date_received TYPE DATE
USING TO_DATE(date_received, 'MM-DD-YYYY');

ALTER TABLE consumer_complaints
ALTER COLUMN date_resolved TYPE DATE
USING TO_DATE(date_resolved, 'MM-DD-YYYY');

----KIỂM TRA Data Validation
--KIỂM TRA resolution_time_days
--Có 1650 TH resolution_time_days bị SAI
SELECT date_received,date_resolved, resolution_time_days,
    date_resolved - date_received AS TEST
FROM consumer_complaints
WHERE (date_resolved - date_received) != resolution_time_days;

--GIẢI QUYẾT 1650 TH resolution_time_days bị SAI 
BEGIN;

WITH candidates AS (
  SELECT
    id,
    date_received AS dr_orig,
    date_resolved AS ds_orig,
    resolution_time_days,
    CASE WHEN EXTRACT(DAY FROM date_received) <= 12
         THEN MAKE_DATE(EXTRACT(YEAR FROM date_received)::int,
                         EXTRACT(DAY FROM date_received)::int,
                         EXTRACT(MONTH FROM date_received)::int)
         ELSE NULL END AS dr_swap,
    CASE WHEN EXTRACT(DAY FROM date_resolved) <= 12
         THEN MAKE_DATE(EXTRACT(YEAR FROM date_resolved)::int,
                         EXTRACT(DAY FROM date_resolved)::int,
                         EXTRACT(MONTH FROM date_resolved)::int)
         ELSE NULL END AS ds_swap
  FROM consumer_complaints
),
fixed AS (
  SELECT
    id,
    CASE
      WHEN ds_orig - dr_orig = resolution_time_days THEN dr_orig
      WHEN dr_swap IS NOT NULL AND ds_orig - dr_swap = resolution_time_days THEN dr_swap
      WHEN ds_swap IS NOT NULL AND ds_swap - dr_orig = resolution_time_days THEN dr_orig
      WHEN dr_swap IS NOT NULL AND ds_swap IS NOT NULL AND ds_swap - dr_swap = resolution_time_days THEN dr_swap
      ELSE dr_orig  -- không khớp combo nào -> giữ nguyên, xử lý riêng sau
    END AS new_dr,
    CASE
      WHEN ds_orig - dr_orig = resolution_time_days THEN ds_orig
      WHEN dr_swap IS NOT NULL AND ds_orig - dr_swap = resolution_time_days THEN ds_orig
      WHEN ds_swap IS NOT NULL AND ds_swap - dr_orig = resolution_time_days THEN ds_swap
      WHEN dr_swap IS NOT NULL AND ds_swap IS NOT NULL AND ds_swap - dr_swap = resolution_time_days THEN ds_swap
      ELSE ds_orig
    END AS new_ds
  FROM candidates
)
UPDATE consumer_complaints cc
SET date_received = f.new_dr,
    date_resolved = f.new_ds
FROM fixed f
WHERE cc.id = f.id
  AND (cc.date_received <> f.new_dr OR cc.date_resolved <> f.new_ds);

SELECT date_received,date_resolved, resolution_time_days,
    date_resolved - date_received AS TEST
FROM consumer_complaints
WHERE (date_resolved - date_received) != resolution_time_days;

SELECT *,
    date_resolved - date_received AS TEST
FROM consumer_complaints;

COMMIT;

--KIỂM TRA year
-- Có 0 TH 
SELECT id, date_resolved,year,
    EXTRACT(year FROM  date_received)
FROM consumer_complaints
WHERE year != EXTRACT(year FROM  date_received);

--KIỂM TRA qtr_us_fly
--Có 2551 Trường hợp bị lệch.
WITH TEST_TABLE AS(
SELECT id, date_received, qtr_us_fly,
    CASE 
        WHEN EXTRACT(MONTH FROM date_received) IN (1,2,3) THEN 'Q1'
        WHEN EXTRACT(MONTH FROM date_received) IN (4,5,6) THEN 'Q2'
        WHEN EXTRACT(MONTH FROM date_received) IN (7,8,9) THEN 'Q3'
        WHEN EXTRACT(MONTH FROM date_received) IN (10,11,12) THEN 'Q4'
    END AS TEST
FROM consumer_complaints
)
SELECT id, date_received, qtr_us_fly, TEST
FROM TEST_TABLE
WHERE qtr_us_fly != TEST;

--Xử lí 2551 Trường hợp qtr_us_fly bị sai
BEGIN;
UPDATE consumer_complaints
SET  qtr_us_fly = CASE 
        WHEN EXTRACT(MONTH FROM date_received) IN (1,2,3) THEN 'Q1'
        WHEN EXTRACT(MONTH FROM date_received) IN (4,5,6) THEN 'Q2'
        WHEN EXTRACT(MONTH FROM date_received) IN (7,8,9) THEN 'Q3'
        WHEN EXTRACT(MONTH FROM date_received) IN (10,11,12) THEN 'Q4'
    END ;


SELECT id, date_resolved, qtr_us_fly
FROM consumer_complaints;

COMMIT;


----KIỂM TRA String Normalization
--Kiểm tra company
SELECT LOWER(TRIM(company)),
       COUNT(DISTINCT company) AS so_bien_the,
       ARRAY_AGG(DISTINCT company) AS cac_bien_the
FROM consumer_complaints
GROUP BY LOWER(TRIM(company))
HAVING COUNT(DISTINCT company) > 1
ORDER BY so_bien_the DESC;

--Kiểm tra issue
SELECT LOWER(TRIM(issue)) , 
       COUNT(DISTINCT issue) AS so_bien_the,
       ARRAY_AGG(DISTINCT issue) AS cac_bien_the
FROM consumer_complaints
GROUP BY LOWER(TRIM(issue))
HAVING COUNT(DISTINCT issue) > 1
ORDER BY so_bien_the DESC;

--Kiểm tra (Product,submitted_via,timely_response, consumer_disputed)
SELECT DISTINCT consumer_disputed
FROM consumer_complaints;



--KIỂM TRA Duplicate
--Có 53 TH bị trùng 
SELECT company, product, issue, date_received, state, COUNT(*) AS so_lan_trung
FROM consumer_complaints
GROUP BY company, product, issue, date_received, state
HAVING COUNT(*) > 1
ORDER BY so_lan_trung DESC;


----CHECK NULL 
SELECT * 
FROM consumer_complaints t 
WHERE NOT (t IS NOT NULL);

--NULL Ở state  VÀ #N/A ở state_name
---CÓ 110 TH
SELECT state, state_name, COUNT(*) OVER()
FROM consumer_complaints
WHERE state IS NULL and state_name = '#N/A';

ALTER TABLE consumer_complaints
ALTER COLUMN state TYPE VARCHAR(20);

BEGIN;

UPDATE consumer_complaints
SET state = 'UNKNOWN' , state_name = 'UNKNOWN'
WHERE state IS NULL and state_name = '#N/A';

SELECT state, state_name, COUNT(*) OVER()
FROM consumer_complaints
WHERE state = 'UNKNOWN';

COMMIT;

--chỉ NULL Ở state 
-- KHÔNG CÓ TH nào 
SELECT state, state_name, COUNT(*) OVER()
FROM consumer_complaints
WHERE state IS NULL and state_name != '#N/A';

--chỉ #N/A ở state_name
--Có 47 TH
SELECT state, state_name, COUNT(*) OVER()
FROM consumer_complaints
WHERE state IS NOT NULL and state_name = '#N/A';


--Tạo Dimension table `dim_state` cho star schema
ALTER TABLE consumer_complaints
RENAME COLUMN state TO state_code;

CREATE TABLE dim_state (
    state_code VARCHAR(10) PRIMARY KEY,
    state_name VARCHAR(50) NOT NULL
);

INSERT INTO dim_state (state_code, state_name)
SELECT DISTINCT state_code, state_name
FROM consumer_complaints
WHERE state_name <> '#N/A' AND state_name <> 'UNKNOWN'  AND state_name IS NOT NULL  
ORDER BY state_code ASC;

INSERT INTO dim_state (state_code, state_name) 
VALUES ('UNKNOWN', 'Unknown');

INSERT INTO dim_state (state_code, state_name) 
VALUES
('PR','Puerto Rico'),('VI','U.S. Virgin Islands'),('GU','Guam'),
('AS','American Samoa'),('MP','Northern Mariana Islands'),
('AE','Armed Forces Europe'),('AP','Armed Forces Pacific'),
('AA','Armed Forces Americas');

--Fix lỗi `#N/A` ở `state_name` bằng `dim_state`:
BEGIN;

UPDATE consumer_complaints cc
SET state_name = ds.state_name
FROM dim_state ds
WHERE cc.state_code = ds.state_code
  AND cc.state_name = '#N/A';

SELECT COUNT(*) FROM consumer_complaints WHERE state_name = '#N/A';

COMMIT; 
 
ALTER TABLE consumer_complaints
DROP COLUMN state_name;

ALTER TABLE consumer_complaints
ADD CONSTRAINT fk_state_code
FOREIGN KEY (state_code) REFERENCES dim_state(state_code);



---
----- BẢNG ------

SELECT *
FROM consumer_complaints cc 









