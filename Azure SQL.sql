CHALLENGE AZURE

-- LAB 2
-- Inner Join(registros comunes en ambas tablas)
SELECT *
FROM Customers2 
INNER JOIN Invoices2 
ON Customers2.ID = Invoices2.Customer

-- Full join (todos registros de ambas tablas, no existentes se ponen NULL)
SELECT *
FROM Customers2 FULL JOIN Invoices2 ON Customers2.ID = Invoices2.Customer

-- Left join 
--(devuelve todos registros de la tabla izq + registros coincidentes de la tabla derech)
SELECT *
FROM Customers2 LEFT JOIN Invoices2 ON Customers2.ID = Invoices2.Customer

-- Right join--(devuelve todos registros de la tabla derec + registros coincidentes de la tabla izq)
SELECT *
FROM Customers2 RIGHT JOIN Invoices2 ON Customers2.ID = Invoices2.Customer

-- Exclusive left join (registros de la tabla izq que no están en la dere. Clientes sin ventas)
SELECT *
FROM Customers2 LEFT JOIN Invoices2 ON Customers2.ID = Invoices2.Customer
WHERE Invoices2.Customer IS NULL

-- Exclusive right join (registros de la tabla dere que no están en la izq. Facturas de clientes inexistentes)
SELECT *
FROM Customers2 RIGHT JOIN Invoices2 ON Customers2.ID = Invoices2.Customer
WHERE Customers2.ID IS NULL

-- Exclusive full join (registros que solo están en la izq o solo en la derech)
--CLIENTES SIN VENTAS Y FACTURAS SIN CLIENTES
SELECT *
FROM Customers2 FULL JOIN Invoices2 ON Customers2.ID = Invoices2.Customer
WHERE Customers2.ID IS NULL OR Invoices2.Customer IS NULL

-- Cross join (Cada registro de la tabla izquierda se combina con un registro de la tabla derecha, obteniendo
un conjunto que es el resultado de) Para generar ejemplos

SELECT *
FROM Customers2 CROSS JOIN Invoices2

-- LAB 3
-- Challenge 1 ¿Qué productos ha comprado cada cliente?
SELECT c.FirstName + ' ' + c.LastName AS [Customer Fullname], p.Name AS [Product Name]
FROM SalesLT.Customer AS c
    INNER JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    INNER JOIN SalesLT.SalesOrderDetail AS shd ON soh.SalesOrderID = shd.SalesOrderID
    INNER JOIN SalesLT.Product AS p ON shd.ProductID = p.ProductID
ORDER BY [Customer Fullname], [Product Name]

-- Challenge 2 Descripción de productos en árabe
SELECT  pm.Name AS 'Product Model', pd.[Description]
FROM SalesLT.ProductModel AS pm    
    INNER JOIN SalesLT.ProductModelProductDescription AS pmpd ON pm.ProductModelID = pmpd.ProductModelID
    INNER JOIN SalesLT.ProductDescription AS pd on PD.ProductDescriptionID = pmpd.ProductDescriptionID
    INNER JOIN SalesLT.Product AS p ON p.ProductModelID = pm.ProductModelID
WHERE pmpd.Culture = 'ar' AND p.ProductID = 710;

-- CHALLENGE 3: BONUS Total de ventas por producto, ordenado desc
SELECT   p.name
	, COUNT(*) AS 'Total Orders' -- cuenta el nº de filas en SalesLT.SalesOrderDetail que coinciden con columna ProductID en tabla SalesLT.Product.
FROM SalesLT.Product AS p
    INNER JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY  p.Name
ORDER BY 'Total Orders' DESC

-- LAB 4
--CHALLENGE 1 PRODUCTO MÁS VENDIDO
SELECT 
p.Name As [Product], 
COUNT(*) AS [Total]
FROM SalesLT.SalesOrderHeader AS soh 
    INNER JOIN SalesLT.SalesOrderDetail AS shd ON soh.SalesOrderID = shd.SalesOrderID
    INNER JOIN SalesLT.Product AS p ON shd.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY 2 DESC --HACE REFERENCIA A LA COLUMNA 2, ES COMO PONER ORDER BY Total DESC

--CHALLENGE 2 Ventas por categoría, y ventas por categoría-producto
SELECT  pc.Name AS [Category], 
p.name AS Product, 
SUM(sod.OrderQty) AS [Total Qty]
FROM SalesLT.Product AS p
    INNER JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY  pc.Name, p.Name
ORDER BY 1, 2 

