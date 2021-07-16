USE AcademyDB;
GO

-- Создание таблиц
CREATE TABLE Departments(
	id INT PRIMARY KEY IDENTITY,
	financing MONEY NOT NULL CHECK(financing >= 0) DEFAULT 0,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO

CREATE TABLE Faculties(
	id INT PRIMARY KEY IDENTITY,
	dean NVARCHAR(MAX) NOT NULL CHECK(len(dean) > 0),
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO

CREATE TABLE Groups(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(10) NOT NULL CHECK(len([name]) > 0) UNIQUE,
	rating INT NOT NULL CHECK(rating >= 0 AND rating <= 5),
	[year] INT NOT NULL CHECK([year] >= 1 AND [year] <= 5)
);
GO

CREATE TABLE Teachers(
	id INT PRIMARY KEY IDENTITY,
	employmentDate DATE NOT NULL CHECK(employmentDate >= '1990-01-01'),
	isAssistant BIT NOT NULL DEFAULT 0,
	isProfessor BIT NOT NULL DEFAULT 0,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	position NVARCHAR(MAX) NOT NULL CHECK(len(position) > 0),
	premium MONEY NOT NULL CHECK(premium >= 0) DEFAULT 0,
	salary MONEY NOT NULL CHECK(salary > 0),
	surname NVARCHAR(MAX) NOT NULL CHECK(len(surname) > 0)
);
GO


-- Заполнение таблиц данными 
INSERT INTO Departments VALUES
(18000, 'Программирование'),
(7000, 'Журналистика'),
(15000, 'Математика');

INSERT INTO Faculties VALUES
('Сидоров А.С.', 'Компьютерных наук и инжененрии'),
('Михайлов Л.С.', 'Иностанных языков'),
('Леонова А.И.', 'Механический');

INSERT INTO Groups VALUES
('1-МС-10', 5, 1),
('2-АПВ-12', 4, 2),
('4-ЕМ-11', 3, 4);

INSERT INTO Teachers VALUES
('1990-01-17', 0, 0, 'Тамара', 'Учитель математики', 2000, 10000, 'Валериевна'),
('1995-03-11', 1, 0, 'Максим', 'Учитель английского языка', 4000, 15000, 'Юриевич'),
('1998-05-20', 0, 1, 'Анатолий', 'Учитель физики', 1000, 10000, 'Иванович');


-- Выборки 
--  1. Вывести таблицу кафедр, но расположить ее поля в обратном порядке. 
SELECT * FROM Departments ORDER BY id DESC;

-- 2. Вывести названия групп и их рейтинги, используя в качестве названий выводимых полей “Group Name” и “Group Rating” соответственно.
SELECT Groups.[name] AS 'Group Name', 
	Groups.rating AS 'Group Rating' 
	FROM Groups;


--  3. Вывести для преподавателей их фамилию, процент ставки по отношению к надбавке и процент ставки по отношению к зарплате (сумма ставки и надбавки).
SELECT 'Фамилия [' + Teachers.surname + '], 
процент ставки по отношению к надбавке
[' + CONVERT(nvarchar(20), Teachers.salary / Teachers.premium * 100) + '%], 
процент ставки по отношению к зарплате 
[' + CONVERT(nvarchar(20), Teachers.salary / (Teachers.premium + Teachers.salary) * 100) + '%]' 
AS 'Percents'
FROM Teachers;


--  4. Вывести таблицу факультетов в виде одного поля в следующем формате: “The dean of faculty [faculty] is [dean].”.
SELECT 'The dean of faculty  [' + Faculties.[name] + '] is
[' + Faculties.dean + ']' AS 'FacultiesDeans'
FROM Faculties;


-- 5. Вывести фамилии преподавателей, которые являются профессорами и ставка которых превышает 1050.
SELECT surname FROM Teachers WHERE isProfessor = 1 AND salary > 1050;

-- 6. Вывести названия кафедр, фонд финансирования которых меньше 11000 или больше 25000.
SELECT [name] FROM Departments WHERE financing < 11000 OR financing > 25000;

-- 7. Вывести названия факультетов кроме факультета “Computer Science”.
SELECT [name] FROM Faculties WHERE [name] != 'Computer Science';

-- 8. Вывести фамилии и должности преподавателей, которые не являются профессорами.
SELECT surname, position FROM Teachers WHERE isProfessor = 0;

-- 9. Вывести фамилии, должности, ставки и надбавки ассистентов, у которых надбавка в диапазоне от 160 до 550.
SELECT surname, position, salary, premium FROM Teachers 
	WHERE isAssistant = 1 AND premium BETWEEN 160 AND 550;

-- 10.Вывести фамилии и ставки ассистентов.
SELECT surname, salary FROM Teachers WHERE isAssistant = 1;

-- 11.Вывести фамилии и должности преподавателей, которые были приняты на работу до 01.01.2000.
SELECT surname, position FROM Teachers WHERE employmentDate < '01.01.2000';

-- 12.Вывести названия кафедр, которые в алфавитном порядке располагаются до кафедры “Software Development”. Выводимое поле должно иметь название “Name of Department”
SELECT Departments.[name] AS 'Name of Department' FROM Departments
	 WHERE [name]<'Software Development'
	 ORDER BY [name];

-- 13.Вывести фамилии ассистентов, имеющих зарплату (сумма ставки и надбавки) не более 1200.
SELECT surname FROM Teachers WHERE isAssistant = 1 AND salary + premium <= 1200;

-- 14.Вывести названия групп 5-го курса, имеющих рейтинг в диапазоне от 2 до 4.
SELECT [name] FROM Groups WHERE [year] = 5 AND rating BETWEEN 2 AND 4;

-- 15.Вывести фамилии ассистентов со ставкой меньше 550 или надбавкой меньше 200.
SELECT surname FROM Teachers WHERE isAssistant = 1 AND salary < 550 OR premium < 200;