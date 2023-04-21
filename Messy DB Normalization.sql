/*
Group Members are:

BANSAL, Varun
GUPTA, Ashish
MAHAJAN, Pranshu

*/


--***************************************************************************************************
--CREATING DATABASE AND SALES SCHMEA

--***************************************************************************************************

CREATE DATABASE MessyNormalized;

USE MessyNormalized
GO
CREATE SCHEMA Sales;
GO

--***************************************************************************************************
------------------------------------------  1ST NORMAL FORM  ---------------------------------------- 

-- TO BE IN THE 1st NORMAL FORM, EACH RECORD SHOULD BE UNIQUELY IDENTIFIED.
-- TABLE CREATED --MESSY1NF
-- HAS UniqueID AS PRIMARY KEY (NEWLY GENERATED COLUMN)
-- EVERY COLUMN VALUES ARE TRIMMED (TO AVOID EXTRA SPACES)
-- ProductTags COLUMN DEFIES THE PRINCIPLES OF RDBMS, SO WE WILL CONVERT EVERY CSV TO SEPERATE ROW.
-- REQUIRED COLUMNS WILL HAVE NOT NULL CONSTRAINT
-- CHANGE CUSTOMER ADDRESS GENERIC NAMES TO PROPER UNDERSTANDABLE NAMES
-- COMBINED VALUES FROM CustomerAddress3 AND CustomerAddress4 INTO ONE COLUMN
-- COMBINED VALUES FROM [DiscountAppliedPc] AND [DiscountAppliedAbs] INTO ONE COLUMN

--***************************************************************************************************

--===============================  CREATING TABLE - Sales.Messy1NF ==================================

-- DROP TABLE Sales.Messy1NF
 CREATE TABLE Sales.Messy1NF
(
UniqueID INT PRIMARY KEY IDENTITY(10001,1),
OrderNo  NVARCHAR(90) NOT NULL,
SaleDate    DATETIME     NOT NULL,
ProductID INT  NOT NULL,
ProductDescription NVARCHAR(60) NOT NULL,
ProductTags  NVARCHAR(60) NOT NULL,
LineItemPrice  FLOAT NOT NULL,
TotalSalePrice FLOAT NOT NULL,
CustomerName	NVARCHAR(60) NOT NULL,
CustomerAddress	NVARCHAR(60) NOT NULL,
CustomerCity	NVARCHAR(60) NOT NULL,
CustomerCounty	NVARCHAR(60) NULL,
CustomerPostalCode	NVARCHAR(60) NULL,
CustomerPhoneNo	NVARCHAR(60) NOT NULL,
CustomerEmail	NVARCHAR(60) NOT NULL,
RepeatCustomer	NVARCHAR(3) NULL,
PromoCode 	NVARCHAR(60) NULL,
DiscountApplied FLOAT NULL,
NewTotalSalePrice  FLOAT NOT NULL 
);

--=====================================  INSERTING RECORDS  =======================================

