# DATA CLEANING & TRANSFORMATION LOG


1.
-Thao tác: DROP COLUMN cả 2 cột `Date received.2` và  `Date resolved.2`
-Lí do: Date received.2 và  Date resolved.2 là Duplicate của Date received.1 và  Date resolved.1


2.
-Thao tác: RENAME COLUMN Date received.1 và  Date resolved.1 -> thành Date received và  Date resolved
-Lí do: Bỏ số đuôi dư thừa để chuẩn hóa tên cột đồng bộ với toàn bộ schema


3.
-Thao tác: Chuyển đổi kiểu dữ liệu của cột date_received từ Text sang DATE (format: YYYY-MM-DD)
-Lí do: Phục vụ cho việc tính toán khoảng thời gian.
4.
-Thao tác: Dùng "COUNT(*)" với "GROUP BY company,.."
-Lí do: KIỂM TRA Duplicate
-Kết quả: Có Duplicate nhưng số lượng ít và dữ liệu không đủ chi tiết nên cho rằng không bị trùng 
5.
-Thao tác: UPDATE 110 dòng có `state IS NULL` và `state_name = '#N/A'` thành `'UNKNOWN'` ở cả 2 cột (đã ALTER `state` từ VARCHAR(5) → VARCHAR(20) trước khi update).
-Lí do: Đây là TH cả 2 cột đều thiếu dữ liệu, không có thông tin để khôi phục hay tra cứu→ không thể giữ NULL/#N/A, cần chuẩn hóa về 1 giá trị thống nhất.
-Kết quả: 110 dòng đã đổi thành 'UNKNOWN', khớp đúng số lượng đã đếm ban đầu.
6.
-Thao tác: `SELECT state, state_name, COUNT(*) OVER()`  ở `WHERE state IS NOT NULL and state_name = '#N/A'`
-Lí do: Kiểm tra có trường hợp nào chỉ `'#N/A'` chỉ ở  ở `state_name`
-Kết quả: Không có trường hợp nào 
7.
-Thao tác: Tạo Dimension table `dim_state` cho star schema:
  1. Đổi tên `state` → `state_code` (đúng vai trò FK).
  2. `CREATE TABLE dim_state (state_code PK, state_name)`.
  3. `INSERT ... SELECT DISTINCT` từ `consumer_complaints` (loại `#N/A`, `UNKNOWN`) → tự động lấy 51 bang/DC.
  4. `INSERT` thủ công 8 mã lãnh thổ/quân đội (PR, VI, GU, AS, MP, AE, AP, AA) theo chuẩn USPS.
  5. `INSERT` thêm `('UNKNOWN','Unknown')` để đảm bảo referential integrity.
-Lí do: Chuẩn hóa mô hình Fact-Dimension, tách riêng bảng mô tả bang khỏi fact table.
-Kết quả: `dim_state` có 60 dòng (51 bang/DC + 8 lãnh thổ + 1 UNKNOWN).

8.
-Thao tác: Fix lỗi `#N/A` ở `state_name` bằng `dim_state`:
  1. `UPDATE consumer_complaints ... FROM dim_state WHERE state_name = '#N/A'`.
  2. `ALTER TABLE ... DROP COLUMN state_name` (xóa cột dư thừa ở fact table).
  3. `ALTER TABLE ... ADD CONSTRAINT FOREIGN KEY (state_code) REFERENCES dim_state`.
-Lí do: Điền khuyết dữ liệu bị lỗi mapping, đồng thời loại bỏ trùng lặp text và ràng buộc DB tự kiểm tra tính toàn vẹn.
-Kết quả: 47 dòng `#N/A` đã điền đúng, verify = 0 dòng còn `#N/A`. FK constraint tạo thành công, không có `state_code` orphan.

