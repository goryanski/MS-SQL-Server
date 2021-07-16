USE Academy3_DB
GO

-- �������� ������
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


-- ���������� ������ ������� 
INSERT INTO Faculties VALUES
('������������ ���� � ����������'),
('���������� ������'),
('������������');

INSERT INTO Departments VALUES
(18000, '����������������', 1),
(7000, '������������', 2),
(30000, '�������', 3),
(70000, '������', 2),
(15000, '����������', 3);

INSERT INTO Groups VALUES
('1-��-10', 1, 2),
('2-���-12', 2, 3),
('4-��-11', 4, 1);

INSERT INTO Subjects VALUES
('����������������'),
('���������� ����'),
('������');

INSERT INTO Teachers VALUES
('�������', 10000, '����������'),
('�����', 15000, '�������'),
('������', 10000, '��������');

INSERT INTO Lectures VALUES
(1, '123A', 2, 1),
(3, '22D', 1, 2),
(4, '44', 3, 3);

INSERT INTO GroupsLectures VALUES
(2, 1),
(1, 2),
(3, 3);



-- ������� 
--1. ������� ���������� �������������� ������� �Software Development�
SELECT COUNT(teacherId) AS 'Count teachers'
FROM Lectures WHERE id IN (SELECT lectureId FROM GroupsLectures 
WHERE groupId = (SELECT id FROM Groups 
WHERE departmentId = (SELECT id FROM Departments 
WHERE [name] = 'Software Development')));

-- 2. ������� ���������� ������, ������� ������ ������������� �Dave McQueen�.
SELECT COUNT(lectureId) AS 'Count lectures'
FROM GroupsLectures WHERE lectureId IN (SELECT id FROM Lectures 
WHERE teacherId = (SELECT id FROM Teachers 
WHERE [name] = 'Dave' AND surname = 'McQueen'))

-- 3. ������� ���������� �������, ���������� � ��������� �D201�.
SELECT COUNT(lectureId) AS 'Count lectures'
FROM GroupsLectures WHERE lectureId IN 
(SELECT id FROM Lectures WHERE lectureRoom = 'D201');

-- 4. ������� �������� ��������� � ���������� ������, ���������� � ���
SELECT lectureRoom AS 'Rooms names', COUNT(GL.lectureId) AS 'Count lectures'
FROM Lectures AS L, GroupsLectures AS GL
WHERE L.id = GL.lectureId
GROUP BY lectureRoom;

-- 5. ������� ���������� ���������, ���������� ������ ������������� �Jack Underhill�.
-- ��������� � ��� ������� ��������� ���, �� � ���-�� ��������� ������ ��� �� ����������, �� ����� ����� ������� ��� � ������� ������� ����� ������ ���-�� �����
SELECT COUNT(groupId) AS 'Count groups'
FROM GroupsLectures WHERE lectureId IN (SELECT id FROM Lectures 
WHERE teacherId = (SELECT id FROM Teachers 
WHERE [name] = 'Jack' AND surname = 'Underhill'))

-- 6. ������� ������� ������ �������������� ���������� �Computer Science�.
SELECT AVG(salary) AS 'Avg salaries of teachers'
FROM Teachers WHERE id IN (SELECT teacherId
FROM Lectures WHERE id IN (SELECT lectureId 
FROM GroupsLectures 
WHERE groupId IN (SELECT id FROM Groups 
WHERE departmentId IN (SELECT id FROM Departments 
WHERE facultyId IN (SELECT id FROM Faculties WHERE [name] = '������������')))));

-- 7. ������� ����������� � ������������ ���������� ��������� ����� ���� �����.
-- ��������� ��� ������� ���������, ��� ������� ����� ����� ������� 

-- 8. ������� ������� ���� �������������� ������.
SELECT AVG(financing) FROM Departments;

-- 9. ������� ������ ����� �������������� � ���������� �������� ��� ���������.
SELECT T.[name] + ' ' + T.surname AS 'Teachers full names', COUNT(GL.lectureId) AS 'Count lectures'
FROM GroupsLectures AS GL, Lectures AS L, Teachers AS T
WHERE L.id = GL.lectureId AND T.id = L.teacherId
GROUP BY T.[name] + ' ' + T.surname;

-- 10. ������� ���������� ������ � ������ ���� ������.
SELECT L.[dayOfWeek] AS 'Days of week', COUNT(GL.lectureId) AS 'Count lectures'
FROM GroupsLectures AS GL, Lectures AS L
WHERE L.id = GL.lectureId
GROUP BY L.[dayOfWeek]; 

-- 11. ������� ������ ��������� � ���������� ������, ��� ������ � ��� ��������.
SELECT L.lectureRoom AS 'Rooms numbers',  COUNT(G.departmentId) AS 'Department count'
FROM Groups AS G, GroupsLectures AS GL, Lectures AS L
WHERE L.id = GL.lectureId AND G.id = GL.groupId
GROUP BY L.lectureRoom;

-- 12.������� �������� ����������� � ���������� ���������, ������� �� ��� ��������.
SELECT D.[name] AS 'Department names', COUNT(L.subjectId) AS 'Subjects count'
FROM Faculties AS F, Departments AS D, Groups AS G, GroupsLectures AS GL, Lectures AS L, Subjects AS S
WHERE F.id = D.facultyId AND D.id = G.departmentId AND G.id = GL.groupId AND L.id = GL.id AND S.id = L.subjectId
GROUP BY D.[name];

-- 13. ������� ���������� ������ ��� ������ ���� �������������-���������.
SELECT T.[name] + ' ' + T.surname + '  r.' + L.lectureRoom AS 'Teacher Place', 
COUNT(GL.lectureId) AS 'Count lectures'
FROM Lectures AS L, Subjects AS S, Teachers AS T, GroupsLectures AS GL
WHERE S.id = L.subjectId AND T.id = L.teacherId AND L.id = GL.lectureId
GROUP BY T.[name] + ' ' + T.surname + '  r.' + L.lectureRoom;