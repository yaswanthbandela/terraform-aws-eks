CREATE DATABASE IF NOT EXISTS transactions;

CREATE USER IF NOT EXISTS 'expense'@'%' IDENTIFIED BY 'ExpenseApp@1';
GRANT ALL ON transactions.* TO 'expense'@'%';
FLUSH PRIVILEGES;

