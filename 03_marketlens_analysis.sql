--    Project  : MarketLens - Consumer Spending and Engagement Dashboard
--    Author   : Rahul Kumar
--    Database : marketlens
--    Tool     : MySQL Workbench 8.0


-- Create Database
DROP DATABASE IF EXISTS marketlens;

CREATE DATABASE IF NOT EXISTS marketlens;

-- Use Database
USE marketlens;

CREATE TABLE dataset (

    CustomerID INT,

    Gender VARCHAR(10),

    Location VARCHAR(50),

    Tenure_Months INT,

    Transaction_ID INT,

    Transaction_Date DATE,

    Product_SKU VARCHAR(100),

    Product_Description VARCHAR(255),

    Product_Category VARCHAR(100),

    Quantity INT,

    Avg_Price DECIMAL(10,2),

    Delivery_Charges DECIMAL(10,2),

    Coupon_Status VARCHAR(20),

    GST DECIMAL(5,2),

    Offline_Spend DECIMAL(10,2),

    Online_Spend DECIMAL(10,2),

    Month INT,

    Coupon_Code VARCHAR(50),

    Discount_pct DECIMAL(5,2)

);

DROP TABLE dataset;
USE marketlens;

LOAD DATA LOCAL INFILE
'C:/Users/sai baba/OneDrive/Desktop/MarketLens-Consumer Spending and Engagement Dashboard/dataset.csv'

INTO TABLE dataset

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\r\n'

IGNORE 1 ROWS

(
CustomerID,
Gender,
Location,
Tenure_Months,
Transaction_ID,
@Transaction_Date,
Product_SKU,
Product_Description,
Product_Category,
Quantity,
Avg_Price,
Delivery_Charges,
Coupon_Status,
GST,
Offline_Spend,
Online_Spend,
Month,
Coupon_Code,
Discount_pct
)

SET Transaction_Date = STR_TO_DATE(@Transaction_Date, '%d-%m-%Y');



SELECT Transaction_Date
FROM dataset
LIMIT 10;


-- Customer Analytics

-- 1.	What is the distribution of customers across different genders?
SELECT
    Gender,
    COUNT(DISTINCT CustomerID) AS Total_Customers
FROM dataset
GROUP BY Gender
ORDER BY Total_Customers DESC;

-- 2.	What is the average customer tenure for each gender?
SELECT
    Gender,
    ROUND(AVG(Tenure_Months), 2) AS Average_Tenure_Months
FROM dataset
GROUP BY Gender
ORDER BY Average_Tenure_Months DESC;

-- 3.	How are customers distributed across different tenure groups?
SELECT
    CASE
        WHEN Tenure_Months <= 12 THEN '0-12 Months'
        WHEN Tenure_Months <= 24 THEN '13-24 Months'
        WHEN Tenure_Months <= 36 THEN '25-36 Months'
        WHEN Tenure_Months <= 48 THEN '37-48 Months'
        ELSE '49+ Months'
    END AS Tenure_Group,
    COUNT(DISTINCT CustomerID) AS Total_Customers
FROM dataset
GROUP BY Tenure_Group
ORDER BY
CASE
    WHEN Tenure_Group='0-12 Months' THEN 1
    WHEN Tenure_Group='13-24 Months' THEN 2
    WHEN Tenure_Group='25-36 Months' THEN 3
    WHEN Tenure_Group='37-48 Months' THEN 4
    ELSE 5
END;

-- 4.	Which customers generate the highest overall spending through online and offline purchase channels? 
SELECT
    CustomerID,
    SUM(Offline_Spend) AS Offline_Spend,
    SUM(Online_Spend) AS Online_Spend,
    SUM(Offline_Spend + Online_Spend) AS Total_Spend
FROM dataset
GROUP BY CustomerID
ORDER BY Total_Spend DESC
LIMIT 10;

-- 5.	Which customers generate the highest revenue based on their product purchases?
SELECT
    CustomerID,
    ROUND(SUM(Quantity * Avg_Price),2) AS Revenue
FROM dataset
GROUP BY CustomerID
ORDER BY Revenue DESC
LIMIT 10;

-- 6.	What are the complete purchase and demographic details of a selected customer?
-- Customer id – 15311

SELECT *
FROM dataset
WHERE CustomerID = 15311;

-- 7.	Which product categories are most frequently purchased by a selected high-value 
-- customer?
SELECT
    Product_Category,
    COUNT(Transaction_ID) AS Total_Transactions,
    SUM(Quantity) AS Total_Units_Purchased,
    ROUND(SUM(Quantity * Avg_Price),2) AS Total_Revenue
