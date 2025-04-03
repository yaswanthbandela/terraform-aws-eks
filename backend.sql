CREATE DATABASE IF NOT EXISTS drupal;

CREATE USER IF NOT EXISTS 'expense'@'%' IDENTIFIED BY 'ExpenseApp@1';
GRANT ALL ON drupal.* TO 'expense'@'%';
FLUSH PRIVILEGES;

