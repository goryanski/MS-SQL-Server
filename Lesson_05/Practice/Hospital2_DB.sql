USE Hospital2DB;
GO

-- �������� ������
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


-- ���������� ������ ������� 
INSERT INTO Doctors VALUES
('����', 1000, 20000, '�������'),
('�����', 2000, 22000, '�������'),
('�������', 1500, 20000, '���������');


INSERT INTO Examinations VALUES
('������ �����'),
('������ ���'),
('������ ������');

INSERT INTO Departments VALUES
(3, '��������'),
(2, '�������������'),
(1, '�����������');

INSERT INTO Wards VALUES
(6, '�������', 1),
(2, '������������', 3),
(6, '�����������������', 2);

INSERT INTO DoctorsExaminations VALUES
('09:00:00', '10:00:00', 1, 3, 3),
('11:00:00', '12:00:00', 2, 2, 1),
('12:00:00', '14:00:00', 3, 1, 2);



-- �������
-- 1. ������� ���������� �����, ����������� ������� ������ 10.
SELECT COUNT(*) FROM Wards WHERE places > 10;

-- 2. ������� �������� �������� � ���������� ����� � ������ �� ���. (� �������� ��� ��������, ���� ������, ����� ������� ��� � ������� ������� ����� "������� ������ ��������")
SELECT (select building from Departments where id = Wards.departmentId) AS 'Departments buildings', 
COUNT(*)  AS 'Wards amount'  
FROM Wards GROUP BY departmentId;

-- 3. ������� �������� ��������� � ���������� ����� � ������ �� ���.
SELECT (select [name] from Departments where id = Wards.departmentId) AS 'Departments names', 
COUNT(*)  AS 'Wards amount'  
FROM Wards GROUP BY departmentId;

-- 4. ������� �������� ��������� � ��������� �������� ������ � ������ �� ���.
SELECT Dep.[name], SUM(Doc.premium) AS 'Doctors premiums'
FROM Departments AS Dep, Wards AS W, DoctorsExaminations AS DE, Doctors AS Doc
WHERE Dep.id = W.departmentId AND W.id = DE.wardId AND Doc.id = DE.doctorId
GROUP BY Dep.[name];

-- 5. ������� �������� ���������, � ������� �������� ������������ 5 � ����� ������.
SELECT Dep.[name], COUNT(DE.doctorId) AS 'Doctors amount'
FROM Departments AS Dep, Wards AS W, DoctorsExaminations AS DE, Doctors AS Doc
WHERE Dep.id = W.departmentId AND W.id = DE.wardId AND Doc.id = DE.doctorId
GROUP BY Dep.[name]
HAVING COUNT(DE.doctorId) >= 5;

-- 6. ������� ���������� ������ � �� ��������� �������� (����� ������ � ��������).
SELECT '���-�� ������ [' + CONVERT(nvarchar(20), COUNT(doc.[name])) + '], ��������� �������� - 
[' + CONVERT(nvarchar(20), SUM(salary + premium)) + ']' AS 'Salaries'
FROM Doctors doc;

-- 7. ������� ������� �������� (����� ������ � ��������) ������.
SELECT AVG(salary + premium) AS 'Average salaries' FROM Doctors;

-- 8. ������� �������� ����� � ����������� ����������������.
SELECT [name] FROM Wards WHERE places < 3;

-- 9. ������� � ����� �� �������� 1, 6, 7 � 8, ��������� ���������� ���� � ������� ��������� 100. ��� ���� ��������� ������ ������ � ����������� ���� ������ 10.
SELECT building FROM Departments 
WHERE building IN (SELECT departmentId  FROM Wards WHERE places > 10 GROUP BY departmentId HAVING SUM(places) > 100) 
AND building IN (1, 6, 7, 8);
