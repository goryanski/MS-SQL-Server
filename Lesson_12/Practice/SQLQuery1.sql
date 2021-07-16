USE master
DROP DATABASE BookShop
GO

CREATE DATABASE BookShop
GO

USE BookShop
GO

CREATE TABLE Countries (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(50) NOT NULL CHECK(len([name]) > 0) UNIQUE
);

INSERT INTO Countries VALUES
('Украина'),
('Польша'),
('Германия'),
('Америка'),
('Китай');


CREATE TABLE Authors (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	surname NVARCHAR(MAX) NOT NULL CHECK(len(surname) > 0), 
	countryId INT,
	FOREIGN KEY (countryId) REFERENCES Countries(id)
);

INSERT INTO Authors VALUES
('Елизавета', 'Ансимова', 1),
('Матвей', 'Беляев', 4),
('Виталий', 'Горбушин', 5),
('Алексей', 'Гриненко', 2),
('Мария', 'Топорова', 3),
('Дина', 'Фазуллина', 1);

CREATE TABLE Themes (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);

INSERT INTO Themes VALUES
('Природа'),
('Животные'),
('Психология'),
('Философия'),
('Наука');

CREATE TABLE Books (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	pages INT NOT NULL CHECK(pages >= 1),
	price MONEY NOT NULL CHECK(price >= 0),
	publishDate DATE NOT NULL CHECK(publishDate <= GETDATE()),
	authorId INT,
	FOREIGN KEY (authorId) REFERENCES Authors(id),
	themeId INT,
	FOREIGN KEY (themeId) REFERENCES Themes(id),
	isDeleted BIT NOT NULL
);

INSERT INTO Books VALUES
('Небо', 455, 200, '2020-11-02', 2, 1, 0),
('Бронзовый ключ', 477, 100, '2010-12-22', 1, 2, 0),
('Похитители снов', 866, 400, '2019-11-04', 3, 3, 0),
('Красный смех', 755, 200, '2017-04-07', 4, 4, 0),
('Поднятая целина', 555, 300, '2016-09-11', 6, 5, 0);
INSERT INTO Books VALUES
('Ночь', 1000, 450, '2019-11-04', 3, 3, 0);

CREATE TABLE Shops (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	countryId INT,
	FOREIGN KEY (countryId) REFERENCES Countries(id)
);

INSERT INTO Shops VALUES
('Libreria El Pendulo', 2),
('Поларе', 3),
('Детская республика', 5),
('Книжный магазин Барта', 4),
('Ler Devagar', 1);

CREATE TABLE Sales (
	id INT PRIMARY KEY IDENTITY,
	price MONEY NOT NULL CHECK(price >= 0),
	quantity INT NOT NULL CHECK(quantity >= 1),
	saleDate DATE NOT NULL CHECK(saleDate <= GETDATE()) DEFAULT GETDATE(),
	bookId INT,
	FOREIGN KEY (bookId) REFERENCES Books(id),
	shopId INT,
	FOREIGN KEY (shopId) REFERENCES Shops(id)
);

INSERT INTO Sales VALUES
(1000, 5, '2020-12-04', 1, 2),
(500, 5, '2020-12-04', 2, 3),
(800, 2, '2020-12-05', 3, 4),
(600, 3, '2020-12-06', 4, 1),
(300, 1, '2020-12-07', 5, 5);
GO



-- 1. Показать все книги, количество страниц в которых больше 500, но меньше 650.
CREATE OR ALTER VIEW NormalCountPages 
AS
	SELECT * 
	FROM Books
	WHERE pages BETWEEN 500 AND 650
GO

SELECT * FROM NormalCountPages
GO

-- 2. Показать все книги, в которых первая буква названия либо «А», либо «З».
CREATE OR ALTER VIEW ShowBooks 
AS
	SELECT * 
	FROM Books
	WHERE [name] LIKE'А%' OR [name] LIKE'3%'
GO

SELECT * FROM ShowBooks
GO

-- 3. Показать все книги жанра «Детектив», количество проданных книг более 30 экземпляров.
CREATE OR ALTER VIEW PopularDetectiveBooks 
AS
	SELECT B.[name] AS 'Book name', 
		T.[name] AS 'Genre', 
		S.quantity AS 'Amount of Sold'
	FROM Books B
	JOIN Themes T ON T.id = B.themeId
	JOIN Sales S ON B.id = S.bookId
	WHERE T.[name] = 'Детектив' AND S.quantity > 30
GO

SELECT * FROM PopularDetectiveBooks
GO



-- 4. Показать все книги, в названии которых есть слово «Microsoft», но нет слова «Windows».
CREATE OR ALTER VIEW NormalCountPages 
AS
	SELECT * 
	FROM Books
	WHERE [name] LIKE '%Microsoft%' AND [name] NOT LIKE '%Windows%'
GO

SELECT * FROM NormalCountPages
GO



-- 5. Показать все книги (название, тематика, полное имя автора в одной ячейке), цена одной страницы которых меньше 65 копеек
CREATE OR ALTER FUNCTION GetPagePrice(@bookPrice MONEY, @pagesCount INT)
RETURNS FLOAT
AS
BEGIN
	RETURN @bookPrice / @pagesCount
