USE Academy2_DB;
GO

-- �������� ������
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



-- ���������� ������ ������� 
INSERT INTO Curators VALUES
('������', '����������'),
('������', '�������'),
('��������', '��������');

INSERT INTO Faculties VALUES
('������������ ���� � ����������'),
('���������� ������'),
('������������');


INSERT INTO Departments VALUES
(1, 18000, '����������������', 1),
(2, 7000, '������������', 2),
(3, 15000, '����������', 3);
INSERT INTO Departments VALUES
(1, 30000, '�������', 3);
INSERT INTO Departments VALUES
(1, 70000, '������', 2);


INSERT INTO Groups VALUES
('1-��-10', 1, 2),
('2-���-12', 2, 3),
('4-��-11', 4, 1);

INSERT INTO GroupsCurators VALUES
(2, 1),
(1, 2),
(3, 3);

INSERT INTO Subjects VALUES
('����������������'),
('���������� ����'),
('������');

INSERT INTO Teachers VALUES
(0, '�������', 10000, '����������'),
(0, '�����', 15000, '�������'),
(1, '������', 10000, '��������');

INSERT INTO Lectures VALUES
('2020-01-17', 2, 1),
('2020-03-11', 1, 2),
('2020-05-20', 3, 3);

INSERT INTO GroupsLectures VALUES
(2, 1),
(1, 2),
(3, 3);

INSERT INTO Students VALUES
('����', '�������', 5),
('�����', '�������', 4),
('�������','���������', 3);

INSERT INTO GroupsStudents VALUES
(2, 1),
(1, 2),
(3, 3);




-- ������� 
-- 1. ������� ������ ��������, ���� ��������� ���� �������������� ������������� � ��� ������ ��������� 100000.
SELECT building FROM Departments GROUP BY building HAVING SUM(financing) > 100000;

-- 2. ������� �������� ����� 5-�� ����� ������� �Software Development�, ������� ����� ����� 10 ��� � ������ ������
-- ������ �������� ���-�� ������ � �������� departmentId, ����� � ������� AND �������� ��� ���� �������, � ��� �� ����� �����
SELECT [name] FROM Groups 
WHERE [year] = 5 AND departmentId = (SELECT id FROM Departments 
WHERE [name] = 'Software Development') AND (SELECT COUNT(id) FROM Lectures 
WHERE id = (SELECT lectureId FROM GroupsLectures 
WHERE groupId = (SELECT id FROM Groups 
WHERE [year] = 5 AND departmentId = (SELECT id FROM Departments 
WHERE [name] = 'Software Development'))) AND date BETWEEN '2020-12-01' AND '2020-12-07') > 10;

-- 3. ������� �������� �����, ������� ������� (������� ������� ���� ��������� ������) ������, ��� ������� ������ �D221�.
SELECT G.[name]
FROM Students AS S, Groups AS G, GroupsStudents AS GS
WHERE S.id = GS.studentId AND G.id = GS.groupId
GROUP BY G.[name]
HAVING AVG(S.rating) > (SELECT AVG(rating) FROM Students WHERE id IN (SELECT studentId FROM GroupsStudents WHERE groupId = (SELECT id FROM Groups WHERE [name] = 'D221')));

-- 4. ������� ������� � ����� ��������������, ������ ������� ���� ������� ������ �����������.
SELECT [name], surname FROM Teachers WHERE 
salary > (SELECT AVG(salary) FROM Teachers WHERE isProfessor = 1) AND isProfessor = 0;

-- 5. ������� �������� �����, � ������� ������ ������ ��������.
SELECT [name] FROM Groups WHERE id IN (
SELECT groupId
FROM  GroupsCurators
GROUP BY groupId
HAVING COUNT(curatorId) > 1);

-- 6. ������� �������� �����, ������� ������� (������� ������� ���� ��������� ������) ������, ��� ����������� ������� ����� 5-�� �����.
SELECT G.[name]
FROM Students AS S, Groups AS G, GroupsStudents AS GS
WHERE S.id = GS.studentId AND G.id = GS.groupId
GROUP BY G.[name]
HAVING AVG(S.rating) < (SELECT MIN(rating) FROM Students WHERE id IN (SELECT studentId FROM GroupsStudents WHERE groupId = (SELECT id FROM Groups WHERE [year] = 5)));


-- 7. ������� �������� �����������, ��������� ���� �������������� ������ ������� ������ ���������� ����� �������������� ������ ���������� �Computer Science�
SELECT F.[name] 
FROM Faculties AS F, Departments AS D
WHERE F.id = D.facultyId
GROUP BY F.[name] 
HAVING SUM(D.financing) > (SELECT SUM(financing) FROM Departments WHERE facultyId = (SELECT id FROM Faculties WHERE [name] = 'Computer Science'));

-- 8. ������� �������� ��������� � ������ ����� ��������������, �������� ���������� ���������� ������ �� ���.
SELECT S.[name] AS 'Subject name', T.[name] + ' ' + T.surname AS 'Teachers full name'
FROM Subjects AS S, Teachers AS T, Lectures AS L 
WHERE T.id = L.teacherId AND S.id = L.subjectId 
AND T.id IN (SELECT teacherId
FROM  Lectures
GROUP BY teacherId
HAVING COUNT(subjectId) > 3);

-- 9. ������� �������� ����������, �� �������� �������� ������ ����� ������.
SELECT S.[name] AS 'Subject name'
FROM Subjects AS S, Teachers AS T, Lectures AS L 
WHERE T.id = L.teacherId AND S.id = L.subjectId 
AND S.id IN (SELECT subjectId
FROM  Lectures
GROUP BY subjectId
HAVING COUNT(teacherId) = MIN(teacherId));

-- 10. ������� ���������� ��������� � �������� ��������� �� ������� �Software Development�.
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
