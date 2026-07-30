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
ROLLBACK;


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























