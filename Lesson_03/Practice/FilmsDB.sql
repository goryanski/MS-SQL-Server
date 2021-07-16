USE FilmsDB

CREATE TABLE Genres (
	id int primary key identity,
	genreName NVARCHAR(20) NOT NULL
);
GO

CREATE TABLE Directors (
	id int primary key identity,
	firstName NVARCHAR(20) NOT NULL,
	lastName NVARCHAR(20) NOT NULL,
	nationality NVARCHAR(20) NOT NULL,
	birth DATE NOT NULL
);
GO

CREATE TABLE Movies (
	id int primary key identity,
	title NVARCHAR(20) NOT NULL,
	releaseYear DATE NOT NULL,
	rating INT NOT NULL,
	plot NVARCHAR(MAX) NOT NULL,
	movieLength TIME  NOT NULL,
	directorId INT,
	foreign key(directorId) references Directors(id) 
);
GO


CREATE TABLE Actors (
	id int primary key identity,
	firstName NVARCHAR(20) NOT NULL,
	lastName NVARCHAR(20) NOT NULL,
	nationality NVARCHAR(20) NOT NULL,
	birth DATE NOT NULL
);
GO

CREATE TABLE MovieGenres (
	movieId INT,
	genreId INT,
	foreign key (movieId) references Movies(id),
	foreign key (genreId) references Genres(id)
);
GO

CREATE TABLE MovieActor (
	movieId INT,
	actorId INT,
	foreign key (movieId) references Movies(id),
	foreign key (actorId) references Actors(id)
);
GO


