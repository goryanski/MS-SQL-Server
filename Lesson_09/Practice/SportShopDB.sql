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




--1. При продаже товара, заносить информацию о продаже в таблицу «История». Таблица «История» используется для дубляжа информации о всех продажах
CREATE TABLE History (
	id INT PRIMARY KEY IDENTITY,
	[date] DATE,
	price MONEY,
	amount INT,
	employeeId INT,
	-- так же создадим связи, что бы при необходимости можно было и с этой таблицы получить дополнительную инфо типа имя продавца
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

-- после покупки будем вставляем информацию о покупке в таблицу Sales, и в это время при срабатывании триггера информация будет дублироваться в таблицу History
INSERT INTO Sales VALUES ('2019-03-04', 400, 1, 1, 1, 1);
GO



-- 2. Если после продажи товара не осталось ни одной единицы данного товара, необходимо перенести информацию о полностью проданном товаре в таблицу «Архив»
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


-- процедура, которая записывает полную информацию о проданном  продукте в таблицу Archive
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

-- Когда продаеся товар, вся информация о нем вставляется в таблицу Sales, сразу же после этого срабатывает триггер, который в таблице продуктов у проданного продукта отнимает единицу от кол-ва этого продукта (кол-во оставшегося на складе продукта), и после этого происходит проверка: если после вычитания единицы осталось 0 продуктов, то вызываем процедуру, которая записывает полную информацию об этом продукте в таблицу Archive
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



-- 3. Не позволять регистрировать уже существующего клиента. При вставке проверять наличие клиента по ФИО и email
CREATE TABLE RegistratedCustomers (
	id INT PRIMARY KEY IDENTITY,
	-- при регистрации в эту таблицу будут попадать покупатели. достаточно указать тут только id, потому что в таблице Customers есть вся информация, нет смысла дублировать 
	customerId INT,
	FOREIGN KEY (customerId) REFERENCES Customers(id)
);
GO

-- поскольу у нас в таблице RegistratedCustomers хранятся только customerId, то нет смысла проверять наличие клиента по ФИО и email, если можно проверить только по id
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



-- 4. Запретить удаление существующих клиентов
CREATE OR ALTER TRIGGER NoDelete
ON Customers INSTEAD OF DELETE
AS
	PRINT 'You cannot delete customers'
GO

-- проверка
DELETE Customers WHERE id = 1
SELECT * FROM Customers
GO


-- 5. Запретить удаление сотрудников, принятых на работу до 2015 года
CREATE OR ALTER TRIGGER NoDeleteEmployees
ON Employees INSTEAD OF DELETE
AS
	DECLARE @date DATE = (select [date] from deleted);
	IF @date < '2015-01-01'
		PRINT 'You cannot delete old employees'	
	ELSE
		DELETE Employees WHERE id = (select id from deleted)
GO

-- для проверки
INSERT INTO Employees VALUES 
('ttt tttt tttt', '2014-04-22', 1000, 1, 2);
SELECT * FROM Employees
DELETE Employees WHERE id = 8
GO


-- 6. При новой покупке товара нужно проверять общую сумму покупок клиента. Если сумма превысила 50000 грн, необходимо установить процент скидки в 15%
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

-- Перед вставкой в таблицу Sales проверим, можно ли повышать покупателю размер скидки и если да то повысим
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

-- Проверочная таблица (для общей суммы покупок)
SELECT C.id, C.fullName, C.discount, SUM(OH.price) AS 'Total spent sum', COUNT(OH.price) AS 'Products amount'
FROM OrdersHistories OH
JOIN Customers C ON OH.id = C.orderHistoryId
JOIN Sales S ON C.id = S.customerId
GROUP BY C.fullName, C.id, C.discount
GO


-- 7. Запретить добавлять товар конкретной фирмы. Например, товар фирмы «Спорт, солнце и штанга»
CREATE OR ALTER TRIGGER NotAddProduct
ON Products INSTEAD OF INSERT
AS
BEGIN
	DECLARE @prohibitedFirm NVARCHAR(30) = 'Спорт, солнце и штанга';

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



-- 8. При продаже проверять количество товара в наличии. Если осталась одна единица товара, необходимо внести информацию об этом товаре в таблицу «Последняя Единица».
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