WITH CTE AS(
  SELECT [OrderNo]
      ,[SaleDate]
      ,[ProductID]
      ,TRIM([ProductDescription]) AS [ProductDescription]
      ,TRIM(cs.Value) AS "ProductTags"
      ,[LineItemPrice]
      ,[TotalSalePrice]
      ,TRIM([CustomerName])  AS [CustomerName]
      ,TRIM([CustomerAddress1]) AS [CustomerAddress1]
      ,TRIM([CustomerAddress2]) AS [CustomerAddress2]
      ,TRIM([CustomerAddress3]) AS [CustomerAddress3]
      ,TRIM([CustomerAddress4]) AS [CustomerAddress4]
      ,TRIM([CustomerAddress5]) AS [CustomerAddress5]
      ,TRIM([CustomerPhoneNo]) AS [CustomerPhoneNo]
      ,TRIM([CustomerEmail]) AS [CustomerEmail]
      ,TRIM([RepeatCustomer]) AS [RepeatCustomer]
      ,TRIM([PromoCode]) AS [PromoCode]
      ,[DiscountAppliedPc]
      ,[DiscountAppliedAbs]
      ,[NewTotalSalePrice]
  FROM [Messy].[dbo].[Messy]
	cross apply STRING_SPLIT (productTags, ',') cs
	)
  INSERT INTO MessyNormalized.Sales.Messy1NF
  SELECT 
	[OrderNo]
	,CAST(SUBSTRING(SaleDate,1,8) AS DATETIME) AS SaleDate
	,CAST([ProductID] AS INT) AS ProductID
	,[ProductDescription]
	,[ProductTags]
	,CAST([LineItemPrice] AS INT) AS LineItemPrice
	,CAST([TotalSalePrice] AS INT) AS TotalSalePrice
	,[CustomerName]
	,[CustomerAddress1]
	,[CustomerAddress2],
	CASE
	WHEN [CustomerAddress4] IS NOT NULL OR [CustomerAddress4]! = '' THEN [CustomerAddress4]
	ELSE [CustomerAddress3]
	END AS [CustomerCounty]
	,[CustomerAddress5]
	,[CustomerPhoneNo]
	,[CustomerEmail]
	,[RepeatCustomer]
	,[PromoCode],
	CASE
    WHEN [DiscountAppliedPc] IS NOT NULL THEN CAST([DiscountAppliedPc] AS FLOAT)
    ELSE CAST([DiscountAppliedAbs] AS FLOAT)
	END AS [DiscountApplied]
	,CAST([NewTotalSalePrice] AS INT) AS NewTotalSalePrice
	  FROM CTE
	  WHERE [OrderNo] IS NOT NULL
		  AND [SaleDate] IS NOT NULL
		  AND [ProductID]  IS NOT NULL
		  AND [LineItemPrice] IS NOT NULL
		  AND [TotalSalePrice] IS NOT NULL
		  AND [CustomerName] IS NOT NULL AND [CustomerName] != ''
		  AND [NewTotalSalePrice] IS NOT NULL
		  AND ProductDescription IS NOT NULL AND ProductDescription != ''
		  AND (ProductTags IS NOT NULL AND ProductTags != '')
		  AND CustomerAddress1 IS NOT NULL AND CustomerAddress1 != ''
		  AND CustomerAddress2 IS NOT NULL AND CustomerAddress2 != ''
		  AND CustomerPhoneNo IS NOT NULL AND CustomerPhoneNo ! = ''
		  AND CustomerEmail IS NOT NULL AND CustomerEmail != ''


-- SELECTING DATA FROM 1NF

SELECT * FROM MessyNormalized.Sales.Messy1NF   


--***************************************************************************************************
------------------------------------------  2nd NORMAL FORM  ---------------------------------------- 

-- TABLES CREATED --CUSTOMERS2NF
--                --PRODUCTS2NF
--                --TAGS2NF
--                --ORDERS2NF

-- EVERY TABLE HAS A PRIMARY KEY AND TABLES ARE LINKED BY A FOREIGN KEY.
-- NON-KEY ATTRIBUTES ARE FULLY DEPENDENT ON THE PRIMARY KEY.

-- BUT STILL THERE IS TRANSITIVE DEPENDENCY OF NON-KEY ATTRIBUTES ON THE PRIMARY KEY.
-- SO WILL FURTHER BREAKDOWN TO 3rd NORMAL FORM AFTER CONVERTING TO 2nd NORMAL FORM
--***************************************************************************************************

--=======================================  CREATING TABLES  =========================================

--DROP TABLE Sales.Customers2NF
CREATE TABLE Sales.Customers2NF
(
CustID INT PRIMARY KEY IDENTITY(10001,1),
CustomerName	NVARCHAR(60) NOT NULL,
CustomerAddress	NVARCHAR(60) NOT NULL,
CustomerCity	NVARCHAR(60) NOT NULL,
CustomerCounty	NVARCHAR(60) NULL,
CustomerPostalCode	NVARCHAR(60) NULL,
CustomerPhoneNo	NVARCHAR(60) NOT NULL,
CustomerEmail	NVARCHAR(60) NOT NULL,
);

--DROP TABLE Sales.Product2NF
CREATE TABLE Sales.Product2NF
(
ProductID INT PRIMARY KEY ,
ProductDescription NVARCHAR(60) NOT NULL,
LineItemPrice  FLOAT NOT NULL,
);

-- DROP TABLE Sales.Tags2NF
CREATE TABLE Sales.Tags2NF (
  ProductTagsID INT IDENTITY(1,1),
  ProductID INT,
  ProductTags VARCHAR(255) NOT NULL,
  PRIMARY KEY (ProductID, ProductTagsID),
  FOREIGN KEY (ProductID) REFERENCES Sales.Product2NF(ProductID),
);

-- DROP TABLE Sales.Orders2NF
CREATE TABLE Sales.Orders2NF
(
OrderNo  NVARCHAR(90),
CustID INT NOT NULL,
ProductID INT NOT NULL,
SaleDate    DATETIME     NOT NULL,
TotalSalePrice FLOAT NOT NULL,
RepeatCustomer	NVARCHAR(3) NULL,
PromoCode 	NVARCHAR(60) NULL,
DiscountAppliedPc 	FLOAT NULL,
NewTotalSalePrice  FLOAT NOT NULL 
PRIMARY KEY (OrderNo, ProductID),
FOREIGN KEY (CustID) REFERENCES Sales.Customers2NF(CustID),
FOREIGN KEY (ProductID) REFERENCES Sales.Product2NF(ProductID)
);

