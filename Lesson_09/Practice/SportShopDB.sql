USE master
DROP DATABASE SportShopDB
GO

CREATE DATABASE SportShopDB
GO

USE SportShopDB
GO

CREATE TABLE ProductsTypes (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(30)
);
GO
INSERT INTO ProductsTypes VALUES ('Shoes'), ('Clothes'); 
GO


CREATE TABLE Manufacturers (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(30)
);
GO
INSERT INTO Manufacturers VALUES 
('ABAK'),
('ADILISIK'),
('AFRODIT'),
('AGI');
GO


CREATE TABLE Products (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(30),
	amountExists INT,
	primeCost MONEY,
	price MONEY,
	typeId INT,
	FOREIGN KEY (typeId) REFERENCES ProductsTypes(id),
	ManufacturersId INT,
	FOREIGN KEY (ManufacturersId) REFERENCES Manufacturers(id)
);
GO
INSERT INTO Products VALUES 
('Sneakers', 10, 200, 400, 1, 1),
('T-shirt', 40, 70, 250, 2, 2),
('Slippers', 11, 50, 150, 1, 1),
('Tracksuit', 10, 600, 1900, 2, 3),
('Jacket', 15, 800, 3000, 2, 4),
('Ski outfit', 25, 2000, 4500, 2, 4);
GO


CREATE TABLE EmployeesPositions (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(30)
);
GO
INSERT INTO EmployeesPositions VALUES ('Saller'), ('Manager');
GO


CREATE TABLE Genders (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(10)
);
GO
INSERT INTO Genders VALUES ('Male'), ('Female');
GO


CREATE TABLE Employees (
	id INT PRIMARY KEY IDENTITY,
	fullName NVARCHAR(50),
	[date] DATE,
	salary MONEY,
	positionId INT,
	FOREIGN KEY (positionId) REFERENCES EmployeesPositions(id),
	genderId INT,
	FOREIGN KEY (genderId) REFERENCES Genders(id)
);
GO

INSERT INTO Employees VALUES 
('�������� ��������� ���������', '2017-04-22', 10000, 1, 2),
('������ ������ ��������', '2016-05-20', 11000, 1, 1),
('�������� ������� ����������', '2017-05-02', 11000, 1, 1),
('�������� ������� ����������', '2018-02-21', 16000, 2, 1),
('�������� ����� ���������', '2018-09-11', 12000, 1, 2),
('��������� ���� ���������', '2015-04-03', 10000, 1, 2);
GO


CREATE TABLE OrdersHistories (
	id INT PRIMARY KEY IDENTITY,
	[date] DATE,
	price MONEY,
	amount INT,
	employeeId INT,
	FOREIGN KEY (employeeId) REFERENCES Employees(id),
	productId INT,
	FOREIGN KEY (productId) REFERENCES Products(id),
);
GO
INSERT INTO OrdersHistories VALUES
('2019-05-02', 400, 1, 1, 1),
('2019-04-12', 1000, 4, 5, 2),
('2019-10-18', 6000, 2, 6, 5);
GO


CREATE TABLE Customers (
	id INT PRIMARY KEY IDENTITY,
	fullName NVARCHAR(50),
	email VARCHAR(30),
	phone VARCHAR(30),
	discount INT,
	isSubscriber BIT,
	genderId INT,
	FOREIGN KEY (genderId) REFERENCES Genders(id),
	orderHistoryId INT,
	FOREIGN KEY (orderHistoryId) REFERENCES OrdersHistories(id),
	isDeleted BIT,
	registrationDate DATE
);
GO

