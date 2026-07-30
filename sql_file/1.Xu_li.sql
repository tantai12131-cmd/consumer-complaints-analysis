SELECT * FROM consumer_complaints
SELECT COUNT(*) FROM consumer_complaints

--XÓA 2 CỘT dư là date_received_2 và date_resolved_2
ALTER TABLE consumer_complaints
DROP COLUMN  date_received_2

ALTER TABLE consumer_complaints
DROP COLUMN  date_resolved_2


--ĐỔI TÊN date_received_1 và date_resolved_1 bỏ số đuôi
ALTER TABLE consumer_complaints
RENAME COLUMN date_received_1 TO date_received

ALTER TABLE consumer_complaints
RENAME COLUMN date_resolved_1 TO date_resolved


--Đổi định dạng 2 cột trên thành yyyy-mm-dd
ALTER TABLE consumer_complaints
ALTER COLUMN date_received TYPE DATE
USING TO_DATE(date_received, 'MM-DD-YYYY')

ALTER TABLE consumer_complaints
ALTER COLUMN date_resolved TYPE DATE
USING TO_DATE(date_resolved, 'MM-DD-YYYY')

SELECT date_received, date_resolved FROM consumer_complaints LIMIT 8


--KIỂM TRA Duplicate
SELECT company, product, issue, date_received, state, COUNT(*) AS so_lan_trung
FROM consumer_complaints
GROUP BY company, product, issue, date_received, state
HAVING COUNT(*) > 1
ORDER BY so_lan_trung DESC;


--CHECK NULL 
SELECT * FROM consumer_complaints

--NULL Ở state  VÀ #N/A ở state_name
---CÓ 110 TH
SELECT state, state_name, COUNT(*) OVER()
FROM consumer_complaints
WHERE state IS NULL and state_name = '#N/A'

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
WHERE state IS NULL and state_name != '#N/A'

--chỉ #N/A ở state_name
--Có 47 TH
SELECT state, state_name, COUNT(*) OVER()
FROM consumer_complaints
WHERE state IS NOT NULL and state_name = '#N/A'


--Dimension table `dim_state` cho star schema
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
ORDER BY state_code ASC

INSERT INTO dim_state (state_code, state_name) 
VALUES ('UNKNOWN', 'Unknown')

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



SELECT * FROM dim_state

SELECT *, COUNT(*) over() FROM consumer_complaints cc 
JOIN dim_state ds ON cc.state_code = ds.state_code
WHERE cc.state_code = 'UNKNOWN' AND state_name  = 'Unknown'
 











