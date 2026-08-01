--'dim_state' đã tạo trước đó rồi
--Tạo Dimension table `dim_date` cho star schema
CREATE TABLE dim_date (
    full_date       DATE PRIMARY KEY,
    year            INT  NOT NULL,
    quarter         VARCHAR(5) NOT NULL,
    month           INT NOT NULL,
    month_name      TEXT NOT NULL,
    day             INT NOT NULL,
    day_name        TEXT NOT NULL,
    is_weekend      BOOLEAN NOT NULL,
    week_of_year    INT NOT NULL
);


WITH list_date AS (
    SELECT date_received AS full_d
    FROM consumer_complaints
    WHERE date_received IS NOT NULL
    UNION
    SELECT date_resolved
    FROM consumer_complaints
    WHERE date_resolved IS NOT NULL
)
INSERT INTO dim_date (full_date,year,quarter,month,month_name,day,day_name,is_weekend,week_of_year)
SELECT 
    full_d AS full_date, 
    EXTRACT(YEAR FROM full_d)::INT AS year,
    CASE 
        WHEN EXTRACT(MONTH FROM full_d) IN (1,2,3) THEN 'Q1'
        WHEN EXTRACT(MONTH FROM full_d) IN (4,5,6) THEN 'Q2'
        WHEN EXTRACT(MONTH FROM full_d) IN (7,8,9) THEN 'Q3'
        WHEN EXTRACT(MONTH FROM full_d) IN (10,11,12) THEN 'Q4'
    END AS quarter,
    EXTRACT(MONTH FROM full_d)::INT AS month,
    INITCAP(TRIM(TO_CHAR(full_d, 'MONTH'))) AS month_name,
    EXTRACT(day FROM full_d) AS day,
    INITCAP (TRIM(TO_CHAR(full_d, 'DAY' ))) AS day_name,
    EXTRACT(DOW FROM full_d) IN (0,6) AS is_weekend,
    EXTRACT(WEEK FROM full_d)::INT AS week_of_year
FROM  list_date
ORDER BY full_d;

SELECT * FROM dim_date



--Tạo Dimension table `dim_company` cho star schema
CREATE TABLE dim_company (
    company_id TEXT PRIMARY KEY,
    company  VARCHAR(100) NOT NULL
);

INSERT INTO dim_company (company_id,company)
SELECT DISTINCT 
    CONCAT('C', DENSE_RANK() OVER (ORDER BY TRIM(company))) AS company_id,
    TRIM(company) AS company
FROM consumer_complaints
ORDER BY TRIM(company);

SELECT * FROM dim_company

--Tạo Dimension table `dim_product` cho star schema
CREATE TABLE dim_product (
    product_id TEXT PRIMARY KEY,
    product    VARCHAR(50)
);

INSERT INTO dim_product (product_id,product)
SELECT DISTINCT 
    CONCAT('P', DENSE_RANK() OVER (ORDER BY TRIM(product))) AS product_id,
    TRIM(product) AS product
FROM consumer_complaints
ORDER BY TRIM(product);
 
 SELECT * FROM dim_product


--Tạo Dimension table `dim_issue` cho star schema
CREATE TABLE dim_issue (
      issue_id TEXT PRIMARY KEY,
      issue    VARCHAR(100)
);

INSERT INTO dim_issue (issue_id,issue)
SELECT DISTINCT 
    CONCAT('I', DENSE_RANK() OVER (ORDER BY TRIM(issue))) AS issue_id,
    TRIM(issue) AS issue
FROM consumer_complaints
ORDER BY TRIM(issue);

 SELECT * FROM dim_issue


--Tạo Dimension table `dim_channel` cho star schema
CREATE TABLE dim_channel (
        channel_id TEXT PRIMARY KEY,
        channel       VARCHAR(20)
);

INSERT INTO dim_channel (channel_id,channel)
SELECT DISTINCT 
    CONCAT('CN', DENSE_RANK() OVER (ORDER BY TRIM(submitted_via))) AS channel_id,
    TRIM(submitted_via) AS channel
FROM consumer_complaints
ORDER BY TRIM(submitted_via);

SELECT * FROM dim_channel

--Tạo Dimension table `dim_response_flag` cho star schema
CREATE TABLE dim_response_flag (
    response_flag_id TEXT PRIMARY KEY,
    timely_response VARCHAR(10),
    consumer_disputed VARCHAR(10)
);

INSERT INTO dim_response_flag (response_flag_id,timely_response, consumer_disputed)
WITH List_Response AS (
SELECT DISTINCT 
    timely_response, 
    consumer_disputed
FROM consumer_complaints
)
SELECT  
    CONCAT('R', DENSE_RANK() OVER(ORDER BY timely_response,consumer_disputed)) AS response_flag_key,
    timely_response, 
    consumer_disputed
FROM List_Response

SELECT * FROM dim_response_flag

--ĐỔI TÊN submitted_via thành channel
ALTER TABLE consumer_complaints
RENAME COLUMN submitted_via TO channel;

