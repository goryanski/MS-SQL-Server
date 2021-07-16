use [master];
go

if db_id('Hospital') is not null
begin
	drop database [Hospital];
end
go

create database [Hospital];
go

use [Hospital];
go

create table [Departments]
(
	[Id] int not null identity(1, 1) primary key,
	[Building] int not null check ([Building] between 1 and 5),
	[Financing] money not null check ([Financing] >= 0.0) default 0.0,
	[Name] nvarchar(100) not null unique check ([Name] <> N'')
);
go

create table [Diseases]
(
	[Id] int not null identity(1, 1) primary key,
	[Name] nvarchar(100) not null unique check ([Name] <> N'')
);
go

create table [Doctors]
(
	[Id] int not null identity(1, 1) primary key,
	[Name] nvarchar(max) not null check ([Name] <> N''),
	[Salary] money not null check ([Salary] > 0.0),
	[Surname] nvarchar(max) not null check ([Surname] <> N'')
);

create table [DoctorsExaminations]
(
	[Id] int not null identity(1, 1) primary key,
	[Date] date not null check ([Date] <= getdate()) default getdate(),
	[DiseaseId] int not null,
	[DoctorId] int not null,
	[ExaminationId] int not null,
	[WardId] int not null
);

create table [Examinations]
(
	[Id] int not null identity(1, 1) primary key,
	[Name] nvarchar(100) not null unique check ([Name] <> N'')
);
go

create table [Interns]
(
	[Id] int not null identity(1, 1) primary key,
	[DoctorId] int not null
);
go

create table [Professors]
(
	[Id] int not null identity(1, 1) primary key,
	[DoctorId] int not null
);
go

create table [Wards]
(
	[Id] int not null identity(1, 1) primary key,
	[Name] nvarchar(20) not null unique check ([Name] <> N''),
	[Places] int not null check ([Places] >= 1),
	[DepartmentId] int not null
);
go

alter table [DoctorsExaminations]
add foreign key ([DiseaseId]) references [Diseases]([Id]);
go

alter table [DoctorsExaminations]
add foreign key ([DoctorId]) references [Doctors]([Id]);
go

alter table [DoctorsExaminations]
add foreign key ([ExaminationId]) references [Examinations]([Id]);
go

alter table [DoctorsExaminations]
add foreign key ([WardId]) references [Wards]([Id]);
go

alter table [Interns]
add foreign key ([DoctorId]) references [Doctors]([Id]);
go

alter table [Professors]
add foreign key ([DoctorId]) references [Doctors]([Id]);
go

alter table [Wards]
add foreign key ([DepartmentId]) references [Departments]([Id]);
go

-- ���������� ������ ������� 
INSERT INTO [Doctors] VALUES
('����', 20000, '�������'),
('�����', 22000, '�������'),
('�������', 20000, '���������');

INSERT INTO [Examinations] VALUES 
('������ �����'),
('������ ���'),
('������ ������');


INSERT INTO [Departments] VALUES 
(3, 15000, '��������'),
(2, 20000, '�������������'),
(1, 25000, '�����������');


INSERT INTO [Diseases] VALUES 
('�����'),
('��������'),
('�������');

INSERT INTO [Interns] VALUES
(1),
(2),
(3);

INSERT INTO [Wards] VALUES 
('�������', 6,  1),
('������������', 2, 3),
('�����������������', 6, 2);

INSERT INTO [DoctorsExaminations] VALUES
('2018-04-07', 1, 1, 3, 3),
('2019-02-17', 2, 2, 2, 1),
('2018-11-12', 3, 3, 1, 2);
INSERT INTO [DoctorsExaminations] VALUES
('2017-11-12', 3, 3, 2, 2);

INSERT INTO [Professors] VALUES
(1),
(2),
(3);
GO

