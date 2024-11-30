-- Task 1: Total Spending Calculation
-- Calculate the total amount spent by each customer.
WITH CustomerSpending AS (
    SELECT CustomerID, SUM(TransactionAmount) AS TotalSpent
    FROM Transactions
    GROUP BY CustomerID
)
SELECT c.Name, cs.TotalSpent
FROM Customers c
JOIN CustomerSpending cs ON c.CustomerID = cs.CustomerID;

-- Task 2: High Spender Customers
-- List customers who have spent more than 1000 units in total.
WITH HighSpenders AS (
    SELECT CustomerID, SUM(TransactionAmount) AS TotalSpent
    FROM Transactions
    GROUP BY CustomerID
    HAVING SUM(TransactionAmount) > 1000
)
SELECT c.Name, hs.TotalSpent
FROM Customers c
JOIN HighSpenders hs ON c.CustomerID = hs.CustomerID;

-- Task 3: Fraud Suspicion Based on Multiple Transactions in One Day
-- Detect customers who made multiple transactions on the same day, which may indicate potential fraud.
WITH MultipleTransactions AS (
    SELECT CustomerID, DATE(TransactionDate) AS TransactionDay, COUNT(*) AS TransactionCount
    FROM Transactions
    GROUP BY CustomerID, DATE(TransactionDate)
    HAVING COUNT(*) > 1
)
SELECT c.Name, mt.TransactionDay, mt.TransactionCount
FROM Customers c
JOIN MultipleTransactions mt ON c.CustomerID = mt.CustomerID;

-- Task 4: Detect Fraud Based on Large Transactions in a Short Period
-- Identify customers who have made transactions above a certain threshold (e.g., 5000 units) within a short time window.
WITH LargeTransactions AS (
    SELECT CustomerID, TransactionAmount, TransactionDate
    FROM Transactions
    WHERE TransactionAmount > 5000
)
SELECT c.Name, lt.TransactionAmount, lt.TransactionDate
FROM Customers c
JOIN LargeTransactions lt ON c.CustomerID = lt.CustomerID;

-- Task 5: Unusual Transaction Frequency
-- Identify customers who have an unusually high frequency of transactions within a short period.
WITH TransactionFrequency AS (
    SELECT CustomerID, COUNT(*) AS TransactionCount, MAX(TransactionDate) AS LastTransactionDate
    FROM Transactions
    GROUP BY CustomerID
    HAVING COUNT(*) > 5 AND DATEDIFF(CURDATE(), MAX(TransactionDate)) < 30
)
SELECT c.Name, tf.TransactionCount, tf.LastTransactionDate
FROM Customers c
JOIN TransactionFrequency tf ON c.CustomerID = tf.CustomerID;

-- Task 6: High Risk Merchants
-- Identify merchants who have unusually high amounts of fraud transactions.
WITH FraudulentMerchants AS (
    SELECT MerchantID, COUNT(*) AS FraudCount
    FROM Transactions
    WHERE IsFraud = TRUE
    GROUP BY MerchantID
    HAVING COUNT(*) > 3
)
SELECT m.MerchantName, fm.FraudCount
FROM Merchants m
JOIN FraudulentMerchants fm ON m.MerchantID = fm.MerchantID;

-- Task 7: Customers with Suspicious Transaction Patterns
-- Detect customers who have made several high-value transactions to different merchants in a short period.
WITH SuspiciousPatterns AS (
    SELECT CustomerID, COUNT(DISTINCT MerchantID) AS MerchantCount, SUM(TransactionAmount) AS TotalSpent
    FROM Transactions
    WHERE TransactionAmount > 1000
    GROUP BY CustomerID
    HAVING MerchantCount > 2 AND TotalSpent > 5000
)
SELECT c.Name, sp.MerchantCount, sp.TotalSpent
FROM Customers c
JOIN SuspiciousPatterns sp ON c.CustomerID = sp.CustomerID;

-- Task 8: Transaction Amount and Time Correlation for Fraud Detection
-- Investigate the correlation between large transaction amounts and specific times of day for potential fraud.
WITH TimeBasedTransactions AS (
    SELECT CustomerID, TransactionAmount, HOUR(TransactionDate) AS HourOfDay
    FROM Transactions
    WHERE TransactionAmount > 1000
)
SELECT c.Name, tbt.TransactionAmount, tbt.HourOfDay
FROM Customers c
JOIN TimeBasedTransactions tbt ON c.CustomerID = tbt.CustomerID
WHERE tbt.HourOfDay BETWEEN 0 AND 6;

-- Task 9: Fraudulent Transactions in the Last Week
-- List all fraudulent transactions in the past week, along with customer and merchant details.
WITH RecentFraud AS (
    SELECT t.TransactionID, t.CustomerID, t.MerchantID, t.TransactionAmount, t.TransactionDate
    FROM Transactions t
    WHERE t.IsFraud = TRUE AND t.TransactionDate >= CURDATE() - INTERVAL 7 DAY
)
SELECT c.Name AS CustomerName, m.MerchantName, rf.TransactionAmount, rf.TransactionDate
FROM RecentFraud rf
JOIN Customers c ON rf.CustomerID = c.CustomerID
JOIN Merchants m ON rf.MerchantID = m.MerchantID;

-- Task 10: Complete Fraud Detection Report
-- Generate a comprehensive report of all customers, merchants, and transactions with potential fraud detected.
WITH FraudReport AS (
    SELECT t.TransactionID, t.CustomerID, t.MerchantID, t.TransactionAmount, t.TransactionDate, t.IsFraud,
           c.Name AS CustomerName, m.MerchantName
    FROM Transactions t
    JOIN Customers c ON t.CustomerID = c.CustomerID
    JOIN Merchants m ON t.MerchantID = m.MerchantID
    WHERE t.IsFraud = TRUE
)
SELECT * FROM FraudReport;
