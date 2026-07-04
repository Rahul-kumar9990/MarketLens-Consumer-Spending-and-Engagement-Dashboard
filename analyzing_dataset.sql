/* ============================================================
   Project : MarketLens - Consumer Spending and Engagement Dashboard
   Purpose : Create Database and Dataset Table
   SQL      : MySQL Workbench
   ============================================================ */

-- Create Database
CREATE DATABASE IF NOT EXISTS marketlens;

-- Use Database
USE marketlens;

-- Create Dataset Table
CREATE TABLE dataset (

    CustomerID INT,
    Gender VARCHAR(20),
    Location VARCHAR(100),
    Tenure_Months INT,

    Transaction_ID INT PRIMARY KEY,

    Transaction_Date DATE,

    Product_SKU VARCHAR(100),

    Product_Description VARCHAR(255),

    Product_Category VARCHAR(100),

    Quantity INT,

    Avg_Price DECIMAL(10,2),

    Delivery_Charges DECIMAL(10,2),

    Coupon_Status VARCHAR(50),

    GST DECIMAL(10,2),

    Date DATE,

    Offline_Spend DECIMAL(10,2),

    Online_Spend DECIMAL(10,2),

    Month INT,

    Coupon_Code VARCHAR(50),

    Discount_pct DECIMAL(5,2)

);

select * from dataset;

USE marketlens;

/* ============================================================
   Project: MarketLens - Consumer Spending and Engagement Dashboard
   File: analysis.sql
   SQL Type: MySQL Workbench
   Purpose: Analyze customer behavior, product performance,
            sales trends, coupon usage, and location-wise revenue.
   ============================================================ */


/* ============================================================
   1. Customer Demographic Analysis
   Purpose: Count customers by gender.
   ============================================================ */

SELECT 
    Gender,
    COUNT(*) AS CustomerCount
FROM dataset 
GROUP BY Gender
ORDER BY CustomerCount DESC;


/* ============================================================
   2. Customer Tenure Analysis
   Purpose: Find average customer tenure by gender.
   ============================================================ */

SELECT 
    Gender,
    AVG(Tenure_Months) AS AvgTenureMonths
FROM dataset
GROUP BY Gender
ORDER BY AvgTenureMonths DESC;


/* ============================================================
   3. Customer Tenure Segmentation Analysis
   Purpose: Group customers by tenure range.
   ============================================================ */

SELECT Gender,
    CASE
        WHEN Tenure_Months <= 12 THEN '0-12 months'
        WHEN Tenure_Months <= 24 THEN '13-24 months'
        WHEN Tenure_Months <= 36 THEN '25-36 months'
        ELSE 'Over 36 months'
    END AS TenureRange,
    COUNT(*) AS CustomerCount
FROM dataset 
GROUP BY
    Gender,
    CASE
        WHEN Tenure_Months <= 12 THEN '0-12 months'
        WHEN Tenure_Months <= 24 THEN '13-24 months'
        WHEN Tenure_Months <= 36 THEN '25-36 months'
        ELSE 'Over 36 months'
    END
ORDER BY Gender, TenureRange;


/* ============================================================
   4. Product Category Sales Analysis
   Purpose: Identify best-selling product categories by quantity.
   ============================================================ */

SELECT
    Product_Category,
    SUM(Quantity) AS Total_Units_Sold
FROM dataset
GROUP BY Product_Category
ORDER BY Total_Units_Sold DESC;


/* ============================================================
   5. Top Product Category Contribution Analysis
   Purpose: Find top 5 categories and their percentage contribution.
   ============================================================ */

WITH CategorySales AS
(
    SELECT
        Product_Category,
        SUM(Quantity) AS TotalUnitsSold
    FROM dataset
    GROUP BY Product_Category
)

SELECT
    Product_Category,
    TotalUnitsSold,
    ROUND(
        (TotalUnitsSold * 100.0) /
        (SELECT SUM(TotalUnitsSold) FROM CategorySales),
        2
    ) AS PercentageContribution
FROM CategorySales
ORDER BY TotalUnitsSold DESC
LIMIT 5;

/* ============================================================
   6. Monthly Discount Analysis
   Purpose: Analyze average discount percentage by month.
   ============================================================ */

SELECT 
    Month,
    AVG(Discount_pct) AS AvgDiscountPct
FROM dataset   
GROUP BY Month
ORDER BY CAST(Month AS UNSIGNED);


/* ============================================================
   7. High-Value Customer Analysis
   Purpose: Identify top 10 customers by online + offline spend.
   ============================================================ */

SELECT
    CustomerID,
    SUM(Offline_Spend) AS TotalOfflineSpend,
    SUM(Online_Spend) AS TotalOnlineSpend,
    SUM(Offline_Spend + Online_Spend) AS TotalSpend
FROM dataset
GROUP BY CustomerID
ORDER BY TotalSpend DESC
LIMIT 10;


