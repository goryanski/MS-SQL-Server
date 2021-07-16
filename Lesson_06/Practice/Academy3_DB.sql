USE Academy3_DB
GO

-- Создание таблиц
CREATE TABLE Faculties(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO

CREATE TABLE Departments(
	id INT PRIMARY KEY IDENTITY,
	financing MONEY NOT NULL CHECK(financing >= 0) DEFAULT 0,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE,
	facultyId INT NOT NULL, 
	foreign key (facultyId) references Faculties(id)
);
GO

CREATE TABLE Groups(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(10) NOT NULL CHECK(len([name]) > 0) UNIQUE,
	[year] INT NOT NULL CHECK([year] >= 1 AND [year] <= 5),
	departmentId INT NOT NULL, 
	foreign key (departmentId) references Departments(id)
);
GO

CREATE TABLE Subjects(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO

CREATE TABLE Teachers(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	salary MONEY NOT NULL CHECK(salary > 0),
	surname NVARCHAR(MAX) NOT NULL CHECK(len(surname) > 0)
);
GO

CREATE TABLE Lectures(
	id INT PRIMARY KEY IDENTITY,
	[dayOfWeek] INT NOT NULL CHECK([dayOfWeek] BETWEEN 1 AND 7),
	lectureRoom  NVARCHAR(MAX) NOT NULL CHECK(len(lectureRoom) > 0),
	subjectId INT NOT NULL,
	teacherId INT NOT NULL,
	foreign key (subjectId) references Subjects(id),
	foreign key (teacherId) references Teachers(id)
);
GO

CREATE TABLE GroupsLectures(
	id INT PRIMARY KEY IDENTITY,
	lectureId INT NOT NULL, 
	groupId INT NOT NULL, 
	foreign key (lectureId) references Lectures(id),
	foreign key (groupId) references Groups(id)
);
GO


-- Заполнение таблиц данными 
INSERT INTO Faculties VALUES
('Компьютерных наук и инжененрии'),
('Иностанных языков'),
('Механический');

INSERT INTO Departments VALUES
(18000, 'Программирование', 1),
(7000, 'Журналистика', 2),
(30000, 'История', 3),
(70000, 'Физика', 2),
(15000, 'Математика', 3);

INSERT INTO Groups VALUES
('1-МС-10', 1, 2),
('2-АПВ-12', 2, 3),
('4-ЕМ-11', 4, 1);

INSERT INTO Subjects VALUES
('Программирование'),
('Английский язык'),
('Физика');

INSERT INTO Teachers VALUES
('Наталия', 10000, 'Валериевна'),
('Антон', 15000, 'Юриевич'),
('Никита', 10000, 'Иванович');

INSERT INTO Lectures VALUES
(1, '123A', 2, 1),
(3, '22D', 1, 2),
(4, '44', 3, 3);

INSERT INTO GroupsLectures VALUES
(2, 1),
(1, 2),
(3, 3);



-- Выборки 
--1. Вывести количество преподавателей кафедры “Software Development”
SELECT COUNT(teacherId) AS 'Count teachers'
FROM Lectures WHERE id IN (SELECT lectureId FROM GroupsLectures 
WHERE groupId = (SELECT id FROM Groups 
WHERE departmentId = (SELECT id FROM Departments 
WHERE [name] = 'Software Development')));

-- 2. Вывести количество лекций, которые читает преподаватель “Dave McQueen”.
SELECT COUNT(lectureId) AS 'Count lectures'
FROM GroupsLectures WHERE lectureId IN (SELECT id FROM Lectures 
WHERE teacherId = (SELECT id FROM Teachers 
WHERE [name] = 'Dave' AND surname = 'McQueen'))

-- 3. Вывести количество занятий, проводимых в аудитории “D201”.
SELECT COUNT(lectureId) AS 'Count lectures'
FROM GroupsLectures WHERE lectureId IN 
(SELECT id FROM Lectures WHERE lectureRoom = 'D201');

-- 4. Вывести названия аудиторий и количество лекций, проводимых в них
SELECT lectureRoom AS 'Rooms names', COUNT(GL.lectureId) AS 'Count lectures'
FROM Lectures AS L, GroupsLectures AS GL
WHERE L.id = GL.lectureId
GROUP BY lectureRoom;

-- 5. Вывести количество студентов, посещающих лекции преподавателя “Jack Underhill”.
-- поскольку у нас таблицы студентов нет, то и кол-во студентов узнать как бы невозможно, по этому будем считать что в задании имелось ввиду узнать кол-во групп
SELECT COUNT(groupId) AS 'Count groups'
FROM GroupsLectures WHERE lectureId IN (SELECT id FROM Lectures 
WHERE teacherId = (SELECT id FROM Teachers 
WHERE [name] = 'Jack' AND surname = 'Underhill'))

-- 6. Вывести среднюю ставку преподавателей факультета “Computer Science”.
SELECT AVG(salary) AS 'Avg salaries of teachers'
FROM Teachers WHERE id IN (SELECT teacherId
FROM Lectures WHERE id IN (SELECT lectureId 
FROM GroupsLectures 
WHERE groupId IN (SELECT id FROM Groups 
WHERE departmentId IN (SELECT id FROM Departments 
WHERE facultyId IN (SELECT id FROM Faculties WHERE [name] = 'Механический')))));

-- 7. Вывести минимальное и максимальное количество студентов среди всех групп.
-- поскольку нет таблицы студентов, это задание никак нелья сделать 

-- 8. Вывести средний фонд финансирования кафедр.
SELECT AVG(financing) FROM Departments;

-- 9. Вывести полные имена преподавателей и количество читаемых ими дисциплин.
SELECT T.[name] + ' ' + T.surname AS 'Teachers full names', COUNT(GL.lectureId) AS 'Count lectures'
FROM GroupsLectures AS GL, Lectures AS L, Teachers AS T
WHERE L.id = GL.lectureId AND T.id = L.teacherId
GROUP BY T.[name] + ' ' + T.surname;

-- 10. Вывести количество лекций в каждый день недели.
SELECT L.[dayOfWeek] AS 'Days of week', COUNT(GL.lectureId) AS 'Count lectures'
FROM GroupsLectures AS GL, Lectures AS L
WHERE L.id = GL.lectureId
GROUP BY L.[dayOfWeek]; 

-- 11. Вывести номера аудиторий и количество кафедр, чьи лекции в них читаются.
SELECT L.lectureRoom AS 'Rooms numbers',  COUNT(G.departmentId) AS 'Department count'
FROM Groups AS G, GroupsLectures AS GL, Lectures AS L
WHERE L.id = GL.lectureId AND G.id = GL.groupId
GROUP BY L.lectureRoom;

-- 12.Вывести названия факультетов и количество дисциплин, которые на них читаются.
SELECT D.[name] AS 'Department names', COUNT(L.subjectId) AS 'Subjects count'
FROM Faculties AS F, Departments AS D, Groups AS G, GroupsLectures AS GL, Lectures AS L, Subjects AS S
WHERE F.id = D.facultyId AND D.id = G.departmentId AND G.id = GL.groupId AND L.id = GL.id AND S.id = L.subjectId
GROUP BY D.[name];

-- 13. Вывести количество лекций для каждой пары преподаватель-аудитория.
SELECT T.[name] + ' ' + T.surname + '  r.' + L.lectureRoom AS 'Teacher Place', 
COUNT(GL.lectureId) AS 'Count lectures'
FROM Lectures AS L, Subjects AS S, Teachers AS T, GroupsLectures AS GL
WHERE S.id = L.subjectId AND T.id = L.teacherId AND L.id = GL.lectureId
GROUP BY T.[name] + ' ' + T.surname + '  r.' + L.lectureRoom;