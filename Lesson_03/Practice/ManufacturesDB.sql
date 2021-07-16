USE FirmsDB
GO

CREATE TABLE WebSites (
	id INT PRIMARY KEY IDENTITY,
	[address] VARCHAR(50) NOT NULL
);
GO


CREATE TABLE Mails (
	id INT PRIMARY KEY IDENTITY,
	email VARCHAR(50) UNIQUE,
);
GO


CREATE TABLE Manufactures (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(30) NOT NULL,
	webSiteeId INT,
	FOREIGN KEY (webSiteeId) REFERENCES WebSites(id),
	mailId INT UNIQUE,
	FOREIGN KEY (mailId) REFERENCES Mails(id)
);
GO




CREATE TABLE Clients (
	id INT PRIMARY KEY IDENTITY,
	firstName NVARCHAR(20) NOT NULL,
	lastName NVARCHAR(20) NOT NULL,
	middleName NVARCHAR(20) NOT NULL,
	position NVARCHAR(20) NOT NULL,
	phone VARCHAR(15) NOT NULL
);
GO

CREATE TABLE ManufactureClients (
	manufactureId INT,
	clientId INT,
	FOREIGN KEY (manufactureId) REFERENCES Manufactures(id),
	FOREIGN KEY (clientId) REFERENCES Clients(id)
);
GO




CREATE TABLE Providers (
	id INT PRIMARY KEY IDENTITY,
	firstName NVARCHAR(20) NOT NULL,
	lastName NVARCHAR(20) NOT NULL,
	middleName NVARCHAR(20) NOT NULL,
	position NVARCHAR(20) NOT NULL,
	phone VARCHAR(15) NOT NULL
);
GO

CREATE TABLE ManufactureProviders (
	manufactureId INT,
	providerId INT,
	FOREIGN KEY (manufactureId) REFERENCES Manufactures(id),
	FOREIGN KEY (providerId) REFERENCES Providers(id)
);
GO




CREATE TABLE Cities (
	id INT PRIMARY KEY IDENTITY,
	[name] NVARCHAR(30) NOT NULL
);
GO

CREATE TABLE ManufactureCities (
	manufactureId INT,
	cityId INT,
	FOREIGN KEY (manufactureId) REFERENCES Manufactures(id),
	FOREIGN KEY (cityId) REFERENCES Cities(id)
);
GO


CREATE TABLE Addresses (
	id INT PRIMARY KEY IDENTITY,
	streetName NVARCHAR(30) NOT NULL,
	buildNumber SMALLINT NOT NULL,
	office SMALLINT,
	manufactureId INT,
	FOREIGN KEY (manufactureId) REFERENCES Manufactures(id)
);
GO