-- �������
-- 1. ������� �������� � ����������� �����, ������������� � 5-� �������, ������������ 5 � ����� ����, ���� � ���� ������� ���� ���� �� ���� ������ ������������ ����� 15 ����.
CREATE OR ALTER VIEW WardsPlaces 
AS
	SELECT W.[Name], W.[Places] 
	FROM Wards W 
	INNER JOIN Departments D ON D.id = W.DepartmentId
	WHERE D.Building = 5 AND W.[Places] >= 5 
	AND W.Id = ANY(SELECT W.Id FROM Wards W INNER JOIN Departments D ON D.id = W.DepartmentId
	WHERE D.Building = 5 AND W.[Places] > 15)
GO

SELECT * FROM WardsPlaces
GO

-- 2. ������� �������� ��������� � ������� ����������� ���� �� ���� ������������ �� ��������� ������.
CREATE OR ALTER VIEW DepartmentsNames 
AS
	SELECT D.[Name]
	FROM Departments D 
	JOIN Wards W ON D.Id = W.DepartmentId
	JOIN DoctorsExaminations DE ON W.Id = DE.WardId
	WHERE DE.ExaminationId = ANY(
		SELECT ExaminationId 
		FROM DoctorsExaminations
		WHERE [Date] >= DATEADD(day, -7, GETDATE())
	)
GO

SELECT * FROM DepartmentsNames
GO


-- 3. ������� �������� �����������, ��� ������� �� ���������� ������������.
CREATE OR ALTER VIEW DesiasesNames 
AS
	SELECT D.[Name] 
	FROM Diseases D 
	LEFT JOIN DoctorsExaminations DE ON D.Id = DE.DiseaseId
	WHERE DE.ExaminationId IS NULL
GO

SELECT * FROM DesiasesNames
GO


-- 4. ������� ������ ����� ������, ������� �� �������� ������������.
CREATE OR ALTER VIEW DoctorsNames 
AS
	SELECT D.[Name] + ' ' + D.Surname AS 'Full name of doctors'
	FROM Doctors D 
	LEFT JOIN  DoctorsExaminations DE ON D.Id = DE.DoctorId
	WHERE DE.ExaminationId IS NULL
GO

SELECT * FROM DoctorsNames
GO


-- 5. ������� �������� ���������, � ������� �� ���������� ������������.
CREATE OR ALTER VIEW DepartmentsNamesNotExaminated 
AS
	SELECT D.[Name]
	FROM Departments D 
	LEFT JOIN Wards W ON D.Id = W.DepartmentId
	LEFT JOIN DoctorsExaminations DE ON W.Id = DE.WardId
	WHERE DE.ExaminationId IS NULL
GO

SELECT * FROM DepartmentsNamesNotExaminated
GO



-- 6. ������� ������� ������, ������� �������� ���������.
CREATE OR ALTER VIEW DoctorsSurnames
AS
	SELECT D.Surname
	FROM Doctors D 
	LEFT JOIN Interns I ON D.Id = I.DoctorId
	WHERE I.DoctorId IS NOT NULL
GO
SELECT * FROM DoctorsSurnames
GO


-- 7. ������� ������� ��������, ������ ������� ������, ��� ������ ���� �� ������ �� ������.
CREATE OR ALTER VIEW InternsNames 
AS
	SELECT D.Surname
	FROM Doctors D 
	LEFT JOIN Interns I ON D.Id = I.DoctorId
	WHERE I.DoctorId IS NOT NULL AND 
	D.Salary > ANY (
		SELECT Salary
		FROM Doctors
	)
GO

SELECT * FROM InternsNames
GO


-- 8. ������� �������� �����, ��� ����������� ������, ��� ����������� ������ ������, ����������� � 3-� �������.
CREATE OR ALTER VIEW WardsNames 
AS
	SELECT W.[Name]
	FROM Wards W 
	INNER JOIN Departments D ON D.id = W.DepartmentId
	WHERE W.Places > ALL (
		SELECT W.Places
		FROM Wards W 
		INNER JOIN Departments D ON D.id = W.DepartmentId
		WHERE D.Building = 3
	)
