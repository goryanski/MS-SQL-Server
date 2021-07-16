USE Hospital3_DB;
GO

-- Создание таблиц
CREATE TABLE Departments(
	id INT PRIMARY KEY IDENTITY,
	building INT NOT NULL CHECK(building > 0 AND Building <= 5),
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO

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

CREATE TABLE Sponsors(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE	
);
GO

CREATE TABLE Donations(
	id INT PRIMARY KEY IDENTITY,
	amount MONEY  NOT NULL CHECK(amount > 0),
	[date] DATE NOT NULL CHECK([date] <= GETDATE()) DEFAULT GETDATE(),
	departmentId INT NOT NULL,
	sponsorId INT NOT NULL,
	foreign key (departmentId) references Departments(id),
	foreign key (sponsorId) references Sponsors(id)
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

INSERT INTO Sponsors VALUES
('Иванов И.И.'),
('Оксана Ф.М.'),
('Сидоров Ф.В.');

INSERT INTO Donations VALUES
(50000, '2018-04-07', 1, 2),
(66000, '2019-02-17', 2, 1),
(88000, '2018-11-12', 3, 3);



-- Запросы
-- 1. Вывести названия отделений, что находятся в том же корпусе, что и отделение “Cardiology”.
SELECT [name] FROM Departments 
WHERE building = (SELECT building FROM Departments WHERE [name] = 'Cardiology');

-- 2. Вывести названия отделений, что находятся в том же корпусе, что и отделения “Gastroenterology” и “General Surgery”.
-- воспользуемся своими названиями, вместо этих для проверки
INSERT INTO Departments VALUES
(1, 'Гиникология');

SELECT [name] FROM Departments 
WHERE building = (SELECT building FROM Departments WHERE [name] = 'Кардиология') 
AND building = (SELECT building FROM Departments WHERE [name] = 'Гиникология');


-- 3. Вывести название отделения, которое получило меньше всего пожертвований.
SELECT [name] FROM Departments 
WHERE id = (SELECT departmentId FROM Donations 
WHERE amount = (SELECT MIN(amount) FROM Donations));

-- 4. Вывести фамилии врачей, ставка которых больше, чем у врача “Thomas Gerada”
INSERT INTO Doctors VALUES
('Thomas', 1000, 9000, 'Gerada');

SELECT surname FROM Doctors 
WHERE salary > (SELECT salary FROM Doctors 
WHERE [name] = 'Thomas' AND surname = 'Gerada');


-- 5. Вывести названия палат, вместимость которых больше, чем средняя вместимость в палатах отделения “Microbiology”.
SELECT [name] FROM Wards 
WHERE places > (SELECT AVG(places) FROM Wards 
WHERE departmentId = (SELECT id FROM Departments 
WHERE [name] = 'Microbiology'));


-- 6. Вывести полные имена врачей, зарплаты которых (сумма ставки и надбавки) превышают более чем на 100 зарплату врача “Anthony Davis”
INSERT INTO Doctors VALUES
('Anthony', 1000, 9000, 'Davis');

SELECT [name] + ' ' + surname AS 'Top salaries'
FROM Doctors 
WHERE (salary + premium) - 
((SELECT salary FROM Doctors 
WHERE [name] = 'Anthony' AND surname = 'Davis') + 
(SELECT premium FROM Doctors 
WHERE [name] = 'Anthony' AND surname = 'Davis')) 
> 100;


-- 7. Вывести названия отделений, в которых проводит обследования врач “Joshua Bell”.

-- Для этого находим id доктора Joshua Bell, затем по этому id находим его в таблице DoctorsExaminations. в этой же таблице находим записи в которых указан нужный нам doctorId и получаем оттуда нужный нам wardId, тем самым мы узнаем список палат, в которых проводит обследования доктор “Joshua Bell”. после этого нам нужно узнать, в каких отделениях находятся эти палаты, их названия и будут результатом запроса 
SELECT [name] FROM Departments 
WHERE id = (SELECT departmentId FROM Wards 
WHERE id = (SELECT wardId FROM DoctorsExaminations 
WHERE doctorId = (SELECT doctorId FROM DoctorsExaminations 
WHERE doctorId = (SELECT id FROM Doctors 
WHERE [name] = 'Joshua' AND surname = 'Bell'))));


-- 8. Вывести названия спонсоров, которые не делали пожертвования отделениям “Neurology” и “Oncology”
SELECT [name] FROM Sponsors 
WHERE id IN (SELECT sponsorId FROM Donations 
WHERE departmentId IN (SELECT id FROM Departments 
WHERE [name] != 'Neurology')
AND departmentId IN (SELECT id FROM Departments 
WHERE [name] != 'Oncology'))


-- 9. Вывести фамилии врачей, которые проводят обследования в период с 12:00 до 15:00.
SELECT surname FROM Doctors 
WHERE id IN (SELECT doctorId FROM DoctorsExaminations 
WHERE startTime <= '12:00:00' AND endTime >= '15:00:00');