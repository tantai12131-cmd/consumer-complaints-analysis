
/* XÓA HẾT CÁI CŨ NẾU LỖI (BỎ QUa)
DROP TABLE IF EXISTS consumer_complaints CASCADE;

*/

CREATE TABLE consumer_complaints (
    id                  INT PRIMARY KEY,
    company             VARCHAR(100),
    product             VARCHAR(50),
    issue               VARCHAR(100),
    state               VARCHAR(5),
    submitted_via       VARCHAR(20),
    date_received_1     VARCHAR(15),   -- giữ dạng text, convert DATE ở bước sau
    date_resolved_1     VARCHAR(15),
    timely_response     VARCHAR(5),
    consumer_disputed   VARCHAR(5),
    state_name          VARCHAR(30),
    date_received_2     VARCHAR(15),   -- cột trùng tên gốc, cần đối chiếu với date_received_1
    date_resolved_2     VARCHAR(15),   -- cột trùng tên gốc, cần đối chiếu với date_resolved_1
    resolution_time_days INT,
    year                INT,
    qtr_us_fly          VARCHAR(5)
);