GO

SELECT * FROM WardsNames
GO

-- 9. ������� ������� ������, ���������� ������������ � ���������� �Ophthalmology� � �Physiotherapy�
CREATE OR ALTER VIEW DoctorsSurnamesHaveExaminations 
AS
	SELECT D.Surname
	FROM Doctors D 
	JOIN DoctorsExaminations DE ON D.Id = DE.DoctorId
	JOIN Wards W ON W.Id = DE.WardId
	JOIN Departments DEP ON DEP.Id = W.DepartmentId
	WHERE DEP.Name IN ('Ophthalmology', 'Physiotherapy')
GO

SELECT * FROM DoctorsSurnamesHaveExaminations
GO


-- 10. ������� �������� ���������, � ������� �������� ������� � ����������.
CREATE OR ALTER VIEW DepartmensNamesHaveInternsAndProfessors 
AS
	SELECT DEP.[Name]
	FROM Doctors D 
	JOIN DoctorsExaminations DE ON D.Id = DE.DoctorId
	JOIN Wards W ON W.Id = DE.WardId
	JOIN Departments DEP ON DEP.Id = W.DepartmentId
	LEFT JOIN Professors P ON D.Id = P.DoctorId
	LEFT JOIN Interns I ON D.Id = I.DoctorId
	WHERE EXISTS (
		SELECT Id 
		FROM Professors P  
		WHERE P.DoctorId IS NOT NULL
	) AND EXISTS (
		SELECT Id 
		FROM Interns I  
		WHERE I.DoctorId IS NOT NULL
	)
GO

SELECT * FROM DepartmensNamesHaveInternsAndProfessors
GO


-- 11. ������� ������ ����� ������ � ��������� � ������� ��� �������� ������������, ���� ��������� ����� ���� �������������� ����� 20000
CREATE OR ALTER VIEW FullNamesOfDoctors 
AS
	SELECT D.[Name] + ' ' + D.Surname AS 'Full name of doctors', DEP.[Name]
	FROM Doctors D 
	JOIN DoctorsExaminations DE ON D.Id = DE.DoctorId
	JOIN Wards W ON W.Id = DE.WardId
	JOIN Departments DEP ON DEP.Id = W.DepartmentId
	WHERE DEP.Financing > 20000
	GROUP BY  DEP.[Name],  D.[Name] + ' ' + D.Surname -- ��� �� �� ���� ����������, ��������� � ������� DoctorsExaminations ������ �����
GO

SELECT * FROM FullNamesOfDoctors
GO

-- 12. ������� �������� ���������, � ������� �������� ������������ ���� � ���������� �������.
CREATE OR ALTER VIEW DepartmentHaveMostExpensiveDoctor 
AS
	SELECT DEP.[Name]
	FROM Doctors D 
	JOIN DoctorsExaminations DE ON D.Id = DE.DoctorId
	JOIN Wards W ON W.Id = DE.WardId
	JOIN Departments DEP ON DEP.Id = W.DepartmentId
	WHERE D.Salary = (
		SELECT MAX(Salary)
		FROM Doctors
	)
GO

SELECT * FROM DepartmentHaveMostExpensiveDoctor
GO

-- 13. ������� �������� ����������� � ���������� ���������� �� ��� ������������.
CREATE OR ALTER VIEW PopularDiseases 
AS
	SELECT D.[Name], COUNT(DE.ExaminationId) AS 'Amount of Examinations'
	FROM Diseases D 
	JOIN DoctorsExaminations DE ON D.Id = DE.DiseaseId
	GROUP BY D.[Name]
GO

SELECT * FROM PopularDiseases
GO


ALTER DATABASE [Hospital] SET RECOVERY FULL;
GO

BACKUP DATABASE [Hospital] 
TO DISK = 'E:\backups\demo.bak'
WITH INIT
GO

