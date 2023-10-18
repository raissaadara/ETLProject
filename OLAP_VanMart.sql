CREATE DATABASE OLAP_VanMart
GO
USE OLAP_VanMart



--DIMENSION TABLE
CREATE TABLE CustomerDimension(
CustomerCode INT PRIMARY KEY IDENTITY(1,1),
CustomerID CHAR(7),
CustomerName VARCHAR(50),
CustomerDOB DATE,
CustomerGender VARCHAR(10),
CustomerPhone VARCHAR(50),
CustomerAddress VARCHAR(50)
)

CREATE TABLE StaffDimension(
StaffCode INT PRIMARY KEY IDENTITY(1,1),
StaffID CHAR(7),
StaffName VARCHAR(50),
StaffDOB DATE,
StaffGender VARCHAR(10),
StaffAddress VARCHAR(50),
StaffPhone VARCHAR(50),
StaffSalary INT,
ValidFrom DATETIME,
ValidTo DATETIME
)

CREATE TABLE GoodsDimension(
GoodsCode INT PRIMARY KEY IDENTITY(1,1),
GoodsID CHAR(7),
GoodsName VARCHAR(50),
GoodsSellingPrice INT,
GoodsBuyingPrice INT,
GoodsWeight INT,
ValidFrom DATETIME,
ValidTo DATETIME
)

CREATE TABLE SupplierDimension(
SupplierCode INT PRIMARY KEY IDENTITY(1,1),
SupplierID CHAR(7),
SupplierName VARCHAR(50),
SupplierAddress VARCHAR(50),
SupplierPhone VARCHAR(50),
SupplierEmail VARCHAR(50),
)

CREATE TABLE BranchDimension(
BranchCode INT PRIMARY KEY IDENTITY(1,1),
BranchID CHAR(7),
BranchAddress VARCHAR(50),
BranchPhone VARCHAR(50),
CityName VARCHAR(50),
)

CREATE TABLE BenefitDimension(
BenefitCode INT PRIMARY KEY IDENTITY(1,1),
BenefitID CHAR(7),
BenefitName VARCHAR(50),
BenefitPrice INT,
BenefitDescription VARCHAR(100),
ValidFrom DATETIME,
ValidTo DATETIME
)

CREATE TABLE TimeDimension(
TimeCode INT PRIMARY KEY IDENTITY(1,1),
[Date] DATE,
[Day] INT,
[Month] INT,
[Year] INT,
[Quarter] INT
)



--FACT TABLE
CREATE TABLE SalesFact(
TimeCode INT,
GoodsCode INT,
StaffCode INT,
CustomerCode INT,
BranchCode INT,
[TotalEarning] BIGINT,
[TotalGoodsSold] BIGINT
)

CREATE TABLE PurchaseFact(
TimeCode INT,
GoodsCode INT,
StaffCode INT, 
BranchCode INT, 
SupplierCode INT, 
[TotalPurchaseCost] BIGINT, 
[TotalGoodsPurchased] BIGINT
)

CREATE TABLE ReturnFact(
TimeCode INT, 
GoodsCode INT, 
StaffCode INT, 
BranchCode INT, 
SupplierCode INT, 
[TotalGoodsReturned] BIGINT, 
[NumberOfStaff] BIGINT
)

CREATE TABLE SubscriptionFact(
TimeCode INT,
CustomerCode INT,
StaffCode INT,
BenefitCode INT,
[TotalSubscriptionEarning] BIGINT,
[NumberOfSubscriber] BIGINT
)

CREATE TABLE FilterTimeStamp(
TableName VARCHAR(255),
LastETL DATETIME
)



--QUERY TimeDimension
IF EXISTS(
	SELECT *
	FROM OLAP_VanMart.dbo.FilterTimeStamp
	WHERE TableName = 'TimeDimension'
	)
BEGIN
	SELECT
		[Date] = X.DATE,
		[Day] = DAY(X.DATE),
		[Month] = MONTH(X.DATE),
		[Year] = YEAR(X.DATE),
		[Quarter] = DATEPART(QUARTER, X.DATE)
	FROM(
		SELECT [Date] = SalesDate
		FROM VanMart.dbo.TrSalesHeader
		UNION
		SELECT [Date] = PurchaseDate
		FROM VanMart.dbo.TrPurchaseHeader
		UNION
		SELECT [Date] = ReturnDate
		FROM VanMart.dbo.TrReturnHeader
		UNION
		SELECT [Date] = SubscriptionStartDate
		FROM VanMart.dbo.TrSubscriptionHeader
		) AS X
	WHERE(
		SELECT LastETL
		FROM OLAP_VanMart.dbo.FilterTimeStamp
		) > X.DATE
END
ELSE
BEGIN
	SELECT
		[Date] = X.DATE,
		[Day] = DAY(X.DATE),
		[Month] = MONTH(X.DATE),
		[Year] = YEAR(X.DATE),
		[Quarter] = DATEPART(QUARTER, X.DATE)
	FROM(
		SELECT [Date] = SalesDate
		FROM VanMart.dbo.TrSalesHeader
		UNION
		SELECT [Date] = PurchaseDate
		FROM VanMart.dbo.TrPurchaseHeader
		UNION
		SELECT [Date] = ReturnDate
		FROM VanMart.dbo.TrReturnHeader
		UNION
		SELECT [Date] = SubscriptionStartDate
		FROM VanMart.dbo.TrSubscriptionHeader
		) AS X
END



--QUERY FilterTimeStamp
IF EXISTS(
	SELECT *
	FROM OLAP_VanMart.dbo.FilterTimeStamp
	WHERE TableName = 'TimeDimension'
	)
BEGIN
	UPDATE OLAP_VanMart.dbo.FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'TimeDimension'
END
ELSE
BEGIN
	INSERT INTO OLAP_VanMart.dbo.FilterTimeStamp
	VALUES('TimeDimension', GETDATE())
END