9.
-Thao tác:
-Lí do:
-Kết quả:
10.
-Thao tác:
-Lí do:
-Kết quả:
11.
-Thao tác:
-Lí do:
-Kết quả:
12.
-Thao tác:
-Lí do:
-Kết quả:
13.
-Thao tác:
-Lí do:
-Kết quả:
14.
-Thao tác:
-Lí do:
-Kết quả:
15.
-Thao tác:
-Lí do:
-Kết quả:
16.
-Thao tác:
-Lí do:
-Kết quả:
17.
-Thao tác:
-Lí do:
-Kết quả:
18.
-Thao tác:
-Lí do:
-Kết quả:
19.
-Thao tác:
-Lí do:
-Kết quả:
20.
-Thao tác:
-Lí do:
-Kết quả:
21.
-Thao tác:
-Lí do:
-Kết quả:
22.
-Thao tác:
-Lí do:
-Kết quả:
23.
-Thao tác:
-Lí do:
-Kết quả:
24.
-Thao tác:
-Lí do:
-Kết quả:
25.
-Thao tác:
-Lí do:
-Kết quả:
26.
-Thao tác:
-Lí do:
-Kết quả:
27.
-Thao tác:
-Lí do:
-Kết quả:
28.
-Thao tác:
-Lí do:
-Kết quả:
29.
-Thao tác:
-Lí do:
-Kết quả:
30.
-Thao tác:
-Lí do:
-Kết quả:
31.
-Thao tác:
-Lí do:
-Kết quả:
32.
-Thao tác:
-Lí do:
-Kết quả:
33.
-Thao tác:
-Lí do:
-Kết quả:
34.
-Thao tác:
-Lí do:
-Kết quả:
35.
-Thao tác:
-Lí do:
-Kết quả:
36.
-Thao tác:
-Lí do:
-Kết quả:
37.
-Thao tác:
-Lí do:
-Kết quả:
38.
-Thao tác:
-Lí do:
-Kết quả:
39.
-Thao tác:
-Lí do:
-Kết quả:
40.
-Thao tác:
-Lí do:
-Kết quả:
41.
-Thao tác:
-Lí do:
-Kết quả:
42.
-Thao tác:
-Lí do:
-Kết quả:
43.
-Thao tác:
-Lí do:
-Kết quả:
44.
-Thao tác:
-Lí do:
-Kết quả:
45.
-Thao tác:
-Lí do:
-Kết quả:
46.
-Thao tác:
-Lí do:
-Kết quả:
47.
-Thao tác:
-Lí do:
-Kết quả:
48.
-Thao tác:
-Lí do:
-Kết quả:
49.
-Thao tác:
-Lí do:
-Kết quả:
50.
-Thao tác:
-Lí do:
-Kết quả:
51.
-Thao tác:
-Lí do:
-Kết quả:
52.
-Thao tác:
-Lí do:
-Kết quả:
53.
-Thao tác:
-Lí do:
-Kết quả:
54.
-Thao tác:
-Lí do:
-Kết quả:
55.
-Thao tác:
-Lí do:
-Kết quả:
56.
-Thao tác:
-Lí do:
-Kết quả:
57.
-Thao tác:
-Lí do:
-Kết quả:
58.
-Thao tác:
-Lí do:
-Kết quả:
59.
-Thao tác:
-Lí do:
-Kết quả:
60.
-Thao tác:
-Lí do:
-Kết quả:
61.
-Thao tác:
-Lí do:
-Kết quả:
62.
-Thao tác:
-Lí do:
-Kết quả:
63.
-Thao tác:
-Lí do:
-Kết quả:
64.
-Thao tác:
-Lí do:
-Kết quả:
65.
-Thao tác:
-Lí do:
-Kết quả:
66.
-Thao tác:
-Lí do:
-Kết quả:
67.
-Thao tác:
-Lí do:
-Kết quả:
68.
-Thao tác:
-Lí do:
-Kết quả:
69.
-Thao tác:
-Lí do:
-Kết quả:
70.
-Thao tác:
-Lí do:
-Kết quả:
71.
-Thao tác:
-Lí do:
-Kết quả:
72.
-Thao tác:
-Lí do:
-Kết quả:
73.
-Thao tác:
-Lí do:
-Kết quả:
74.
-Thao tác:
-Lí do:
-Kết quả:
75.
-Thao tác:
-Lí do:
-Kết quả:
76.
-Thao tác:
-Lí do:
-Kết quả:
77.
-Thao tác:
-Lí do:
-Kết quả:
78.
-Thao tác:
-Lí do:
-Kết quả:
79.
-Thao tác:
-Lí do:
-Kết quả:
80.
-Thao tác:
-Lí do:
-Kết quả:
81.
-Thao tác:
-Lí do:
-Kết quả:
82.
-Thao tác:
-Lí do:
-Kết quả:
83.
-Thao tác:
-Lí do:
-Kết quả:
84.
-Thao tác:
-Lí do:
-Kết quả:
85.
-Thao tác:
-Lí do:
-Kết quả:
86.
-Thao tác:
-Lí do:
-Kết quả:
87.
-Thao tác:
-Lí do:
-Kết quả:
88.
-Thao tác:
-Lí do:
-Kết quả:
89.
-Thao tác:
-Lí do:
-Kết quả:
90.
-Thao tác:
-Lí do:
-Kết quả:
91.
-Thao tác:
-Lí do:
-Kết quả:
92.
-Thao tác:
-Lí do:
-Kết quả:
93.
-Thao tác:
-Lí do:
-Kết quả:
94.
-Thao tác:
-Lí do:
-Kết quả:
95.
-Thao tác:
-Lí do:
-Kết quả:
96.
-Thao tác:
-Lí do:
-Kết quả:
97.
-Thao tác:
-Lí do:
-Kết quả:
98.
-Thao tác:
-Lí do:
-Kết quả:
99.
-Thao tác:
-Lí do:
-Kết quả:
100.
-Thao tác:
-Lí do:
-Kết quả: