--***************************************************************************************************
-- BUSINESS RULES AND THEIR CORRESPONDING VIEWS
--***************************************************************************************************

--Product Catalog View: A view that combines data from the Product, ProductModel, and ProductDescription tables to
--show a list of all products in the AdventureWorks catalog with their descriptions.

USE AdventureWorks2014
GO

CREATE VIEW AdventureWorksCatalog
AS
SELECT 
    p.ProductID, 
    p.Name AS ProductName, 
    pm.Name AS ModelName, 
    pd.Description 
FROM 
    Production.Product AS p 
    JOIN Production.ProductModel AS pm ON p.ProductModelID = pm.ProductModelID 
    JOIN Production.ProductModelProductDescriptionCulture AS pmpdc ON pm.ProductModelID = pmpdc.ProductModelID 
    JOIN Production.ProductDescription AS pd ON pmpdc.ProductDescriptionID = pd.ProductDescriptionID 
WHERE 
    p.ListPrice IS NOT NULL;

-- ================================================================================================

-- Vendor View: A view that combines data from the Vendor, PurchaseOrderHeader, and PurchaseOrderDetail tables 
-- to show a list of all vendors and their recent purchase orders.

USE AdventureWorks2014
GO

CREATE VIEW VendorPurchaseOrders
AS
SELECT 
    v.BusinessEntityID, 
    v.Name AS VendorName, 
    MAX(poh.OrderDate) AS MostRecentOrderDate, 
    SUM(pod.LineTotal) AS TotalPurchaseAmount 
FROM 
    Purchasing.Vendor AS v 
    JOIN Purchasing.PurchaseOrderHeader AS poh ON v.BusinessEntityID = poh.VendorID 
    JOIN Purchasing.PurchaseOrderDetail AS pod ON poh.PurchaseOrderID = pod.PurchaseOrderID 
GROUP BY 
    v.BusinessEntityID, 
    v.Name;

select * from VendorPurchaseOrders

-- ================================================================================================

-- Sales by Category View: A view that combines data from the Product, ProductCategory, and SalesOrderDetail 
-- tables to show total sales by product category.

USE AdventureWorks2014
GO

CREATE VIEW SalesByProductCategory
AS
SELECT 
    pc.ProductCategoryID, 
    pc.Name AS CategoryName, 
    SUM(sod.LineTotal) AS TotalSales 
FROM 
    Sales.SalesOrderDetail AS sod
    JOIN Production.Product AS p ON sod.ProductID = p.ProductID 
    JOIN Production.ProductSubcategory AS psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID 
    JOIN Production.ProductCategory AS pc ON psc.ProductCategoryID = pc.ProductCategoryID 
GROUP BY 
    pc.ProductCategoryID, 
    pc.Name;

-- ================================================================================================

-- Customer Order History View: A view that combines data from the Customer and SalesOrderHeader tables to 
-- show a customer's order history, including order date, product ordered, and order status.

USE AdventureWorks2014
GO
CREATE VIEW CustomerOrderHistory
AS
SELECT 
    c.CustomerID, 
    c.PersonID, 
    --c.FirstName + ' ' + c.LastName AS CustomerName,
    soh.SalesOrderID, 
    soh.OrderDate, 
    sod.LineTotal, 
    p.Name AS ProductName, 
    soh.Status 
FROM 
    Sales.Customer AS c 
    JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID 
    JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID 
    JOIN Production.Product AS p ON sod.ProductID = p.ProductID;

-- ================================================================================================
-- Product Inventory View: A view that combines data from the Product and ProductInventory 
-- tables to show the current inventory levels for all products.

USE AdventureWorks2014
GO
CREATE VIEW ProductInventoryView
AS
SELECT 
    p.ProductID, 
    p.Name AS ProductName, 
    p.ListPrice, 
    pi.Quantity, 
    pi.LocationID
FROM 
    Production.Product AS p 
    JOIN Production.ProductInventory AS pi ON p.ProductID = pi.ProductID;

-- ================================================================================================
--Vendor Performance View: A view that combines data from the Vendor, PurchaseOrderHeader, 
-- and PurchaseOrderDetail tables to show a vendor's performance metrics, such as on-time delivery rate or average order amount.

USE AdventureWorks2014
GO
CREATE VIEW VendorPerformanceView
AS
SELECT 
    v.BusinessEntityID, 
    v.AccountNumber, 
    v.Name, 
    v.CreditRating, 
    v.PreferredVendorStatus, 
    v.ActiveFlag,
    COUNT(DISTINCT poh.PurchaseOrderID) AS NumOrders,
    SUM(pod.OrderQty * pod.UnitPrice) AS TotalOrderAmount,
    AVG(DATEDIFF(day, poh.OrderDate, poh.ShipDate)) AS AvgDeliveryDays