-- ���� ������������ �� ���������������, �� �� ����� ��� �����, ����� � ��������, �� ����� ��� ���� ����� NULL, �� ��� ����� ����� ��������� ����� ����������� � ������� ��� ����� ������� � �������� ��������� (��� ��������� ����� ������� ��������). � ���� ��, ���� ������������  �� ���������������, ����� ���������� � ������� ��� ���, ��� ����� ���������� (��� �� ����� ��� ����� ������ ������ ��������, ��� �� �������������� ��� ����� �������� � �������� �������)
INSERT INTO Customers VALUES 
('������� ������ ������������', 'delluiza@yandex.ru', '+(380 44) 483 45 90', 3, 1, 1, 1, 0, '2018-05-02'),
('�������� ������ ���������', 'Konfetka13-94@mail.ru', '+(380 322) 295 868', 5, 1, 2, 2, 0, '2018-01-19'),
(NULL, NULL, NULL, 0, 0, 1, NULL, 0, NULL),
('�������� ��������� �������� ����', 'uglova93@mail.ru', '+(380 44) 537 41 50', 10, 1, 1, 3, 0, '2018-10-18'),
(NULL, NULL, NULL, 0, 0, 1, NULL, 0, NULL),
(NULL, NULL, NULL, 0, 0, 1, NULL, 0, NULL);
GO


-- � ���� ������� ����� ��������� ���������� ��� ���� �������� (�� �������� �� ����, ������� ����� ������������������ ������������ ��� ���), � � ������� OrdersHistories ����� ��������� ������ ������� ������� ������������������ ������������� (��� ������ ������� ������� ������� ��� ��������������������� ������������, ������ ��� ���-�� ������� ������ �� ������� ������, � ���� ������������ �� ���������������, �� �� ����� ������� �� �����, ������ �� ����� ��� �����), �� ����� �� ������ �� �� ��� ����� ��� ���� ����������, ������ ������ ���� ���
CREATE TABLE Sales (
	id INT PRIMARY KEY IDENTITY,
	[date] DATE,
	price MONEY,
	amount INT,
	employeeId INT,
	FOREIGN KEY (employeeId) REFERENCES Employees(id),
	productId INT,
	FOREIGN KEY (productId) REFERENCES Products(id),
	customerId INT,
	FOREIGN KEY (customerId) REFERENCES Customers(id)
);
GO
INSERT INTO Sales VALUES
('2019-05-02', 400, 1, 1, 1, 1),
('2019-04-12', 1000, 4, 5, 2, 2),
('2019-10-18', 6000, 2, 6, 5, 4),
('2019-05-12', 150, 1, 2, 3, 3),
('2019-01-17', 400, 1, 2, 1, 5),
('2019-01-19', 4500, 1, 4, 6, 6);
GO




--1. ��� ������� ������, �������� ���������� � ������� � ������� ���������. ������� ��������� ������������ ��� ������� ���������� � ���� ��������
CREATE TABLE History (
	id INT PRIMARY KEY IDENTITY,
	[date] DATE,
	price MONEY,
	amount INT,
	employeeId INT,
	-- ��� �� �������� �����, ��� �� ��� ������������� ����� ���� � � ���� ������� �������� �������������� ���� ���� ��� ��������
	FOREIGN KEY (employeeId) REFERENCES Employees(id),
	productId INT,
	FOREIGN KEY (productId) REFERENCES Products(id),
	customerId INT,
	FOREIGN KEY (customerId) REFERENCES Customers(id)
);
GO

CREATE OR ALTER TRIGGER AfterSale 
ON Sales AFTER INSERT
AS
	INSERT INTO History SELECT [date], price, amount, employeeId, productId, customerId FROM inserted
GO

-- ����� ������� ����� ��������� ���������� � ������� � ������� Sales, � � ��� ����� ��� ������������ �������� ���������� ����� ������������� � ������� History
INSERT INTO Sales VALUES ('2019-03-04', 400, 1, 1, 1, 1);
GO



-- 2. ���� ����� ������� ������ �� �������� �� ����� ������� ������� ������, ���������� ��������� ���������� � ��������� ��������� ������ � ������� ������
CREATE TABLE Archive (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(30),
	amountExists INT,
	primeCost MONEY,
	price MONEY,
	[type] NVARCHAR(30),
	manufacturer NVARCHAR(30)
);
GO


