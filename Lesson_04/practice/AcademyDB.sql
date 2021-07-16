USE AcademyDB;
GO

-- �������� ������
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


-- ���������� ������ ������� 
INSERT INTO Departments VALUES
(18000, '����������������'),
(7000, '������������'),
(15000, '����������');

INSERT INTO Faculties VALUES
('������� �.�.', '������������ ���� � ����������'),
('�������� �.�.', '���������� ������'),
('������� �.�.', '������������');

INSERT INTO Groups VALUES
('1-��-10', 5, 1),
('2-���-12', 4, 2),
('4-��-11', 3, 4);

INSERT INTO Teachers VALUES
('1990-01-17', 0, 0, '������', '������� ����������', 2000, 10000, '����������'),
('1995-03-11', 1, 0, '������', '������� ����������� �����', 4000, 15000, '�������'),
('1998-05-20', 0, 1, '��������', '������� ������', 1000, 10000, '��������');


-- ������� 
--  1. ������� ������� ������, �� ����������� �� ���� � �������� �������. 
SELECT * FROM Departments ORDER BY id DESC;

-- 2. ������� �������� ����� � �� ��������, ��������� � �������� �������� ��������� ����� �Group Name� � �Group Rating� ��������������.
SELECT Groups.[name] AS 'Group Name', 
	Groups.rating AS 'Group Rating' 
	FROM Groups;


--  3. ������� ��� �������������� �� �������, ������� ������ �� ��������� � �������� � ������� ������ �� ��������� � �������� (����� ������ � ��������).
SELECT '������� [' + Teachers.surname + '], 
������� ������ �� ��������� � ��������
[' + CONVERT(nvarchar(20), Teachers.salary / Teachers.premium * 100) + '%], 
������� ������ �� ��������� � �������� 
[' + CONVERT(nvarchar(20), Teachers.salary / (Teachers.premium + Teachers.salary) * 100) + '%]' 
AS 'Percents'
FROM Teachers;


--  4. ������� ������� ����������� � ���� ������ ���� � ��������� �������: �The dean of faculty [faculty] is [dean].�.
SELECT 'The dean of faculty  [' + Faculties.[name] + '] is
[' + Faculties.dean + ']' AS 'FacultiesDeans'
FROM Faculties;


-- 5. ������� ������� ��������������, ������� �������� ������������ � ������ ������� ��������� 1050.
SELECT surname FROM Teachers WHERE isProfessor = 1 AND salary > 1050;

-- 6. ������� �������� ������, ���� �������������� ������� ������ 11000 ��� ������ 25000.
SELECT [name] FROM Departments WHERE financing < 11000 OR financing > 25000;

-- 7. ������� �������� ����������� ����� ���������� �Computer Science�.
SELECT [name] FROM Faculties WHERE [name] != 'Computer Science';

-- 8. ������� ������� � ��������� ��������������, ������� �� �������� ������������.
SELECT surname, position FROM Teachers WHERE isProfessor = 0;

-- 9. ������� �������, ���������, ������ � �������� �����������, � ������� �������� � ��������� �� 160 �� 550.
SELECT surname, position, salary, premium FROM Teachers 
	WHERE isAssistant = 1 AND premium BETWEEN 160 AND 550;

-- 10.������� ������� � ������ �����������.
SELECT surname, salary FROM Teachers WHERE isAssistant = 1;

-- 11.������� ������� � ��������� ��������������, ������� ���� ������� �� ������ �� 01.01.2000.
SELECT surname, position FROM Teachers WHERE employmentDate < '01.01.2000';

-- 12.������� �������� ������, ������� � ���������� ������� ������������� �� ������� �Software Development�. ��������� ���� ������ ����� �������� �Name of Department�
SELECT Departments.[name] AS 'Name of Department' FROM Departments
	 WHERE [name]<'Software Development'
	 ORDER BY [name];

-- 13.������� ������� �����������, ������� �������� (����� ������ � ��������) �� ����� 1200.
SELECT surname FROM Teachers WHERE isAssistant = 1 AND salary + premium <= 1200;

-- 14.������� �������� ����� 5-�� �����, ������� ������� � ��������� �� 2 �� 4.
SELECT [name] FROM Groups WHERE [year] = 5 AND rating BETWEEN 2 AND 4;

-- 15.������� ������� ����������� �� ������� ������ 550 ��� ��������� ������ 200.
SELECT surname FROM Teachers WHERE isAssistant = 1 AND salary < 550 OR premium < 200;