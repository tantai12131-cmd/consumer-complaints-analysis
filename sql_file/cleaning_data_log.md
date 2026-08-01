# DATA CLEANING & TRANSFORMATION LOG

1.
- Thao tác: DROP COLUMN cả 2 cột `Date received.2` và `Date resolved.2`
- Lí do: Xóa Date received.2 và Date resolved.2 vì là Duplicate của Date received.1 và Date resolved.1

2.
- Thao tác: RENAME COLUMN Date received.1 và Date resolved.1 -> thành Date received và Date resolved
- Lí do: RENAME cột, Bỏ số đuôi dư thừa để chuẩn hóa tên cột đồng bộ với toàn bộ schema

3.
- Thao tác: Chuyển đổi kiểu dữ liệu của cột date_received từ Text sang DATE (format: YYYY-MM-DD)
- Lí do: Phục vụ cho việc tính toán khoảng thời gian.

4.
- Thao tác: Kiểm tra và fix lỗi lệch `resolution_time_days` do `date_received`/`date_resolved` bị đảo ngược ngày-tháng (swap mm/dd) độc lập ở từng cột hoặc cả hai cột.
- Lí do: `resolution_time_days` phải luôn bằng `(date_resolved - date_received)`. Phát hiện nhiều dòng lệch do lỗi swap ngày/tháng ở các giá trị ngày ≤12 (ambiguous khi parse).
- Kết quả: Xác định 4 nhóm lỗi (OK/swap received/swap resolved/swap cả hai), fix theo đúng combo khớp với `resolution_time_days` gốc. Sau fix, số dòng lệch giảm về 0 (hoặc còn X dòng KHONG_KHOP không thể tự động fix, đã cô lập riêng).

5.
- Thao tác: Sử dụng `SELECT`+`WHERE year != EXTRACT(year FROM date_received)` để tìm các trường hợp lỗi
- Lí do: KIỂM TRA year
- Kết quả: Không phát hiện trường hợp lỗi

6.
- Thao tác: Tạo cột `TEST` so sánh với `qtr_us_fly` thấy có nhiều trường hợp lỗi, nên đã `UPDATE` cho cột `qtr_us_fly` dựa vào `date_received`.
- Lí do: KIỂM TRA qtr_us_fly + Xử lí 
- Kết quả: Các cột `qtr_us_fly` đã khớp dựa vào `date_received`

7.
- Thao tác: Dùng `TRIM`,`LOWER` + `GROUP BY` và `SELECT DISTINCT` 
- Lí do: KIỂM TRA Inconsistent Formatting của (Company, Product, Issue, Submitted via,Product,submitted_via,timely_response, consumer_disputed)
- Kết quả: Không phát hiện lỗi

8.
- Thao tác: Dùng "COUNT(*)" với "GROUP BY company,.."
- Lí do: KIỂM TRA Duplicate
- Kết quả: Có Duplicate nhưng số lượng ít và dữ liệu không đủ chi tiết nên cho rằng không bị trùng 

9.
- Thao tác: UPDATE 110 dòng có `state IS NULL` và `state_name = '#N/A'` thành `'UNKNOWN'` ở cả 2 cột (đã ALTER `state` từ VARCHAR(5) → VARCHAR(20) trước khi update).
- Lí do: Đây là TH cả 2 cột đều thiếu dữ liệu, không có thông tin để khôi phục hay tra cứu→ không thể giữ NULL/#N/A, cần chuẩn hóa về 1 giá trị thống nhất.
- Kết quả: 110 dòng đã đổi thành 'UNKNOWN', khớp đúng số lượng đã đếm ban đầu.

10.
- Thao tác: `SELECT state, state_name, COUNT(*) OVER()` ở `WHERE state IS NOT NULL and state_name = '#N/A'`
- Lí do: Kiểm tra có trường hợp nào chỉ `'#N/A'` chỉ ở ở `state_name`
- Kết quả: Không có trường hợp nào 

11.
- Thao tác: Tạo Dimension table `dim_state` cho star schema:
  1. Đổi tên `state` → `state_code` (đúng vai trò FK).
  2. `CREATE TABLE dim_state (state_code PK, state_name)`.
  3. `INSERT ... SELECT DISTINCT` từ `consumer_complaints` (loại `#N/A`, `UNKNOWN`) → tự động lấy 51 bang/DC.
  4. `INSERT` thủ công 8 mã lãnh thổ/quân đội (PR, VI, GU, AS, MP, AE, AP, AA) theo chuẩn USPS.
  5. `INSERT` thêm `('UNKNOWN','Unknown')` để đảm bảo referential integrity.
- Lí do: Chuẩn hóa mô hình Fact-Dimension, tách riêng bảng mô tả bang khỏi fact table.
- Kết quả: `dim_state` có 60 dòng (51 bang/DC + 8 lãnh thổ + 1 UNKNOWN).

12.
- Thao tác: Fix lỗi `#N/A` ở `state_name` bằng `dim_state`:
  1. `UPDATE consumer_complaints ... FROM dim_state WHERE state_name = '#N/A'`.
  2. `ALTER TABLE ... DROP COLUMN state_name` (xóa cột dư thừa ở fact table).
  3. `ALTER TABLE ... ADD CONSTRAINT FOREIGN KEY (state_code) REFERENCES dim_state`.
- Lí do: Điền khuyết dữ liệu bị lỗi mapping, đồng thời loại bỏ trùng lặp text và ràng buộc DB tự kiểm tra tính toàn vẹn.
- Kết quả: 47 dòng `#N/A` đã điền đúng, verify = 0 dòng còn `#N/A`. FK constraint tạo thành công, không có `state_code` orphan