--KIỂM TRA FK
SELECT 
    cc.id,
    c.company_id,
    p.product_id,
    i.issue_id,
    cc.state_code,
    cn.channel_id,
    cc.date_received,
    cc.date_resolved,
    cc.resolution_time_days,
    r.response_flag_id
FROM consumer_complaints cc 
LEFT JOIN dim_company c ON cc.company = c.company
LEFT JOIN dim_product p ON cc.product = p.product
LEFT JOIN dim_issue i ON cc.issue = i.issue
LEFT JOIN dim_state s ON cc.state_code = s.state_code
LEFT JOIN dim_channel cn ON cc.channel = cn.channel
LEFT JOIN dim_date dr ON cc.date_received = dr.full_date
LEFT JOIN dim_date ds ON cc.date_resolved = ds.full_date
LEFT JOIN dim_response_flag r ON cc.timely_response =r.timely_response
    AND cc.consumer_disputed = r.consumer_disputed
ORDER BY cc.id

----THAO TÁC TRÊN `consumer_complaints` (fact_table)

-- Thêm các cột id các dim tương ứng vào `consumer_complaints`
ALTER TABLE consumer_complaints ADD COLUMN company_id TEXT;
ALTER TABLE consumer_complaints ADD COLUMN product_id TEXT;
ALTER TABLE consumer_complaints ADD COLUMN issue_id TEXT;
ALTER TABLE consumer_complaints ADD COLUMN channel_id TEXT;
ALTER TABLE consumer_complaints ADD COLUMN response_flag_id TEXT;


--UPDATE DỮ LIỆU CÁC CỘT
UPDATE consumer_complaints cc
SET 
    company_id          = c.company_id,
    product_id          = p.product_id,
    issue_id            = i.issue_id,
    channel_id          = cn.channel_id,
    response_flag_id    = r.response_flag_id 
FROM 
    dim_company c,
    dim_product p,
    dim_issue i,
    dim_channel cn,
    dim_response_flag r
WHERE 
    cc.company = c.company
AND cc.product = p.product
AND cc.issue = i.issue
AND cc.channel = cn.channel
AND cc.timely_response =r.timely_response
AND cc.consumer_disputed = r.consumer_disputed;

SELECT *
FROM consumer_complaints cc 
WHERE NOT (cc IS NOT NULL)


--DROP CÁC CỘT KHÔNG CẦN THIẾT 
ALTER TABLE consumer_complaints DROP COLUMN company;
ALTER TABLE consumer_complaints DROP COLUMN product;
ALTER TABLE consumer_complaints DROP COLUMN issue;
ALTER TABLE consumer_complaints DROP COLUMN channel;
ALTER TABLE consumer_complaints DROP COLUMN timely_response;
ALTER TABLE consumer_complaints DROP COLUMN consumer_disputed;
ALTER TABLE consumer_complaints DROP COLUMN year;
ALTER TABLE consumer_complaints DROP COLUMN qtr_us_fly;


--TẠO FK cho `consumer_complaints`
BEGIN;

ALTER TABLE consumer_complaints
ADD CONSTRAINT fk_company_id
FOREIGN KEY (company_id) REFERENCES dim_company(company_id);

ALTER TABLE consumer_complaints
ADD CONSTRAINT fk_product_id
FOREIGN KEY (product_id) REFERENCES dim_product(product_id);

ALTER TABLE consumer_complaints
ADD CONSTRAINT fk_issue_id
FOREIGN KEY (issue_id) REFERENCES dim_issue(issue_id);

ALTER TABLE consumer_complaints
ADD CONSTRAINT fk_channel_id
FOREIGN KEY (channel_id) REFERENCES dim_channel(channel_id);

ALTER TABLE consumer_complaints
ADD CONSTRAINT fk_response_flag_id
FOREIGN KEY (response_flag_id) REFERENCES dim_response_flag(response_flag_id);

ALTER TABLE consumer_complaints
ADD CONSTRAINT fk_date_received
FOREIGN KEY (date_received) REFERENCES dim_date(full_date);

ALTER TABLE consumer_complaints
ADD CONSTRAINT fk_date_resolved
FOREIGN KEY (date_resolved) REFERENCES dim_date(full_date);

-- kiểm tra toàn bộ constraint đã tạo trên fact table
SELECT conname, conrelid::regclass, confrelid::regclass
FROM pg_constraint
WHERE conrelid = 'consumer_complaints'::regclass AND contype = 'f';

COMMIT;


-- TẠO VIEW , CHO DỄ NHÌN
CREATE VIEW consumer_complaints_ordered AS
SELECT 
    id, 
    company_id, 
    product_id,
    issue_id,
    state_code,
    channel_id,
    date_received,
    date_resolved, 
    resolution_time_days,
    response_flag_id    
FROM consumer_complaints;

SELECT *
FROM  consumer_complaints_ordered



----- BẢNG ------
SELECT *
FROM consumer_complaints cc

SELECT * FROM dim_company 
SELECT * FROM dim_product 
SELECT * FROM dim_issue 
SELECT * FROM dim_state;
SELECT * FROM dim_channel 
SELECT * FROM dim_date ;
SELECT * FROM dim_response_flag 