-- ���������, ������� ���������� ������ ���������� � ���������  �������� � ������� Archive
CREATE OR ALTER PROCEDURE sp_fillArchive
		@id INT
	AS
BEGIN
	INSERT INTO Archive SELECT P.[name], P.amountExists, P.primeCost, P.price, PT.[name], M.[name]
	FROM Products P
	FULL JOIN ProductsTypes PT ON PT.id = P.typeId
	FULL JOIN Manufacturers M ON M.id = P.ManufacturersId
	WHERE P.id = @id
END
GO

-- ����� �������� �����, ��� ���������� � ��� ����������� � ������� Sales, ����� �� ����� ����� ����������� �������, ������� � ������� ��������� � ���������� �������� �������� ������� �� ���-�� ����� �������� (���-�� ����������� �� ������ ��������), � ����� ����� ���������� ��������: ���� ����� ��������� ������� �������� 0 ���������, �� �������� ���������, ������� ���������� ������ ���������� �� ���� �������� � ������� Archive
CREATE OR ALTER TRIGGER OutOfStock
ON Sales AFTER INSERT
AS
BEGIN
	DECLARE @selectedId INT = (SELECT productId FROM inserted)
	UPDATE Products SET  amountExists -= 1 WHERE id = @selectedId

	IF ((SELECT amountExists FROM Products WHERE id = @selectedId) = 0)
		EXEC sp_fillArchive @selectedId
END
GO
INSERT INTO Sales VALUES ('2019-11-11', 400, 1, 1, 1, 1);
GO



-- 3. �� ��������� �������������� ��� ������������� �������. ��� ������� ��������� ������� ������� �� ��� � email
CREATE TABLE RegistratedCustomers (
	id INT PRIMARY KEY IDENTITY,
	-- ��� ����������� � ��� ������� ����� �������� ����������. ���������� ������� ��� ������ id, ������ ��� � ������� Customers ���� ��� ����������, ��� ������ ����������� 
	customerId INT,
	FOREIGN KEY (customerId) REFERENCES Customers(id)
);
GO

-- �������� � ��� � ������� RegistratedCustomers �������� ������ customerId, �� ��� ������ ��������� ������� ������� �� ��� � email, ���� ����� ��������� ������ �� id
CREATE OR ALTER FUNCTION CheckId(@id INT)
RETURNS BIT
AS
BEGIN
	RETURN (SELECT COUNT(*) FROM RegistratedCustomers WHERE customerId = @id)
END
GO


CREATE OR ALTER TRIGGER CustomerRegistration
ON RegistratedCustomers INSTEAD OF INSERT
AS 
BEGIN
	DECLARE @id INT = (SELECT customerId FROM inserted);
	IF dbo.CheckId(@id) = 0
		INSERT INTO RegistratedCustomers VALUES (@id);
END
GO



-- 4. ��������� �������� ������������ ��������
CREATE OR ALTER TRIGGER NoDelete
ON Customers INSTEAD OF DELETE
AS
	PRINT 'You cannot delete customers'
GO

-- ��������
DELETE Customers WHERE id = 1
SELECT * FROM Customers
GO


-- 5. ��������� �������� �����������, �������� �� ������ �� 2015 ����
CREATE OR ALTER TRIGGER NoDeleteEmployees
ON Employees INSTEAD OF DELETE
AS
	DECLARE @date DATE = (select [date] from deleted);
	IF @date < '2015-01-01'
		PRINT 'You cannot delete old employees'	
	ELSE
		DELETE Employees WHERE id = (select id from deleted)
GO

-- ��� ��������
INSERT INTO Employees VALUES 
('ttt tttt tttt', '2014-04-22', 1000, 1, 2);
SELECT * FROM Employees
DELETE Employees WHERE id = 8
GO