--CHALLENGE 3 Ventas mayores de ocho por categoría, y por categoría-producto
SELECT pc.Name AS [Category],  
p.Name As [Product], 
SUM(shd.OrderQty) AS [Total Qty]
FROM SalesLT.SalesOrderHeader AS soh 
    INNER JOIN SalesLT.SalesOrderDetail AS shd ON soh.SalesOrderID = shd.SalesOrderID
    INNER JOIN SalesLT.Product AS p ON shd.ProductID = p.ProductID
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY GROUPING SETS ((pc.Name), (pc.Name, p.Name))
ORDER BY 1, 2 

--CHALLENGE 4 BONUS. Descarta los grupos que tengan menos de 8 tickets de venta
SELECT pc.Name AS [Category],  
p.Name As [Product], 
SUM(shd.OrderQty) AS [Total Qty]
FROM SalesLT.SalesOrderHeader AS soh 
    INNER JOIN SalesLT.SalesOrderDetail AS shd ON soh.SalesOrderID = shd.SalesOrderID
    INNER JOIN SalesLT.Product AS p ON shd.ProductID = p.ProductID
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY GROUPING SETS ((pc.Name), (pc.Name, p.Name))
HAVING COUNT(DISTINCT soh.SalesOrderID) >= 8 
	--el count distinct hace referencia al nº de ventas distintas para cada producto según el orderID

--LAB 6 FUNCIONES DE VENTANA
SELECT 
p.ProductID, 
pc.Name AS 'Category', 
p.Name AS 'Product', 
p.[Size]

	-- ranking
    , ROW_NUMBER() OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Size) AS 'Row Number Per Category & Size'
    , RANK() OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Size) AS 'Rank Per Category & Size'
    , DENSE_RANK() OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Size) AS 'Dense Rank Per Category & Size'
    , NTILE(2) OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'NTile Per Category & Name'

	-- aggregate
    , SUM(p.StandardCost) OVER() AS 'Standard Cost Grand Total'
    , SUM(p.StandardCost) OVER(PARTITION BY p.ProductCategoryID) AS 'Standard Cost Per Category'
    
	-- analytical
    , LAG(p.Name, 1, '-- NOT FOUND --') OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'Previous Product Per Category'
    , LEAD(p.Name, 1, '-- NOT FOUND --') OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'Next Product Per Category'
    , FIRST_VALUE(p.Name) OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'First Product Per Category'
    , LAST_VALUE(p.Name) OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'Last Product Per Category'
FROM SalesLT.Product AS p
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
ORDER BY pc.Name, p.Name 

--- LAB 6 CREAR UN PROCEDIMIENTO ALMACENADO
CREATE OR ALTER PROCEDURE [SalesLT].[uspUpdateCustomerAddress]
    @CustomerID INT, 
	@AddressType NVARCHAR(50), 
    @AddressLine NVARCHAR(50), 
    @City NVARCHAR(50), 
    @StateProvince NVARCHAR(50), 
    @CountryRegion NVARCHAR(50),  
    @PostalCode NVARCHAR(50)
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
	
	
		--	Comprobamos que el cliente referenciado existe. En caso contrario se devuelve mensaje de error 
		-- y finaliza la ejecución del procedimiento
		IF NOT EXISTS (SELECT 1 FROM SalesLT.Customer WHERE CustomerID = @CustomerID)
		BEGIN
			RAISERROR(N'Customer doesn''t exist', 16, 127) WITH NOWAIT;
			RETURN;
		END
	
		--	Iniciamos transacción para ejecutar todas las instrucciones como si fuera una sola
        BEGIN TRANSACTION;
		
		DECLARE @newAddress INT;
		
		--	Insertamos un nuevo registro
		INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode)
		VALUES (@AddressLine, @City, @StateProvince, @CountryRegion, @PostalCode)

		--	Recogemos el valor del identificador autogenerado;
		SELECT @newAddress = SCOPE_IDENTITY() ;

		--	Almacenamos la nueva relación entre Cliente y su dirección
        INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType)            
        VALUES (@CustomerID, @newAddress, @AddressType);

		-- 	Confirmamos transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- 	Cancelamos transacción en caso de que haya habido algún error		
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END


        DECLARE  @ErrorMessage  NVARCHAR(4000),  @ErrorSeverity INT,  @ErrorState    INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(), 
            @ErrorSeverity = ERROR_SEVERITY(), 
            @ErrorState = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        
    END CATCH;
	

END;
