-- 手動新增 stores 表的 phone, address, logo 欄位
-- 若 php artisan migrate 無法執行，可於 phpMyAdmin 執行此 SQL

ALTER TABLE `stores`
  ADD COLUMN `phone` VARCHAR(255) NULL AFTER `branch_name`,
  ADD COLUMN `address` VARCHAR(255) NULL AFTER `phone`,
  ADD COLUMN `logo` VARCHAR(255) NULL AFTER `address`;