--=======================================  INSERING RECORDS  =========================================

INSERT INTO Sales.Customers2NF
	select distinct [CustomerName]
	,CustomerAddress
	,[CustomerCity]
	,[CustomerCounty]
	,[CustomerPostalCode]
	,[CustomerPhoneNo]
	,[CustomerEmail]
	from MessyNormalized.Sales.Messy1NF

INSERT INTO Sales.Product2NF
	SELECT DISTINCT
	[ProductID]
	,[ProductDescription]
	,[LineItemPrice]
	from MessyNormalized.Sales.Messy1NF

INSERT INTO Sales.Tags2NF
	SELECT DISTINCT ProductID, ProductTags
	FROM Sales.Messy1NF messy

INSERT INTO MessyNormalized.Sales.Orders2NF
	SELECT DISTINCT [OrderNo]
	,cust.CustID
	,ProductID
	,[SaleDate]
	,[TotalSalePrice]
	,[RepeatCustomer]
	,[PromoCode]
	,[DiscountApplied]
	,[NewTotalSalePrice]
	FROM
	MessyNormalized.Sales.Messy1NF mess
	INNER JOIN
	Sales.Customers2NF cust
	ON cust.CustomerName = mess.CustomerName
	ORDER BY SaleDate
	
--=======================================  SELECTING RECORDS  ========================================

SELECT * FROM Sales.Customers2NF;
SELECT * FROM Sales.Product2NF;
SELECT * FROM Sales.Tags2NF ;
SELECT * FROM MessyNormalized.Sales.Orders2NF;



--***************************************************************************************************
--------------------------------------------    3NF  ------------------------------------------------ 

-- TABLES CREATED --CUSTOMERS
--                --CUSTOMERADDRESS
--                --PRODUCTS
--                --TAGS
--                --PRODUCTTAGS
--				  --PROMO
--                --ORDERS

-- EVERY TABLE HAS A PRIMARY KEY AND TABLES ARE LINKED BY A FOREIGN KEY.
-- NO TRANSITIVE DEPENDENCY OF NON-KEY ATTRIBUTES ON THE PRIMARY KEY.

-- DETAILS ABOUT EVERY TABLE:
--		ORDERS - ORDERS TABLE NOW ONLY HAS THE FACT VALUES AND THE FOREIGN KEYS.
--				 COLUMNS ARE - [OrderNo], [SaleDate] ,[TotalSalePrice], [NewTotalSalePrice]
--							   [RepeatCustomer], CustID, [ProductID], PromoID

--		PROMO - PROMO TABLE HAS THE DETAILS OF THE PROMO CODE AND ITS ABSOLUTE VALUE.
--				COLUMNS ARE - [PromoCode], [DiscountApplied], PromoID

--		PRODUCTS - PRODUCT TABLE HAS DETAILS ABOUT THE PRODUCT AND ITS PRICE
--				   COLUMNS ARE - [ProductID], [ProductDescription], [LineItemPrice]

--		TAGS - TAGS TABLE HAS THE DETAILS ABOUT THE TAG AND HAS THE PRODUCTID
--				IN THIS TABLE THE PRIMARY KEY IS : (ProductTagsID, ProductID)
--				COLUMNS ARE - [ProductTagsID], [ProductTags], [ProductID]

--		CUSTOMERS - THIS HAS ONLY THE DETAILS OF CUSTOMERS THAT ARE LESS LIKEY TO CHANGE
--					COLUMNS ARE - [CustomerName], [CustomerPhoneNo], [CustomerEmail], CustID

--		CUSTOMERADDRESS - ONE CUSTOMER CAN HAVE MULTIPLE ADDRESSESS , LIKE HOME ADDRESS, OFFICE, RENTAL
--					COLUMNS ARE - CustID, CustomerAddress, [CustomerCity], [CustomerRegion],
--								  [CustomerCounty], [CustomerPostalCode]

--***************************************************************************************************

--=======================================  CREATING TABLES  =========================================

--DROP TABLE Sales.Customers
CREATE TABLE Sales.Customers
(
CustID INT PRIMARY KEY IDENTITY(10001,1),
CustomerName	NVARCHAR(60) NOT NULL,
CustomerPhoneNo	NVARCHAR(60) NOT NULL,
CustomerEmail	NVARCHAR(60) NOT NULL,
);

