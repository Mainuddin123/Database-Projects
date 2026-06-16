CREATE DATABASE BankingAnalytics;
USE BankingAnalytics;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    credit_score INT,
    created_at DATETIME
);

CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(20),
    balance_usd DECIMAL(15,2),
    open_date DATE,

    FOREIGN KEY (customer_id)
    REFERENCES Customers(customer_id)
);

CREATE INDEX idx_customer_city
ON Customers(city);

CREATE INDEX idx_credit_score
ON Customers(credit_score);

CREATE INDEX idx_account_customer
ON Accounts(customer_id);

CREATE INDEX idx_account_type
ON Accounts(account_type);

CREATE TABLE Cards (
    card_id INT PRIMARY KEY,
    account_id INT,
    card_type VARCHAR(30),
    expiration_date DATE
);

CREATE TABLE Loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    start_date DATE
);

CREATE TABLE Merchants (
    merchant_id INT PRIMARY KEY,
    merchant_name VARCHAR(100),
    city VARCHAR(50)
);

ALTER TABLE Accounts
ADD CONSTRAINT fk_accounts_customer
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id);

ALTER TABLE Cards
ADD CONSTRAINT fk_cards_account
FOREIGN KEY (account_id)
REFERENCES Accounts(account_id);

ALTER TABLE Loans
ADD CONSTRAINT fk_loans_customer
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id);