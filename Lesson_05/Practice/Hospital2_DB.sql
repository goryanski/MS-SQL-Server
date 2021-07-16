USE Hospital2DB;
GO

-- Создание таблиц
CREATE TABLE Doctors(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	premium MONEY NOT NULL CHECK(premium >= 0) DEFAULT 0,
	salary MONEY NOT NULL CHECK(salary >= 0),
	surname NVARCHAR(MAX) NOT NULL CHECK(len(surname) > 0)
);
GO

CREATE TABLE Examinations(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE	
);
GO

CREATE TABLE Departments(
	id INT PRIMARY KEY IDENTITY,
	building INT NOT NULL CHECK(building > 0 AND Building <= 5),
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO

CREATE TABLE Wards(
	id INT PRIMARY KEY IDENTITY,
	places INT NOT NULL CHECK(places >= 1),
	[name] NVARCHAR(20) NOT NULL CHECK(len([name]) > 0) UNIQUE,
	departmentId INT NOT NULL, 
	foreign key (departmentId) references Departments(id)
);
GO

CREATE TABLE DoctorsExaminations(
	id INT PRIMARY KEY IDENTITY,
	startTime TIME NOT NULL CHECK(startTime >= '08:00:00' AND startTime <= '18:00:00'),
	endTime TIME NOT NULL CHECK(endTime > '08:00:00'),
	doctorId INT NOT NULL,
	examinationId INT NOT NULL,
	wardId INT NOT NULL,
	foreign key (doctorId) references Doctors(id),
	foreign key (examinationId) references Examinations(id),
	foreign key (wardId) references Wards(id)
);
GO


-- Заполнение таблиц данными 
INSERT INTO Doctors VALUES
('Иван', 1000, 20000, 'Сидоров'),
('Вадим', 2000, 22000, 'Смирнов'),
('Наталия', 1500, 20000, 'Степанова');


INSERT INTO Examinations VALUES
('Осмотр груди'),
('Осмотр ног'),
('Осмотр живота');

INSERT INTO Departments VALUES
(3, 'Хирургия'),
(2, 'Травматология'),
(1, 'Кардиология');

INSERT INTO Wards VALUES
(6, 'Терапия', 1),
(2, 'Операционная', 3),
(6, 'Послеоперационная', 2);

INSERT INTO DoctorsExaminations VALUES
('09:00:00', '10:00:00', 1, 3, 3),
('11:00:00', '12:00:00', 2, 2, 1),
('12:00:00', '14:00:00', 3, 1, 2);



-- Запросы
-- 1. Вывести количество палат, вместимость которых больше 10.
SELECT COUNT(*) FROM Wards WHERE places > 10;

-- 2. Вывести названия корпусов и количество палат в каждом из них. (у корпусов нет названий, есть номера, будем считать что в задании имелось ввиду "Вывести номера корпусов")
SELECT (select building from Departments where id = Wards.departmentId) AS 'Departments buildings', 
COUNT(*)  AS 'Wards amount'  
FROM Wards GROUP BY departmentId;

-- 3. Вывести названия отделений и количество палат в каждом из них.
SELECT (select [name] from Departments where id = Wards.departmentId) AS 'Departments names', 
COUNT(*)  AS 'Wards amount'  
FROM Wards GROUP BY departmentId;

-- 4. Вывести названия отделений и суммарную надбавку врачей в каждом из них.
SELECT Dep.[name], SUM(Doc.premium) AS 'Doctors premiums'
FROM Departments AS Dep, Wards AS W, DoctorsExaminations AS DE, Doctors AS Doc
WHERE Dep.id = W.departmentId AND W.id = DE.wardId AND Doc.id = DE.doctorId
GROUP BY Dep.[name];

-- 5. Вывести названия отделений, в которых проводят обследования 5 и более врачей.
SELECT Dep.[name], COUNT(DE.doctorId) AS 'Doctors amount'
FROM Departments AS Dep, Wards AS W, DoctorsExaminations AS DE, Doctors AS Doc
WHERE Dep.id = W.departmentId AND W.id = DE.wardId AND Doc.id = DE.doctorId
GROUP BY Dep.[name]
HAVING COUNT(DE.doctorId) >= 5;

-- 6. Вывести количество врачей и их суммарную зарплату (сумма ставки и надбавки).
SELECT 'Кол-во врачей [' + CONVERT(nvarchar(20), COUNT(doc.[name])) + '], суммарная зарплата - 
[' + CONVERT(nvarchar(20), SUM(salary + premium)) + ']' AS 'Salaries'
FROM Doctors doc;

-- 7. Вывести среднюю зарплату (сумма ставки и надбавки) врачей.
SELECT AVG(salary + premium) AS 'Average salaries' FROM Doctors;

-- 8. Вывести названия палат с минимальной вместительностью.
SELECT [name] FROM Wards WHERE places < 3;

-- 9. Вывести в каких из корпусов 1, 6, 7 и 8, суммарное количество мест в палатах превышает 100. При этом учитывать только палаты с количеством мест больше 10.
SELECT building FROM Departments 
WHERE building IN (SELECT departmentId  FROM Wards WHERE places > 10 GROUP BY departmentId HAVING SUM(places) > 100) 
AND building IN (1, 6, 7, 8);
