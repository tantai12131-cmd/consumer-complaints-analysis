# CREATE STAR SCHEMA LOG

1.
- Tạo Dimension table `dim_date` cho star schema

2.
- Tạo Dimension table `dim_company` cho star schema

3.
- Tạo Dimension table `dim_product` cho star schema

4.
- Tạo Dimension table `dim_issue` cho star schema

5.
- Tạo Dimension table `dim_channel` cho star schema

6.
- Tạo Dimension table `dim_response_flag` cho star schema

7.
- Thao tác: JOIN các bảng `dim_` lại với nhau
- Lí do: KIỂM TRA FK

8.
- Thao tác: RENAME COLUMN `submitted_via` TO `channel`;
- Lí do: Chuẩn hóa tên cột, đồng bộ với schema

9.
- Thao tác: Dùng `ALTER TABLE`+`ADD COLUMN`
- Lí do: Thêm các cột id các dim tương ứng vào `consumer_complaints`

10.
- Thao tác: Dùng UPDATE
- Lí do: UPDATE DỮ LIỆU CÁC CỘT

11.
- Thao tác: Dùng `ALTER TABLE`+`DROP COLUMN`
- Lí do: DROP CÁC CỘT KHÔNG CẦN THIẾT

12.
- Thao tác: Dùng `ALTER TABLE`+`ADD CONSTRAINT`+ `FOREIGN KEY`
- Lí do: TẠO FK cho `consumer_complaints` với các bảng `dim_`
- Kết quả: Nối xong và kiểm tra lại toàn bộ constraint

13.
- Thao tác: Dùng `CREATE VIEW`
- Lí do: TẠO VIEW, CHO DỄ NHÌN