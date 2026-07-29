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



SELECT * FROM consumer_complaints

--KIỂM TRA Duplicate
SELECT company, product, issue, date_received, state, COUNT(*) AS so_lan_trung
FROM consumer_complaints
GROUP BY company, product, issue, date_received, state
HAVING COUNT(*) > 1
ORDER BY so_lan_trung DESC;




--CHECK NULL 

--NULL Ở state 



--#N/A ở state_name
























