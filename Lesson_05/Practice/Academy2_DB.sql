USE Academy2_DB;
GO

-- Создание таблиц
CREATE TABLE Curators(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	surname NVARCHAR(MAX) NOT NULL CHECK(len(surname) > 0)
);
GO

CREATE TABLE Faculties(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO

CREATE TABLE Departments(
	id INT PRIMARY KEY IDENTITY,
	building INT NOT NULL CHECK(building > 0 AND Building <= 5),
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

CREATE TABLE GroupsCurators(
	id INT PRIMARY KEY IDENTITY,
	curatorId INT NOT NULL, 
	groupId INT NOT NULL, 
	foreign key (curatorId) references Curators(id),
	foreign key (groupId) references Groups(id)
);
GO

CREATE TABLE Subjects(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(100) NOT NULL CHECK(len([name]) > 0) UNIQUE
);
GO

CREATE TABLE Teachers(
	id INT PRIMARY KEY IDENTITY,
	isProfessor BIT NOT NULL DEFAULT 0,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	salary MONEY NOT NULL CHECK(salary > 0),
	surname NVARCHAR(MAX) NOT NULL CHECK(len(surname) > 0)
);
GO

CREATE TABLE Lectures(
	id INT PRIMARY KEY IDENTITY,
	[date] DATE NOT NULL CHECK([date] <= GETDATE()),
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

CREATE TABLE Students(
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(MAX) NOT NULL CHECK(len([name]) > 0),
	surname NVARCHAR(MAX) NOT NULL CHECK(len(surname) > 0),
	rating INT NOT NULL CHECK(rating >= 0 AND rating <= 5),
);
GO

CREATE TABLE GroupsStudents(
	id INT PRIMARY KEY IDENTITY,
	studentId INT NOT NULL, 
	groupId INT NOT NULL, 
	foreign key (studentId) references Students(id),
	foreign key (groupId) references Groups(id)
);
GO



-- Заполнение таблиц данными 
INSERT INTO Curators VALUES
('Тамара', 'Валериевна'),
('Максим', 'Юриевич'),
('Анатолий', 'Иванович');

INSERT INTO Faculties VALUES
('Компьютерных наук и инжененрии'),
('Иностанных языков'),
('Механический');


INSERT INTO Departments VALUES
(1, 18000, 'Программирование', 1),
(2, 7000, 'Журналистика', 2),
(3, 15000, 'Математика', 3);
INSERT INTO Departments VALUES
(1, 30000, 'История', 3);
INSERT INTO Departments VALUES
(1, 70000, 'Физика', 2);


INSERT INTO Groups VALUES
('1-МС-10', 1, 2),
('2-АПВ-12', 2, 3),
('4-ЕМ-11', 4, 1);

INSERT INTO GroupsCurators VALUES
(2, 1),
(1, 2),
(3, 3);

INSERT INTO Subjects VALUES
('Программирование'),
('Английский язык'),
('Физика');

INSERT INTO Teachers VALUES
(0, 'Наталия', 10000, 'Валериевна'),
(0, 'Антон', 15000, 'Юриевич'),
(1, 'Никита', 10000, 'Иванович');

INSERT INTO Lectures VALUES
('2020-01-17', 2, 1),
('2020-03-11', 1, 2),
('2020-05-20', 3, 3);

INSERT INTO GroupsLectures VALUES
(2, 1),
(1, 2),
(3, 3);

INSERT INTO Students VALUES
('Иван', 'Сидоров', 5),
('Вадим', 'Смирнов', 4),
('Наталия','Степанова', 3);

INSERT INTO GroupsStudents VALUES
(2, 1),
(1, 2),
(3, 3);




-- Выборки 
-- 1. Вывести номера корпусов, если суммарный фонд финансирования расположенных в них кафедр превышает 100000.
SELECT building FROM Departments GROUP BY building HAVING SUM(financing) > 100000;

-- 2. Вывести названия групп 5-го курса кафедры “Software Development”, которые имеют более 10 пар в первую неделю
-- узнаем отдельно кол-во лекций и отдельно departmentId, потом с помощью AND проверим оба этих условия, а так же номер курса
SELECT [name] FROM Groups 
WHERE [year] = 5 AND departmentId = (SELECT id FROM Departments 
WHERE [name] = 'Software Development') AND (SELECT COUNT(id) FROM Lectures 
WHERE id = (SELECT lectureId FROM GroupsLectures 
WHERE groupId = (SELECT id FROM Groups 
WHERE [year] = 5 AND departmentId = (SELECT id FROM Departments 
WHERE [name] = 'Software Development'))) AND date BETWEEN '2020-12-01' AND '2020-12-07') > 10;

-- 3. Вывести названия групп, имеющих рейтинг (средний рейтинг всех студентов группы) больше, чем рейтинг группы “D221”.
SELECT G.[name]
FROM Students AS S, Groups AS G, GroupsStudents AS GS
WHERE S.id = GS.studentId AND G.id = GS.groupId
GROUP BY G.[name]
HAVING AVG(S.rating) > (SELECT AVG(rating) FROM Students WHERE id IN (SELECT studentId FROM GroupsStudents WHERE groupId = (SELECT id FROM Groups WHERE [name] = 'D221')));

-- 4. Вывести фамилии и имена преподавателей, ставка которых выше средней ставки профессоров.
SELECT [name], surname FROM Teachers WHERE 
salary > (SELECT AVG(salary) FROM Teachers WHERE isProfessor = 1) AND isProfessor = 0;

-- 5. Вывести названия групп, у которых больше одного куратора.
SELECT [name] FROM Groups WHERE id IN (
SELECT groupId
FROM  GroupsCurators
GROUP BY groupId
HAVING COUNT(curatorId) > 1);

-- 6. Вывести названия групп, имеющих рейтинг (средний рейтинг всех студентов группы) меньше, чем минимальный рейтинг групп 5-го курса.
SELECT G.[name]
FROM Students AS S, Groups AS G, GroupsStudents AS GS
WHERE S.id = GS.studentId AND G.id = GS.groupId
GROUP BY G.[name]
HAVING AVG(S.rating) < (SELECT MIN(rating) FROM Students WHERE id IN (SELECT studentId FROM GroupsStudents WHERE groupId = (SELECT id FROM Groups WHERE [year] = 5)));


-- 7. Вывести названия факультетов, суммарный фонд финансирования кафедр которых больше суммарного фонда финансирования кафедр факультета “Computer Science”
SELECT F.[name] 
FROM Faculties AS F, Departments AS D
WHERE F.id = D.facultyId
GROUP BY F.[name] 
HAVING SUM(D.financing) > (SELECT SUM(financing) FROM Departments WHERE facultyId = (SELECT id FROM Faculties WHERE [name] = 'Computer Science'));

-- 8. Вывести названия дисциплин и полные имена преподавателей, читающих наибольшее количество лекций по ним.
SELECT S.[name] AS 'Subject name', T.[name] + ' ' + T.surname AS 'Teachers full name'
FROM Subjects AS S, Teachers AS T, Lectures AS L 
WHERE T.id = L.teacherId AND S.id = L.subjectId 
AND T.id IN (SELECT teacherId
FROM  Lectures
GROUP BY teacherId
HAVING COUNT(subjectId) > 3);

-- 9. Вывести название дисциплины, по которому читается меньше всего лекций.
SELECT S.[name] AS 'Subject name'
FROM Subjects AS S, Teachers AS T, Lectures AS L 
WHERE T.id = L.teacherId AND S.id = L.subjectId 
AND S.id IN (SELECT subjectId
FROM  Lectures
GROUP BY subjectId
HAVING COUNT(teacherId) = MIN(teacherId));

-- 10. Вывести количество студентов и читаемых дисциплин на кафедре “Software Development”.
SELECT COUNT(studentId) AS 'Count students', COUNT(lectureId) AS 'Count lectures'
FROM GroupsStudents, GroupsLectures
WHERE studentId = (SELECT studentId FROM GroupsStudents 
WHERE groupId = (SELECT id FROM Groups 
WHERE departmentId = (SELECT id FROM Departments 
WHERE [name] = 'Software Development'))) 
AND
lectureId = (SELECT lectureId FROM GroupsLectures 
WHERE groupId = (SELECT id FROM Groups 
WHERE departmentId = (SELECT id FROM Departments 
WHERE [name] = 'Software Development')));
