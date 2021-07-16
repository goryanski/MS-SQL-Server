USE HospitalDB;
GO

-- Создание таблиц
CREATE TABLE Departments(
	id INT PRIMARY KEY IDENTITY,
	building INT NOT NULL CHECK(building > 0 AND Building <= 5),
	financing MONEY NOT NULL CHECK(financing >= 0) DEFAULT 0,
	[floor] INT NOT NULL CHECK([floor] >= 1),
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO

CREATE TABLE Diseases(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE,
	severity INT NOT NULL CHECK(severity >= 1) DEFAULT 1
);
GO

CREATE TABLE Doctors(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	phone CHAR(10),
	premium MONEY NOT NULL CHECK(premium >= 0) DEFAULT 0,
	salary MONEY NOT NULL CHECK(salary >= 0),
	surname NVARCHAR(MAX) NOT NULL CHECK(len(surname) > 0)
);
GO

CREATE TABLE Examinations(
	id INT PRIMARY KEY IDENTITY,
	[dayOfWeek] INT NOT NULL CHECK([dayOfWeek] >= 1 AND [dayOfWeek] <= 7),
	startTime TIME NOT NULL CHECK(startTime >= '08:00:00' AND startTime <= '18:00:00'),
	endTime TIME NOT NULL CHECK(endTime > '08:00:00'),
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE	
);
GO

CREATE TABLE Wards(
	id INT PRIMARY KEY IDENTITY,
	building INT NOT NULL CHECK(building >= 1 AND building <= 5),
	[floor] INT NOT NULL CHECK([floor] >= 1),
	[name] NVARCHAR(20) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO


-- Заполнение таблиц данными 
INSERT INTO Departments VALUES
(3, 1000, 2, 'Хирургия'),
(2, 9000, 1, 'Травматология'),
(1, 18000, 3, 'Кардиология');

INSERT INTO Diseases VALUES
('Склероз', 2),
('Бронхит', 3),
('Перелом', 1);

INSERT INTO Doctors VALUES
('Иван', 1234567891, 1000, 20000, 'Сидоров'),
('Вадим', 1237777891, 2000, 22000, 'Смирнов'),
('Наталия', 2222267891, 1500, 20000, 'Степанова');

INSERT INTO Examinations VALUES
(2, '09:00:00', '10:00:00', 'Осмотр груди'),
(3, '11:00:00', '12:00:00', 'Осмотр ног'),
(4, '12:00:00', '14:00:00', 'Осмотр живота');

INSERT INTO Wards VALUES
(1, 2, 'Терапия'),
(2, 2, 'Операционная'),
(2, 3, 'Послеоперационная');


-- Выборки 
-- 1. Вывести содержимое таблицы палат
SELECT * FROM Wards;

-- 2. Вывести фамилии и телефоны всех врачей.
SELECT surname, phone FROM Doctors;

-- 3. Вывести все этажи без повторений, на которых располагаются палаты
SELECT DISTINCT [floor] FROM Wards;

-- 4. Вывести названия заболеваний под именем “Name of Disease” и степень их тяжести под именем “Severity of Disease”
SELECT Diseases.[name] as 'Name of Disease',
	Diseases.severity as 'Severity of Disease'
FROM Diseases;

-- 5. Использовать выражение FROM для любых трех таблиц базы данных, используя для них псевдонимы.
SELECT dep.building as 'Корпус',
	dep.[floor] as 'Этаж'
FROM Departments dep;

SELECT doc.salary as 'ЗП',
	doc.premium as 'Взятки'
FROM Doctors doc;

SELECT exam.startTime as 'Начало обследования',
	exam.endTime as 'Конец обследования'
FROM Examinations exam;


-- 6. Вывести названия отделений, расположенных в корпусе 5 и имеющих фонд финансирования менее 30000.
SELECT [name] FROM Departments WHERE building = 5 AND financing < 30000;

-- 7. Вывести названия отделений, расположенных в 3-м корпусе с фондом финансирования в диапазоне от 12000 до 15000.
SELECT [name] FROM Departments WHERE building = 3 AND financing BETWEEN 12000 AND 15000;

-- 8. Вывести названия палат, расположенных в корпусах 4 и 5 на 1-м этаже.
SELECT [name] FROM Wards WHERE building IN (4, 5) AND [floor] = 1;

-- 9. Вывести названия, корпуса и фонды финансирования отделений, расположенных в корпусах 3 или 6 и имеющих фонд финансирования меньше 11000 или больше 25000.
SELECT [name], building, financing FROM Departments 
	WHERE building IN (3, 6) AND financing < 11000 OR financing  > 25000;

-- 10. Вывести фамилии врачей, чья зарплата (сумма ставки и надбавки) превышает 1500.
SELECT surname FROM Doctors WHERE salary + premium > 1500;

-- 11. Вывести фамилии врачей, у которых половина зарплаты превышает троекратную надбавку
SELECT surname FROM Doctors WHERE salary / 2 > premium * 3;

-- 12. Вывести названия обследований без повторений, проводимых в первые три дня недели с 12:00 до 15:00. 
SELECT DISTINCT [name] FROM Examinations 
	WHERE [dayOfWeek] IN (1, 2, 3) AND startTime >= '12:00:00' AND endTime <= '15:00:00';

-- 13. Вывести названия и номера корпусов отделений, расположенных в корпусах 1, 3, 8 или 10.
SELECT [name], building FROM Departments WHERE building IN (1, 3, 8, 10);

-- 14. Вывести названия заболеваний всех степеней тяжести, кроме 1-й и 2-й.
SELECT [name] FROM Diseases WHERE severity > 2;

-- 15. Вывести названия отделений, которые не располагаются в 1-м или 3-м корпусе.
SELECT [name] FROM Departments WHERE building != 1 AND building != 3;

-- 16. Вывести названия отделений, которые располагаются в 1-м или 3-м корпусе.
SELECT [name] FROM Departments WHERE building IN (1, 3);

-- 17. Вывести фамилии врачей, начинающиеся на букву “N”.
SELECT surname FROM Doctors WHERE surname LIKE 'N%';