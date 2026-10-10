create database online_retail;

use online_retail;

# create table sales
CREATE TABLE sales (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate VARCHAR(50),
    UnitPrice DECIMAL(10,2),
    CustomerID VARCHAR(20),
    Country VARCHAR(50)
);
# checking count
SELECT COUNT(*) FROM sales;

SELECT * FROM sales LIMIT 10;

SELECT COUNT(*) FROM sales WHERE InvoiceNo IS NULL

SELECT COUNT(*) FROM sales WHERE Description IS NULL OR Description = '';

SELECT COUNT(*) FROM sales WHERE CustomerID IS NULL OR CustomerID = '';

SELECT COUNT(*) FROM sales WHERE InvoiceNo LIKE 'C%';

# get revenue upon month 

SELECT 
    SUBSTRING(InvoiceDate, 4, 2) AS Month,
    SUBSTRING(InvoiceDate, 7, 4) AS Year,
    SUM(Quantity * UnitPrice) AS Revenue
FROM sales
WHERE Quantity > 0
GROUP BY Year, Month
ORDER BY Year, Month;

# december of 2011 has dipped much lower than expected so checking for data irregularities

SELECT DISTINCT SUBSTRING(InvoiceDate, 1, 2) AS Day
FROM sales
WHERE SUBSTRING(InvoiceDate, 4, 2) = '12' AND SUBSTRING(InvoiceDate, 7, 4) = '2011'
ORDER BY Day;

# return revenue for each country and number of orders

SELECT Country, SUM(Quantity * UnitPrice) AS Revenue, COUNT(DISTINCT InvoiceNo) AS Orders
FROM sales
WHERE Quantity > 0
GROUP BY Country
ORDER BY Revenue DESC
LIMIT 15;

# get avgordervalue for the revenue and group by country

SELECT Country, 
       SUM(Quantity * UnitPrice) AS Revenue, 
       COUNT(DISTINCT InvoiceNo) AS Orders,
       SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo) AS AvgOrderValue
FROM sales
WHERE Quantity > 0
GROUP BY Country
ORDER BY Revenue DESC
LIMIT 15;

# checking netherlands for any bulk orders since revenue is high in lower number of orders

SELECT CustomerID, SUM(Quantity * UnitPrice) AS Revenue, COUNT(DISTINCT InvoiceNo) AS Orders
FROM sales
WHERE Quantity > 0 AND Country = 'Netherlands'
GROUP BY CustomerID
ORDER BY Revenue DESC;

# getting "14646" customer's revenue with netherlands total revenue

SELECT 
    SUM(CASE WHEN CustomerID = '14646' THEN Quantity * UnitPrice ELSE 0 END) AS TopCustomerRevenue,
    SUM(Quantity * UnitPrice) AS TotalNetherlandsRevenue
FROM sales
WHERE Quantity > 0 AND Country = 'Netherlands';

# checking for top quantities with top revenue for any possible matches

SELECT Description, SUM(Quantity) AS TotalQty, SUM(Quantity * UnitPrice) AS Revenue
FROM sales
WHERE Quantity > 0
GROUP BY Description
ORDER BY Revenue DESC
LIMIT 10;

SELECT Description, SUM(Quantity) AS TotalQty, SUM(Quantity * UnitPrice) AS Revenue
FROM sales
WHERE Quantity > 0
GROUP BY Description
ORDER BY TotalQty DESC
LIMIT 10;

# checking for shipping entries

SELECT StockCode, Description, COUNT(*) AS Occurrences
FROM sales
WHERE Description IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
GROUP BY StockCode, Description;

# removing shipping entries and re-running the previous query

SELECT Description, SUM(Quantity) AS TotalQty, SUM(Quantity * UnitPrice) AS Revenue
FROM sales
WHERE Quantity > 0 
  AND Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
  AND Description IS NOT NULL AND Description != ''
GROUP BY Description
ORDER BY Revenue DESC
LIMIT 10;

SELECT Description, SUM(Quantity) AS TotalQty, SUM(Quantity * UnitPrice) AS Revenue
FROM sales
WHERE Quantity > 0 
  AND Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
  AND Description IS NOT NULL AND Description != ''
GROUP BY Description
ORDER BY TotalQty DESC
LIMIT 10;

# overall customer concentration(top 20)

SELECT CustomerID, SUM(Quantity * UnitPrice) AS Revenue
FROM sales
WHERE Quantity > 0 AND CustomerID IS NOT NULL AND CustomerID != ''
GROUP BY CustomerID
ORDER BY Revenue DESC
LIMIT 20;

# to check the top 20's revenue as to the totalrevenue

SELECT SUM(Quantity * UnitPrice) AS TotalRevenue
FROM sales
WHERE Quantity > 0;

# non-null values

SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country,
       (Quantity * UnitPrice) AS Revenue
FROM sales
WHERE Quantity > 0 
  AND Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
  AND Description IS NOT NULL AND Description != '';
  
  
SELECT COUNT(*) FROM sales
WHERE Quantity > 0 
  AND Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
  AND Description IS NOT NULL AND Description != '';
  
# country revenue on clean data (matches the Tableau dashboard)

SELECT Country,
       SUM(Quantity * UnitPrice) AS Revenue,
       COUNT(DISTINCT InvoiceNo) AS Orders
FROM sales
WHERE Quantity > 0
  AND Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
  AND Description IS NOT NULL AND Description != ''
GROUP BY Country
ORDER BY Revenue DESC
LIMIT 15;

# customer 14646's share of netherlands revenue on clean data

SELECT
    SUM(CASE WHEN CustomerID = '14646' THEN Quantity * UnitPrice ELSE 0 END) AS TopCustomerRevenue,
    SUM(Quantity * UnitPrice) AS TotalNetherlandsRevenue,
    ROUND(100 * SUM(CASE WHEN CustomerID = '14646' THEN Quantity * UnitPrice ELSE 0 END)
              / SUM(Quantity * UnitPrice), 1) AS TopCustomerPct
FROM sales
WHERE Quantity > 0
  AND Country = 'Netherlands'
  AND Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
  AND Description IS NOT NULL AND Description != '';

# top 20 customers' share of total revenue on clean data

SELECT ROUND(100 * SUM(rev) / (
    SELECT SUM(Quantity * UnitPrice)
    FROM sales
    WHERE Quantity > 0
      AND Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
      AND Description IS NOT NULL AND Description != ''
), 1) AS Top20Pct
FROM (
    SELECT CustomerID, SUM(Quantity * UnitPrice) AS rev
    FROM sales
    WHERE Quantity > 0
      AND Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
      AND Description IS NOT NULL AND Description != ''
      AND CustomerID IS NOT NULL AND CustomerID != ''
    GROUP BY CustomerID
    ORDER BY rev DESC
    LIMIT 20
) t;

# clean dataset exported for the tableau dashboard

SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice,
       CustomerID, Country,
       (Quantity * UnitPrice) AS Revenue
FROM sales
WHERE Quantity > 0
  AND Description NOT IN ('DOTCOM POSTAGE', 'POSTAGE', 'Manual')
  AND Description IS NOT NULL AND Description != '';
