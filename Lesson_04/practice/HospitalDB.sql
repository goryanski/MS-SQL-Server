USE HospitalDB;
GO

-- �������� ������
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


-- ���������� ������ ������� 
INSERT INTO Departments VALUES
(3, 1000, 2, '��������'),
(2, 9000, 1, '�������������'),
(1, 18000, 3, '�����������');

INSERT INTO Diseases VALUES
('�������', 2),
('�������', 3),
('�������', 1);

INSERT INTO Doctors VALUES
('����', 1234567891, 1000, 20000, '�������'),
('�����', 1237777891, 2000, 22000, '�������'),
('�������', 2222267891, 1500, 20000, '���������');

INSERT INTO Examinations VALUES
(2, '09:00:00', '10:00:00', '������ �����'),
(3, '11:00:00', '12:00:00', '������ ���'),
(4, '12:00:00', '14:00:00', '������ ������');

INSERT INTO Wards VALUES
(1, 2, '�������'),
(2, 2, '������������'),
(2, 3, '�����������������');


-- ������� 
-- 1. ������� ���������� ������� �����
SELECT * FROM Wards;

-- 2. ������� ������� � �������� ���� ������.
SELECT surname, phone FROM Doctors;

-- 3. ������� ��� ����� ��� ����������, �� ������� ������������� ������
SELECT DISTINCT [floor] FROM Wards;

-- 4. ������� �������� ����������� ��� ������ �Name of Disease� � ������� �� ������� ��� ������ �Severity of Disease�
SELECT Diseases.[name] as 'Name of Disease',
	Diseases.severity as 'Severity of Disease'
FROM Diseases;

-- 5. ������������ ��������� FROM ��� ����� ���� ������ ���� ������, ��������� ��� ��� ����������.
SELECT dep.building as '������',
	dep.[floor] as '����'
FROM Departments dep;

SELECT doc.salary as '��',
	doc.premium as '������'
FROM Doctors doc;

SELECT exam.startTime as '������ ������������',
	exam.endTime as '����� ������������'
FROM Examinations exam;


-- 6. ������� �������� ���������, ������������� � ������� 5 � ������� ���� �������������� ����� 30000.
SELECT [name] FROM Departments WHERE building = 5 AND financing < 30000;

-- 7. ������� �������� ���������, ������������� � 3-� ������� � ������ �������������� � ��������� �� 12000 �� 15000.
SELECT [name] FROM Departments WHERE building = 3 AND financing BETWEEN 12000 AND 15000;

-- 8. ������� �������� �����, ������������� � �������� 4 � 5 �� 1-� �����.
SELECT [name] FROM Wards WHERE building IN (4, 5) AND [floor] = 1;

-- 9. ������� ��������, ������� � ����� �������������� ���������, ������������� � �������� 3 ��� 6 � ������� ���� �������������� ������ 11000 ��� ������ 25000.
SELECT [name], building, financing FROM Departments 
	WHERE building IN (3, 6) AND financing < 11000 OR financing  > 25000;

-- 10. ������� ������� ������, ��� �������� (����� ������ � ��������) ��������� 1500.
SELECT surname FROM Doctors WHERE salary + premium > 1500;

-- 11. ������� ������� ������, � ������� �������� �������� ��������� ����������� ��������
SELECT surname FROM Doctors WHERE salary / 2 > premium * 3;

-- 12. ������� �������� ������������ ��� ����������, ���������� � ������ ��� ��� ������ � 12:00 �� 15:00. 
SELECT DISTINCT [name] FROM Examinations 
	WHERE [dayOfWeek] IN (1, 2, 3) AND startTime >= '12:00:00' AND endTime <= '15:00:00';

-- 13. ������� �������� � ������ �������� ���������, ������������� � �������� 1, 3, 8 ��� 10.
SELECT [name], building FROM Departments WHERE building IN (1, 3, 8, 10);

-- 14. ������� �������� ����������� ���� �������� �������, ����� 1-� � 2-�.
SELECT [name] FROM Diseases WHERE severity > 2;

-- 15. ������� �������� ���������, ������� �� ������������� � 1-� ��� 3-� �������.
SELECT [name] FROM Departments WHERE building != 1 AND building != 3;

-- 16. ������� �������� ���������, ������� ������������� � 1-� ��� 3-� �������.
SELECT [name] FROM Departments WHERE building IN (1, 3);

-- 17. ������� ������� ������, ������������ �� ����� �N�.
SELECT surname FROM Doctors WHERE surname LIKE 'N%';