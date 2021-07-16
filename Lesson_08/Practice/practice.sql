-- 1. Хранимая процедура выводит «Hello, world!»
CREATE OR ALTER PROCEDURE sp_showHelloWord
	AS
BEGIN
	PRINT 'Hello Word'
END
GO

EXEC sp_showHelloWord
GO

-- 2. Хранимая процедура возвращает информацию о текущем времени
CREATE OR ALTER PROCEDURE sp_showCurrentTime
	AS
BEGIN
	PRINT DATENAME(hour, GETDATE()) 
	+ ':' + DATENAME(minute, GETDATE()) 
	+ ':' + DATENAME(second, GETDATE()) 
END
GO

EXEC sp_showCurrentTime
GO


-- 3. Хранимая процедура возвращает информацию о текущей дате
CREATE OR ALTER PROCEDURE sp_showCurrentDate
	AS
BEGIN
	PRINT GETDATE()
END
GO

EXEC sp_showCurrentDate
GO


-- 4. Хранимая процедура принимает три числа и возвращает их сумму
CREATE OR ALTER PROCEDURE sp_getSum
		@numberOne int,
		@numberTwo int,
		@numberThree int
	AS
BEGIN
	declare @sum int = 0;
	SELECT @sum  = @numberOne + @numberTwo + @numberThree
	return @sum
END
GO

declare @res int = 0;
EXEC @res = sp_getSum 5, 4, 1;
print @res;
GO


-- 5. Хранимая процедура принимает три числа и возвращает среднеарифметическое трёх чисел
CREATE OR ALTER PROCEDURE sp_getAvg
		@numberOne int,
		@numberTwo int,
		@numberThree int
	AS
BEGIN
	declare @avg int = 0;
	SELECT @avg  = (@numberOne + @numberTwo + @numberThree) / 3
	return @avg
END
GO

declare @res int = 0;
EXEC @res = sp_getAvg 5, 4, 1;
print @res;
GO


-- 6. Хранимая процедура принимает три числа и возвращает максимальное значение
CREATE OR ALTER PROCEDURE sp_getMax
		@a int,
		@b int,
		@c int
	AS
BEGIN
	declare @max int = 0;
	if(@a>@b) AND (@a>@c) SET @max = @a;
	if(@b>@a) AND (@b>@c) SET @max = @b;
	if(@c>@a) AND (@c>@b) SET @max = @c;
	return @max
END
GO

declare @res int = 0;
EXEC @res = sp_getMax 5, 4, 1;
print @res;
GO

-- 7. Хранимая процедура принимает три числа и возвращает минимальное значение
CREATE OR ALTER PROCEDURE sp_getMin
		@a INT,
		@b INT,
		@c INT
	AS
BEGIN
	DECLARE @min int = 0;
	if(@a<@b) AND (@a<@c) SET @min = @a;
	if(@b<@a) AND (@b<@c) SET @min = @b;
	if(@c<@a) AND (@c<@b) SET @min = @c;
	return @min
END
GO

DECLARE @res INT = 0;
EXEC @res = sp_getMin 5, 4, 1;
print @res;
GO


-- 8. Хранимая процедура принимает число и символ. В результате работы хранимой процедуры отображается линия длиной равной числу. Линия построена из символа, указанного во втором параметре.
CREATE OR ALTER PROCEDURE sp_showLine
		@number INT,
		@symbol CHAR
	AS
BEGIN
	DECLARE @counter INT = 0;

	WHILE @counter <= @number
	BEGIN
		PRINT @symbol;
		SET @counter += 1;
	END;
END
GO

EXEC sp_showLine 5, '#'
GO


-- 9. Хранимая процедура принимает в качестве параметра число и возвращает его факториал. Формула расчета факториала: n! = 1*2*…n. Например, 3! = 1*2*3 = 6
CREATE OR ALTER PROCEDURE sp_showLine
		@number INT
	AS
BEGIN
	DECLARE @fact INT = 1;
	DECLARE @counter INT = 2;

	WHILE @counter <= @number
	BEGIN
		SET @fact = @fact * @counter;
		SET @counter += 1;
	END;
	PRINT @fact;
END
GO

EXEC sp_showLine 5
GO


-- 10.Хранимая принимает два числовых параметра. Первый параметр — это число. Второй параметр — это степень. Процедура возвращает число, возведенное в степень. Например, если параметры равны 2 и 3, тогда вернется 2 в третьей степени, то есть 8.

CREATE OR ALTER PROCEDURE sp_pow
		@num INT,
		@numPow INT
	AS
BEGIN
	DECLARE @res INT = @num;
	DECLARE @counter INT = 2;

	IF (@numPow = 0) 
		SET @res = 1
	ELSE
		WHILE @counter <= @numPow
		BEGIN
			SET @res *= @num
			SET @counter += 1;
		END;
	RETURN @res;
END
GO

DECLARE @res INT = 0;
EXEC @res = sp_pow 2, 3;
PRINT @res;
GO