END
GO

CREATE OR ALTER FUNCTION ShowCheapBooks()
RETURNS TABLE
AS
RETURN (
	SELECT B.[name] + ' (' + T.[name] + ') ' + A.[name] + ' ' +  A.surname AS 'Cheap Books'
	FROM Books B
	JOIN Themes T ON T.id = B.themeId
	JOIN Authors A ON A.id = B.authorId
	WHERE dbo.GetPagePrice(price, pages) <  0.65
)
GO

SELECT * FROM ShowCheapBooks();
GO

-- 6. Показать все книги, название которых состоит из 4 слов
CREATE OR ALTER FUNCTION ShowLongNamebooks()
RETURNS TABLE
AS
RETURN (
	SELECT * 
	FROM Books
	WHERE [name] LIKE'% % % %'
)
GO

SELECT * FROM ShowLongNamebooks();
GO

-- 7. Показать информацию о продажах в следующем виде:
-- ▷ Название книги, но, чтобы оно не содержало букву «А».
-- ▷ Тематика, но, чтобы не «Программирование».
-- ▷ Автор, но, чтобы не «Герберт Шилдт».
-- ▷ Цена, но, чтобы в диапазоне от 10 до 20 гривен.
-- ▷ Количество продаж, но не менее 8 книг.
-- ▷ Название магазина, который продал книгу, но он не должен быть в Украине или России.
CREATE OR ALTER FUNCTION ShowSalesInfo()
RETURNS TABLE
AS
RETURN (
	SELECT 
		B.[name] AS 'Book name',
		T.[name] AS Ganre,
		A.[name] AS 'Book author',
		B.price,
		S.quantity,
		Sh.[name] AS 'Shop name'
	FROM Sales S
		JOIN Books B ON B.id = S.bookId
		JOIN Themes T ON T.id = B.themeId
		JOIN Authors A ON A.id = B.authorId
		JOIN Shops Sh ON Sh.id = S.shopId
		JOIN Countries C ON C.id = Sh.countryId
	WHERE B.[name] NOT LIKE '%А%'
		AND T.[name] != 'Программирование'
		AND A.[name] ! = 'Герберт Шилдт'
		AND B.price BETWEEN 10 AND 20
		AND S.quantity >= 8 
		AND C.[name] != 'Украина' AND C.[name] != 'Россия'
)
GO

SELECT * FROM ShowSalesInfo();
GO



-- 8. Показать следующую информацию в два столбца (числа в правом столбце приведены в качестве примера):
-- ▷ Количество авторов: 14
-- ▷ Количество книг: 47
-- ▷ Средняя цена продажи: 85.43 грн.
-- ▷ Среднее количество страниц: 650.6.
CREATE OR ALTER FUNCTION GetAuthorsCount()
RETURNS TABLE
AS
RETURN (
	SELECT 'Количество авторов:' AS Note, COUNT(id) AS 'Value'
	FROM Authors
)
GO

SELECT * FROM GetAuthorsCount();
GO

--
CREATE OR ALTER FUNCTION GetBooksCount()
RETURNS TABLE
AS
RETURN (
	SELECT 'Количество книг:' AS Note, COUNT(id) AS 'Value'
	FROM Books
)
GO

SELECT * FROM GetBooksCount();
GO

--
CREATE OR ALTER FUNCTION GetAvgPrice()
RETURNS TABLE
AS
RETURN (
	SELECT 'Средняя цена продажи:' AS Note, AVG(price) AS 'Value'
	FROM Sales
)
GO

SELECT * FROM GetAvgPrice();
GO

--
CREATE OR ALTER FUNCTION GetAvgPagesCount()
RETURNS TABLE
AS
RETURN (
	SELECT 'Среднее количество страниц:' AS Note, AVG(pages) AS 'Value'
	FROM Books
)
GO

SELECT * FROM GetAvgPagesCount();
GO


-- 9. Показать тематики книг и сумму страниц всех книг по каждой из них.
CREATE OR ALTER VIEW BooksByGenres 
AS
	SELECT 
		T.[name] AS 'Genre', 
		SUM(B.pages) AS 'Sum of pages by genre' 
	FROM Books B
	JOIN Themes T ON T.id = B.themeId
	GROUP BY T.[name]
GO

SELECT * FROM BooksByGenres
GO



-- 10. Показать количество всех книг и сумму страниц этих книг по каждому из авторов.
CREATE OR ALTER VIEW BooksByAuthors
AS
	SELECT 
		A.[name] + ' ' + A.surname AS 'Author name', 
		COUNT(B.id) AS 'Books count', 
		SUM(B.pages) AS 'General Sum of pages'
	FROM Books B
	JOIN Authors A ON A.id = B.authorId
	GROUP BY A.[name] + ' ' + A.surname
GO

SELECT * FROM BooksByAuthors
GO


-- 11. Показать книгу тематики «Программирование» с наибольшим количеством страниц.
CREATE OR ALTER VIEW MostFatBook
AS
	SELECT TOP(1) B.[name], B.pages
	FROM Books B
	JOIN Themes T ON T.id = B.themeId
	WHERE T.[name] = 'Программирование'
	ORDER BY B.pages DESC