-- 6. ��� ����� ������� ������ ����� ��������� ����� ����� ������� �������. ���� ����� ��������� 50000 ���, ���������� ���������� ������� ������ � 15%
CREATE OR ALTER FUNCTION CheckTotalSum(@id INT)
RETURNS BIT
AS
BEGIN
	DECLARE @discountSum MONEY = 50000;
	DECLARE @selectedSum MONEY = (
		SELECT SUM(OH.price)
		FROM OrdersHistories OH
		JOIN Customers C ON OH.id = C.orderHistoryId
		JOIN Sales S ON C.id = S.customerId
		GROUP BY C.id
		HAVING C.id = @id
	);

	DECLARE @res BIT = 0;
	IF (@selectedSum > @discountSum) SET @res = 1
	RETURN @res
END
GO

-- ����� �������� � ������� Sales ��������, ����� �� �������� ���������� ������ ������ � ���� �� �� �������
CREATE OR ALTER TRIGGER GetDiscount
ON Sales INSTEAD OF INSERT
AS
BEGIN
	DECLARE @id INT = (SELECT customerId FROM inserted);
	IF dbo.CheckTotalSum(@id) = 1
		UPDATE Customers SET discount = 15;

	INSERT INTO Sales SELECT [date], price, amount, employeeId, productId, customerId FROM inserted
END
GO

-- ����������� ������� (��� ����� ����� �������)
SELECT C.id, C.fullName, C.discount, SUM(OH.price) AS 'Total spent sum', COUNT(OH.price) AS 'Products amount'
FROM OrdersHistories OH
JOIN Customers C ON OH.id = C.orderHistoryId
JOIN Sales S ON C.id = S.customerId
GROUP BY C.fullName, C.id, C.discount
GO


-- 7. ��������� ��������� ����� ���������� �����. ��������, ����� ����� ������, ������ � ������
CREATE OR ALTER TRIGGER NotAddProduct
ON Products INSTEAD OF INSERT
AS
BEGIN
	DECLARE @prohibitedFirm NVARCHAR(30) = '�����, ������ � ������';

	DECLARE @selectedFirm NVARCHAR(30) = (
		SELECT [name]
		FROM Manufacturers
		WHERE id = (SELECT ManufacturersId FROM inserted)
	);

	IF @selectedFirm = @prohibitedFirm
		PRINT 'You cannot add product of such firm'
	ELSE 
		INSERT INTO Products SELECT [name], amountExists, primeCost, price, typeId, ManufacturersId 
		FROM inserted
END
GO



-- 8. ��� ������� ��������� ���������� ������ � �������. ���� �������� ���� ������� ������, ���������� ������ ���������� �� ���� ������ � ������� ���������� �������.
CREATE TABLE LastItem (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(30),
	amountExists INT,
	primeCost MONEY,
	price MONEY,
	[type] NVARCHAR(30),
	manufacturer NVARCHAR(30)
);
GO


CREATE OR ALTER PROCEDURE sp_fillLastItemTable
		@id INT
	AS
BEGIN
	INSERT INTO LastItem SELECT P.[name], P.amountExists, P.primeCost, P.price, PT.[name], M.[name]
	FROM Products P
	FULL JOIN ProductsTypes PT ON PT.id = P.typeId
	FULL JOIN Manufacturers M ON M.id = P.ManufacturersId
	WHERE P.id = @id
END
GO


CREATE OR ALTER TRIGGER LastItemLeft
ON Sales AFTER INSERT
AS
BEGIN
	DECLARE @selectedId INT = (SELECT productId FROM inserted)
	UPDATE Products SET  amountExists -= 1 WHERE id = @selectedId

	IF ((SELECT amountExists FROM Products WHERE id = @selectedId) = 1)
		EXEC sp_fillLastItemTable @selectedId
END
GO
INSERT INTO Sales VALUES ('2019-11-11', 400, 1, 1, 1, 1);
GO