FROM dataset
WHERE CustomerID = 15311
GROUP BY Product_Category
ORDER BY Total_Revenue DESC;


-- 8.	How does customer spending vary across different genders, locations, and tenure groups?
SELECT
    Gender,
    Location,
    CASE
        WHEN Tenure_Months <= 12 THEN '0-12 Months'
        WHEN Tenure_Months <= 24 THEN '13-24 Months'
        WHEN Tenure_Months <= 36 THEN '25-36 Months'
        WHEN Tenure_Months <= 48 THEN '37-48 Months'
        ELSE '49+ Months'
    END AS Tenure_Group,
    COUNT(DISTINCT CustomerID) AS Total_Customers,
    ROUND(SUM(Offline_Spend),2) AS Total_Offline_Spend,
    ROUND(SUM(Online_Spend),2) AS Total_Online_Spend,
    ROUND(SUM(Offline_Spend + Online_Spend),2) AS Total_Spend
FROM dataset
GROUP BY
    Gender,
    Location,
    Tenure_Group
ORDER BY
    Total_Spend DESC;
    
--  Product Analytics , Sales & Revenue Analytics

-- 9.	Which product categories contribute the highest number of units sold?
SELECT
    Product_Category,
    SUM(Quantity) AS Total_Units_Sold
FROM dataset
GROUP BY Product_Category
ORDER BY Total_Units_Sold DESC;

-- 10.	Which product categories contribute the most to total sales volume, and what percentage of overall sales does each category represent?
WITH CategorySales AS
(
    SELECT
        Product_Category,
        SUM(Quantity) AS Total_Units_Sold
    FROM dataset
    GROUP BY Product_Category
)
SELECT
    Product_Category,
    Total_Units_Sold,
    ROUND(
        (Total_Units_Sold * 100.0) /
        (SELECT SUM(Total_Units_Sold) FROM CategorySales),
        2
    ) AS Sales_Contribution_Percentage
FROM CategorySales
ORDER BY Total_Units_Sold DESC;


-- 11.	Which products generate the highest revenue and sales volume?
SELECT
    Product_SKU,
    Product_Description,
    Product_Category,
    SUM(Quantity) AS Total_Units_Sold,
    ROUND(
        SUM(Quantity * Avg_Price),
        2
    ) AS Total_Revenue
FROM dataset
GROUP BY
    Product_SKU,
    Product_Description,
    Product_Category
ORDER BY
    Total_Revenue DESC,
    Total_Units_Sold DESC
LIMIT 10;

-- 12.	How do product sales and revenue change throughout the year?
SELECT
    Month,
    SUM(Quantity) AS Total_Units_Sold,
    ROUND(
        SUM(Quantity * Avg_Price),
        2
    ) AS Total_Revenue
FROM dataset
GROUP BY Month
ORDER BY Month;



-- 13.	Which locations generate the highest product revenue?
SELECT
    Location,
    ROUND(
        SUM(Quantity * Avg_Price),
        2
    ) AS Total_Revenue
FROM dataset
GROUP BY Location
ORDER BY Total_Revenue DESC;   
    
    
-- Discount & Coupon Analytics
-- 14.	How do average discount percentages vary across different months?
SELECT
    Month,
    ROUND(AVG(Discount_pct), 2) AS Average_Discount_Percentage
FROM dataset
GROUP BY Month
ORDER BY Month;
-- 15.	How are customers engaging with available coupons during purchases?
SELECT
    Coupon_Status,
    COUNT(*) AS Total_Transactions,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM dataset),
        2
    ) AS Engagement_Percentage
FROM dataset
GROUP BY Coupon_Status
ORDER BY Total_Transactions DESC;
-- 16.	How does coupon engagement change across different months?
SELECT
    Month,
    Coupon_Status,
    COUNT(*) AS Coupon_Transactions
FROM dataset
GROUP BY
    Month,
    Coupon_Status
ORDER BY
    Month,
    Coupon_Status;

-- 17.	Which product categories receive the highest coupon engagement?
SELECT
    Product_Category,
    Coupon_Status,
    COUNT(*) AS Total_Transactions,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY Product_Category),
        2
    ) AS Engagement_Percentage
FROM dataset
GROUP BY
    Product_Category,
    Coupon_Status
ORDER BY
    Product_Category,
    Total_Transactions DESC;
    