-- DROP TABLE Sales.CustomerAddress
CREATE TABLE Sales.CustomerAddress
(
CustAddressID INT PRIMARY KEY IDENTITY(10001,1),
CustID INT,
CustomerAddress	NVARCHAR(60) NOT NULL,
CustomerCity	NVARCHAR(60) NOT NULL,
CustomerCounty	NVARCHAR(60) NULL,
CustomerPostalCode	NVARCHAR(60) NULL
FOREIGN KEY (CustID) REFERENCES Sales.Customers(CustID),
);

--DROP TABLE Sales.Products
CREATE TABLE Sales.Products
(
ProductID INT PRIMARY KEY ,
ProductDescription NVARCHAR(60) NOT NULL,
LineItemPrice  FLOAT NOT NULL,
);

--DROP TABLE Sales.Tags
CREATE TABLE Sales.Tags (
  ProductTagsID INT IDENTITY(1,1),
  ProductID INT,
  ProductTags VARCHAR(255) NOT NULL,
  PRIMARY KEY (ProductID, ProductTagsID),
  FOREIGN KEY (ProductID) REFERENCES Sales.Products(ProductID),
);

-- DROP TABLE Sales.Promo;
CREATE TABLE Sales.Promo
(
PromoID INT PRIMARY KEY IDENTITY(101,1),
PromoCode 	NVARCHAR(60) NOT NULL,
DiscountApplied FLOAT NOT NULL,
);

-- DROP TABLE Sales.Orders;
CREATE TABLE Sales.Orders
(
OrderNo  NVARCHAR(90),
CustID INT NOT NULL,
ProductID INT NOT NULL,
PromoID INT NULL,
SaleDate    DATETIME     NOT NULL,
TotalSalePrice FLOAT NOT NULL,
RepeatCustomer	NVARCHAR(3) NULL,
NewTotalSalePrice  FLOAT NOT NULL 
PRIMARY KEY (OrderNo, ProductID),
FOREIGN KEY (CustID) REFERENCES Sales.Customers(CustID),
FOREIGN KEY (ProductID) REFERENCES Sales.Products(ProductID),
FOREIGN KEY (PromoID) REFERENCES Sales.Promo(PromoID),
);


--=======================================  INSERING RECORDS  =========================================

SET IDENTITY_INSERT Sales.Customers ON;
INSERT INTO Sales.Customers(CustID,[CustomerName],[CustomerPhoneNo],[CustomerEmail])
select CustID,
[CustomerName]
,[CustomerPhoneNo]
,[CustomerEmail]
from MessyNormalized.Sales.Customers2NF
WHERE CustomerPhoneNo is NOT NULL 
AND CustomerEmail IS NOT NULL;
SET IDENTITY_INSERT Sales.Customers OFF;

 
INSERT INTO Sales.CustomerAddress
select CustID
,CustomerAddress
,[CustomerCity]
,[CustomerCounty]
,[CustomerPostalCode]
from MessyNormalized.Sales.Customers2NF
WHERE CustomerPhoneNo is NOT NULL 
AND CustomerEmail IS NOT NULL;


INSERT INTO Sales.Products
SELECT DISTINCT
[ProductID]
,[ProductDescription]
,[LineItemPrice]
from MessyNormalized.Sales.Product2NF


--SET IDENTITY_INSERT Sales.Tags ON;
INSERT INTO Sales.Tags
SELECT DISTINCT ProductID, ProductTags
FROM MessyNormalized.Sales.Tags2NF;
--SET IDENTITY_INSERT Sales.Tags OFF;


INSERT INTO Sales.Promo
SELECT DISTINCT PromoCode
,[DiscountAppliedPc]
FROM MessyNormalized.Sales.Orders2NF
WHERE PromoCode IS NOT NULL;


INSERT INTO MessyNormalized.Sales.Orders
	SELECT DISTINCT [OrderNo]
	,CustID
	,ProductID
	,promo.PromoID
	,[SaleDate]
	,[TotalSalePrice]
	,[RepeatCustomer]
	,[NewTotalSalePrice]
	FROM
	Sales.Orders2NF orders
	LEFT JOIN 	Sales.Promo promo
	ON orders.PromoCode = promo.PromoCode
	ORDER BY SaleDate


--======================================  SELECTING RECORDS  ========================================

SELECT * FROM Sales.Customers
SELECT * FROM Sales.CustomerAddress
SELECT * FROM Sales.Products
SELECT * FROM Sales.Tags 
SELECT * FROM Sales.Promo
SELECT * FROM Sales.Orders