GO

SELECT * FROM MostFatBook
GO


-- 12. Показать среднее количество страниц по каждой тематике, которое не превышает 400.
CREATE OR ALTER VIEW AvgPagesCountByGenres 
AS
	SELECT 
		T.[name] AS 'Genre', 
		AVG(B.pages) AS 'Sum of pages by genre' 
	FROM Books B
	JOIN Themes T ON T.id = B.themeId
	GROUP BY T.[name]
	HAVING AVG(B.pages) <= 400
GO

SELECT * FROM AvgPagesCountByGenres
GO


--13. Показать сумму страниц по каждой тематике, учитывая только книги с количеством страниц более 400, и чтобы тематики были «Программирование», «Администрирование» и «Дизайн».
CREATE OR ALTER VIEW AvgPagesCountByGenres 
AS
	SELECT 
		T.[name] AS 'Genre', 
		SUM(B.pages) AS 'Sum of pages by genre' 
	FROM Books B
	JOIN Themes T ON T.id = B.themeId
	WHERE B.pages >= 400
		AND T.[name] IN ('Программирование', 'Администрирование','Дизайн')
	GROUP BY T.[name]
GO

SELECT * FROM AvgPagesCountByGenres
GO


-- 14. Показать информацию о работе магазинов: что, где, кем, когда и в каком количестве было продано.
CREATE OR ALTER FUNCTION ShowShopsInfo()
RETURNS TABLE
AS
RETURN (
		SELECT 
		Sh.[name] AS 'Name of shop, which sold',
		B.[name] + ' (' + T.[name] + ')' AS 'What was sold',
		S.saleDate AS 'When was sold',
		S.quantity AS 'Quantity of sold',
		C.[name] AS 'Where was sold'
	FROM Sales S
		JOIN Books B ON B.id = S.bookId
		JOIN Themes T ON T.id = B.themeId
		JOIN Authors A ON A.id = B.authorId
		JOIN Shops Sh ON Sh.id = S.shopId
		JOIN Countries C ON C.id = Sh.countryId
)
GO

SELECT * FROM ShowShopsInfo();
GO
	


-- 15. Показать самый прибыльный магазин.
CREATE OR ALTER FUNCTION ShowMostProfitableShop()
RETURNS TABLE
AS
RETURN (
	SELECT TOP(1) Sh.[name], SUM(S.price) AS 'General profit'
	FROM Sales S
		JOIN Shops Sh ON Sh.id = S.shopId
	GROUP BY Sh.[name] 
	ORDER BY SUM(S.price) DESC
)
GO

SELECT * FROM ShowMostProfitableShop();
GO


SELECT * FROM Books ORDER BY price DESC





-- осуществим регистрацию
create table People (
	id int primary key identity,
	firstName nvarchar(30) NOT NULL,
	lastName nvarchar(30) NOT NULL,
	birth date NOT NULL
);
go

create table Accounts (
	id int primary key identity,
	[login] varchar(30) NOT NULL unique,
	[password] varchar(30) NOT NULL,
	regDate date default getdate()
);
go

alter table People add accountId int;
alter table People add constraint fk_people_account_id_accounts foreign key (accountId) references Accounts (id);

--insert into People (firstName, lastName, birth) values 
--('First name 1', 'Last name 1', '1990-10-20'),
--('First name 2', 'Last name 2', '1988-2-11'),
--('First name 3', 'Last name 3', '1995-3-26'),
--('First name 4', 'Last name 4', '1978-8-6');
--go
--insert into People (firstName, lastName, birth) values ('First name 6', 'Last name 6', '2000-10-1')
--go

select * from People;
select * from Accounts;

--drop table People
--drop table Accounts
GO

create or alter procedure sp_Registration
		@login varchar(30),
		@pasword varchar(30),
		@firstName nvarchar(30),
		@lastName nvarchar(30),
		@birth date
	as
begin
	INSERT INTO Accounts ([login], [password]) VALUES (@login, @pasword); 
	INSERT INTO People VALUES (@firstName, @lastName, @birth, @@IDENTITY);
end
go



-- вызов процедуры
exec sp_Registration 'vasya_2020', '123456', 'Vasya', 'Pupkin', '2000-10-10';
go


SELECT * FROM Accounts WHERE [login] = 'vasya_2020'  AND [password] = '123456'

select * from Books


-- full books info
SELECT B.[name], B.price, B.pages, B.publishDate, T.[name] AS 'theme', A.[name] + ' ' +  A.surname AS 'author'
	FROM Books B
	JOIN Themes T ON T.id = B.themeId
	JOIN Authors A ON A.id = B.authorId
	WHERE B.id = 2


UPDATE Books 
SET [name] = 'updated name', 
	pages = 444, 
	price = 444, 
	publishDate = '2020-03-03', 
	authorId = 1, 
	themeId = 1 
WHERE id = 7


SELECT COUNT(id) FROM Accounts WHERE login = 'Iva__2' AND password = 12345

DELETE People WHERE id = 1