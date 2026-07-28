-- ============================================================
-- COFFEE SHOP DATABASE - IMPORT CSV DATA
-- Run AFTER 01_create_tables.sql
-- ============================================================
-- IMPORTANT: Thay 'C:/your/path/to/' bằng đường dẫn thực tế
-- đến folder chứa các file CSV của bạn.
-- Windows dùng dấu / (không phải \)
-- Ví dụ: 'C:/Users/YourName/Desktop/coffee_shop_clean/'
-- ============================================================

COPY consumer_complaints (
    id, company, product, issue, state, submitted_via,
    date_received_1, date_resolved_1, timely_response, consumer_disputed,
    state_name, date_received_2, date_resolved_2,
    resolution_time_days, year, qtr_us_fly
)
FROM 'D:\Project_DA\consumer-complaints-analysis\csv_file\datatset_consumer_complaints.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8', QUOTE '"');


SELECT * FROM consumer_complaints

