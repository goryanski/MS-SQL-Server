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
INSERT INTO ProductsTypes VALUES ('Shoes'), ('Clothes'); -- +
GO


CREATE TABLE Manufacturers (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(30)
);
GO
INSERT INTO Manufacturers VALUES -- +
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
INSERT INTO Products VALUES -- +
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
('Ансимова Елизавета Андреевна', '2017-04-22', 10000, 1, 2),
('Беляев Матвей Артёмович', '2016-05-20', 11000, 1, 1),
('Горбушин Виталий Валерьевич', '2017-05-02', 11000, 1, 1),
('Гриненко Алексей Алексеевич', '2018-02-21', 16000, 2, 1),
('Топорова Мария Сергеевна', '2018-09-11', 12000, 1, 2),
('Фазуллина Дина Фанилевна', '2015-04-03', 10000, 1, 2);
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

-- если пользователь не зарегистрирован, мы не знаем его имени, почты и телефона, по этому эти поля будут NULL, но все равно будем вписывать таких покупателей в таблицу для учета покупок и контроля персонала (так персоналу будет тяжелее воровать). К тому же, хоть пользователь  не зарегистрирован, будем записывать в таблицу его пол, для сбора статистики (что бы знать кто какие товары больше покупает, что бы подстраиваться под нужды клиентов и повышать продажи)
INSERT INTO Customers VALUES 
('Честнов Роберт Валентинович', 'delluiza@yandex.ru', '+(380 44) 483 45 90', 3, 1, 1, 1, 0, '2018-05-02'),
('Халитова Рената Булатовна', 'Konfetka13-94@mail.ru', '+(380 322) 295 868', 5, 1, 2, 2, 0, '2018-01-19'),
(NULL, NULL, NULL, 0, 0, 1, NULL, 0, NULL),
('Султанов Миргурбан Миркалиб оглы', 'uglova93@mail.ru', '+(380 44) 537 41 50', 10, 1, 1, 3, 0, '2018-10-18'),
(NULL, NULL, NULL, 0, 0, 1, NULL, 0, NULL),
(NULL, NULL, NULL, 0, 0, 1, NULL, 0, NULL);
GO


-- в этой таблице будет храниться информация обо всех продажах (не зависимо от того, покупку делал зарегистрированный пользователь или нет), а в таблице OrdersHistories будут храниться только истории покупок зарегистрированных пользователей (нет смысла хранить историю покупок для незарегистрированного пользователя, потому что кол-во покупок влияет на процент скидки, а если пользователь не зарегистрирован, то не важно сколько он купит, скидки не будет все равно), по этому не смотря на то что почти все поля одинаковые, таблиц должно быть две
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



-- 1. Хранимая процедура отображает полную информацию о всех товарах
CREATE OR ALTER PROCEDURE sp_showProductsInfo
	AS
BEGIN
	SELECT P.[name], P.amountExists, P.primeCost, P.price, PT.[name] AS type, M.[name] AS Manufacturers  
	FROM Products P
	FULL JOIN ProductsTypes PT ON PT.id = P.typeId
	FULL JOIN Manufacturers M ON M.id = P.ManufacturersId
END
GO

EXEC sp_showProductsInfo
GO

-- 2. Хранимая процедура показывает полную информацию о товаре конкретного вида. Вид товара передаётся в качестве параметра. Например, если в качестве параметра указана обувь, нужно показать всю обувь, которая есть в наличии
CREATE OR ALTER PROCEDURE sp_showProductsInfoByType
		@type NVARCHAR(30)
	AS
BEGIN
	SELECT P.[name], P.amountExists, P.primeCost, P.price, PT.[name] AS type, M.[name] AS Manufacturers  
	FROM Products P
	FULL JOIN ProductsTypes PT ON PT.id = P.typeId
	FULL JOIN Manufacturers M ON M.id = P.ManufacturersId
	WHERE PT.name = @type
END
GO

EXEC sp_showProductsInfoByType 'Shoes'
GO


-- 3. Хранимая процедура показывает топ-3 самых старых клиентов. Топ-3 определяется по дате регистрации
CREATE OR ALTER PROCEDURE sp_showOldestCustomers
	AS
BEGIN
	SELECT TOP(3) C.fullName, C.email, C.phone, S.date
	FROM Customers C
	JOIN Sales S ON C.id = S.id
	WHERE C.isSubscriber = 1
	ORDER BY S.[date]
END
GO

EXEC sp_showOldestCustomers
GO


-- 4. Хранимая процедура показывает информацию о самом успешном продавце. Успешность определяется по общей сумме продаж за всё время
CREATE OR ALTER PROCEDURE sp_showMostSuccessfulSeller
	AS
BEGIN
	SELECT TOP(1) E.fullName, SUM(S.price) AS 'General sales sum'
	FROM Employees E
	JOIN Sales S ON E.id = S.employeeId
	WHERE E.positionId = 1
	GROUP BY E.fullName
	ORDER BY  SUM(S.price) DESC
END
GO

EXEC sp_showMostSuccessfulSeller
GO


-- 5. Хранимая процедура проверяет есть ли хоть один товар указанного производителя в наличии. Название производителя передаётся в качестве параметра. По итогам работы хранимая процедура должна вернуть yes в том случае, если товар есть, и no, если товара нет
CREATE OR ALTER PROCEDURE sp_checkManufacturerProducts
		@name NVARCHAR(20),
		@res NVARCHAR(3) OUTPUT
	AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM Products P
		JOIN Manufacturers M ON M.id = P.ManufacturersId
		WHERE M.[name] = @name
	) SET @res = 'yes';
END
GO

-- вернуть можно только int, по этому вернем результат используя выходные параметры 
DECLARE @result NVARCHAR(3) = 'no';
EXEC sp_checkManufacturerProducts 'AGI', @result OUTPUT;
PRINT @result
GO


-- 6. Хранимая процедура отображает информацию о самом популярном производителе среди покупателей. Популярность среди покупателей определяется по общей сумме продаж
CREATE OR ALTER PROCEDURE sp_showMostPopularManufacturer
	AS
BEGIN
	SELECT TOP(1) M.[name], SUM(S.price) AS 'Total sum of sales'
	FROM Manufacturers M
	JOIN Products P ON M.id = P.ManufacturersId
	JOIN Sales S ON P.id = S.productId
	GROUP BY M.[name]
	ORDER BY SUM(S.price) DESC
END
GO

EXEC sp_showMostPopularManufacturer
GO


-- 7. Хранимая процедура удаляет всех клиентов, зарегистрированных после указанной даты. Дата передаётся в качестве параметра. Процедура возвращает количество удаленных записей.
CREATE OR ALTER PROCEDURE sp_deleteCustomers
		@date DATE
	AS
BEGIN
	UPDATE Customers SET isDeleted = 1
	WHERE registrationDate IS NOT NULL
	AND registrationDate > @date 

	RETURN (
		SELECT COUNT(id)
		FROM Customers
		WHERE registrationDate IS NOT NULL
		AND registrationDate > @date 
	)
END
GO

DECLARE @date DATE = '2018-02-11';
DECLARE @deletedCount INT;
EXEC @deletedCount = sp_deleteCustomers @date
PRINT @deletedCount
GO