/* ============================================================
   8. Top Customers by Transaction Revenue
   Purpose: Identify customers who generated the highest revenue.
   ============================================================ */

/* ============================================================
   8. Top Customers by Transaction Revenue
   Purpose: Identify customers who generated the highest
            sales revenue based on their transactions.
   ============================================================ */

SELECT
    CustomerID,
    SUM(Quantity * Avg_Price) AS TotalRevenue
FROM dataset
GROUP BY CustomerID
ORDER BY TotalRevenue DESC
LIMIT 10;

/* ============================================================
   9. Specific Customer Profile Check
   Purpose: View complete details of one selected customer.
   ============================================================ */
SELECT
    CustomerID,
    Gender,
    Location,
    Tenure_Months,
    Transaction_ID,
    Transaction_Date,
    Product_Description,
    Product_Category,
    Quantity,
    Avg_Price,
    Offline_Spend,
    Online_Spend,
    Coupon_Status,
    Discount_pct
FROM dataset
WHERE CustomerID = 15311;



/* ============================================================
   10. Purchase Breakdown of a High-Spending Customer
   Purpose: Analyze product categories bought by a selected customer.
   ============================================================ */

SELECT
    Product_Category,
    COUNT(Transaction_ID) AS TotalTransactions,
    SUM(Quantity) AS TotalQuantityPurchased,
    SUM(Quantity * Avg_Price) AS TotalRevenue
FROM dataset
WHERE CustomerID = 12748
GROUP BY Product_Category
ORDER BY TotalRevenue DESC;


/* ============================================================
   11. Customer Spending Summary
   Purpose: Compare customers by gender, location, tenure, and spend.
   ============================================================ */

SELECT
    CustomerID,
    Gender,
    Location,
    Tenure_Months,
    SUM(Offline_Spend) AS TotalOfflineSpend,
    SUM(Online_Spend) AS TotalOnlineSpend,
    SUM(Offline_Spend + Online_Spend) AS TotalSpend
FROM dataset
GROUP BY
    CustomerID,
    Gender,
    Location,
    Tenure_Months
ORDER BY TotalSpend DESC;


/* ============================================================
   12. Product Performance Analysis
   Purpose: Find top 10 products by revenue and quantity sold.
   ============================================================ */

SELECT
    Product_Description,
    Product_Category,
    SUM(Quantity) AS TotalQuantitySold,
    SUM(Quantity * Avg_Price) AS TotalRevenue
FROM dataset
GROUP BY
    Product_Description,
    Product_Category
ORDER BY TotalRevenue DESC
LIMIT 10;


/* ============================================================
   13. Specific Product Performance Analysis
   Purpose: Analyze sales and revenue of one selected product.
   ============================================================ */

SELECT
    Product_Description,
    Product_Category,
    SUM(Quantity) AS TotalQuantitySold,
    SUM(Quantity * Avg_Price) AS TotalRevenue
FROM dataset
WHERE Product_Description = 'Nest Learning Thermostat 3rd Gen-USA - Stainless Steel'
GROUP BY
    Product_Description,
    Product_Category;


/* ============================================================
   14. Monthly Sales Trend Analysis
   Purpose: Analyze monthly quantity sold and total revenue.
   ============================================================ */
SELECT
    Month,
    SUM(Quantity) AS TotalQuantitySold,
    SUM(Quantity * Avg_Price) AS TotalRevenue
FROM dataset
GROUP BY Month
ORDER BY Month;


/* ============================================================
   15. Coupon Usage Analysis
   Purpose: Understand overall coupon usage behavior.
   ============================================================ */

SELECT
    Coupon_Status,
    COUNT(*) AS TotalCouponUsage
FROM dataset
WHERE Coupon_Status IS NOT NULL
GROUP BY Coupon_Status
ORDER BY TotalCouponUsage DESC;


/* ============================================================
   16. Monthly Coupon Usage Trend
   Purpose: Analyze coupon usage month by month.
   ============================================================ */

SELECT
    Month,
    Coupon_Status,
    COUNT(*) AS TotalCouponUsage
FROM dataset
WHERE Coupon_Status IS NOT NULL
GROUP BY
    Month,
    Coupon_Status
ORDER BY
    Month,
    Coupon_Status;

/* ============================================================
   17. Coupon Usage by Product Category
   Purpose: Identify product categories where coupons are used most.
   ============================================================ */

SELECT
    Product_Category,
    COUNT(*) AS TotalCouponUsage
FROM dataset
WHERE Coupon_Status = 'Used'
GROUP BY Product_Category
ORDER BY TotalCouponUsage DESC;


/* ============================================================
   18. Location-Based Sales Analysis
   Purpose: Identify locations generating the highest revenue.
   ============================================================ */

SELECT
    Location,
    SUM(Quantity * Avg_Price) AS TotalRevenue
FROM dataset
GROUP BY Location
ORDER BY TotalRevenue DESC;