FROM 
    Purchasing.Vendor AS v 
    JOIN Purchasing.PurchaseOrderHeader AS poh ON v.BusinessEntityID = poh.VendorID 
    JOIN Purchasing.PurchaseOrderDetail AS pod ON poh.PurchaseOrderID = pod.PurchaseOrderID 
GROUP BY 
    v.BusinessEntityID, 
    v.AccountNumber, 
    v.Name, 
    v.CreditRating, 
    v.PreferredVendorStatus, 
    v.ActiveFlag;

-- ================================================================================================

--Product Reviews View: A view that combines data from the Product, ProductReview, and 
-- SalesOrderDetail tables to show product ratings and reviews from customers who have purchased the product.
USE AdventureWorks2014
GO
CREATE VIEW ProductReviewsView
AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    AVG(pr.Rating) AS AverageRating,
    COUNT(pr.ProductReviewID) AS ReviewCount,
    STRING_AGG(CONVERT(NVARCHAR(MAX), pr.Comments), CHAR(13) + CHAR(10)) AS ReviewComments
FROM 
    Production.Product AS p
    JOIN Production.ProductReview AS pr ON p.ProductID = pr.ProductID
    JOIN Sales.SalesOrderDetail AS sod ON sod.ProductID = p.ProductID
GROUP BY 
    p.ProductID,
    p.Name

	
-- ================================================================================================
-- Order Fulfillment View: A view that combines data from the SalesOrderHeader, 
-- SalesOrderDetail, and PurchaseOrderHeader tables to show the status of open orders 
USE AdventureWorks2014
GO
CREATE VIEW OrderFulfillmentView
AS
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.DueDate,
    ph.PurchaseOrderID,
    ph.OrderDate AS PurchaseOrderDate,
    SUM(sod.OrderQty) AS OrderQuantity,
    SUM(sod.OrderQty * sod.UnitPrice) AS TotalPrice,
    CASE 
        WHEN soh.ShipDate IS NULL THEN 'Open'
        ELSE 'Fulfilled'
    END AS OrderStatus
FROM 
    Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Purchasing.PurchaseOrderDetail AS pod ON sod.ProductID = pod.ProductID
    JOIN Purchasing.PurchaseOrderHeader AS ph ON pod.PurchaseOrderID = ph.PurchaseOrderID
GROUP BY 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.DueDate,
    ph.PurchaseOrderID,
    ph.OrderDate,
    soh.ShipDate
HAVING 
    soh.ShipDate IS NULL; -- Only show open orders

-- ================================================================================================

--Order Summary View: A view that combines data from the SalesOrderHeader and SalesOrderDetail tables
-- to provide a summary of an order, including the order date, customer, products ordered, and total cost.

USE AdventureWorks2014
GO

CREATE VIEW OrderSummaryView AS
SELECT
    soh.SalesOrderID,
    soh.OrderDate,
    c.CustomerID,
    --c.CompanyName AS CustomerName,
    SUM(sod.OrderQty) AS TotalQuantity,
    SUM(sod.LineTotal) AS TotalCost
FROM 
    Sales.SalesOrderHeader AS soh
    JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
    JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY 
    soh.SalesOrderID, 
    soh.OrderDate, 
    c.CustomerID
    --c.CompanyName


-- ================================================================================================

-- Product Sales Forecast View: A view that combines data from the Product, SalesOrderHeader, 
-- and SalesOrderDetail tables to show a forecast of product sales based on historical data.
USE AdventureWorks2014
GO

CREATE VIEW ProductSalesForecast AS
SELECT 
    p.Name AS ProductName, 
    YEAR(soh.OrderDate) AS SalesYear,
    MONTH(soh.OrderDate) AS SalesMonth,
    SUM(sod.OrderQty) AS TotalSalesQty,
    SUM(sod.LineTotal) AS TotalSalesAmount
FROM 
    Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product AS p ON sod.ProductID = p.ProductID
GROUP BY 
    p.Name, 
    YEAR(soh.OrderDate), 
    MONTH(soh.OrderDate)

-- ================================================================================================

-- Showing total orders placed by customers

USE AMALGAMATED

GO

SELECT c.custid, c.contactname, count(o.custid) as 'Total orders palced'
FROM Sales.Customers c
INNER JOIN Sales.Orders o
ON c.custid = o.custid
group by  c.custid, c.contactname

-- ================================================================================================

