/*

1. RECUPERACI�N DE DATOS SIMPLE

Listar todos los art�culos que cumplan con las siguientes condiciones:
- su preciomenor tenga un valor entre 5.00 y 30.00
- su c�digo (articulo) comience con la letra K
- contanga en su nombre la palabra REMERA

Presentar las columnas ARTICULO, NOMBRE, PRECIOMENOR y ESTADO. Ordenar por la columna NOMBRE.

TABLAS: articulos (EL RESULTADO DEBE ARROJAR 31 FILAS)

*/
SELECT 
	articulo,
	nombre,
	preciomenor,
	estado
FROM articulos
WHERE
	preciomenor between 5.00 and 30.00
	and articulo like 'K%'
	and nombre like '%REMERA%'
ORDER BY
	2


/*

2. RECUPERACI�N DE DATOS CON AGRUPAMIENTO

Mostrar por MES la cantidad de facturas emitidas y el importe total de ventas MAYORISTAS correspondientes al a�o 2007.

Excluir las ventas anuladas. Mostrar las columnas MES, FACTURAS, IMPORTE. Ordenar por mes.

TABLAS: mayorcab (EL RESULTADO DEBE ARROJAR 12 FILAS)

*/
SELECT 
	MONTH(fecha) as 'MES',
	count(factura) as 'CANTIDAD FACTURAS',
	sum(total) as 'IMPORTE TOTAL'
FROM mayorcab
where
	anulada = 0
	and year(fecha) = 2007
group by
	MONTH(fecha)
order by
	1
/*

3. RECUPERACI�N DE DATOS CON SUBCONSULTA

Listar los vendedores ACTIVOS que NO realizaron ventas minoristas en el periodo que va del 01/04/2006 al 30/06/2006.

Mostrar las columnas VENDEDOR (c�digo), NOMBRE, ENCARGADO y ACTIVO. Ordenar por nombre del vendedor.

TABLAS: vencab (suconsulta), vendedores (consulta principal) (EL RESULTADO DEBE RETORNAR 68 FILAS)

*/
SELECT 
	vendedor,
	nombre,
	encargado,
	activo
FROM vendedores
WHERE
	activo = 'S'
	and vendedor not in (SELECT distinct vendedor FROM vencab WHERE fecha between '2006/04/01' and '2006/06/30')
ORDER BY 
	1
/*

4. RECUPERACI�N DE DATOS CON UNION

Listar en una sola columna denominada "Factura" la LETRA + FACTURA (concatenadas) de las facturas realizadas por ventas minoristas
(vencab) en el mes de mayo del 2006, excluyendo las ventas anuladas. 

Luego listar el conjunto equivalente pero para ventas mayoristas (mayorcab), para el mismo periodo y excluyendo tambi�n
ventas anuladas.

Unir los dos conjuntos, agregando una columna "Tipo Venta" que indique si la factura es de venta mayorista o minorista.

Ordenar por la primer columna "Factura".

TABLAS: vencab (consulta 1), mayorcab (consulta 2) (EL RESULTADO DEBE RETORNAR 10738 FILAS)

*/
SELECT
	letra +  Rtrim(str(factura)) as 'FACTURA',
	'Min' as 'Tipo Venta'
FROM vencab
WHERE 
	anulada = 0
	and year(fecha) = 2006
	and MONTH(fecha) = 5

UNION

SELECT 
	letra + trim(str(factura)) as 'FACTURA',
	'MAY' as 'Tipo Venta'
FROM mayorcab
where
	anulada = 0
	and year(fecha) = 2006
	and MONTH(fecha) = 5
order by 
	1

/*

5. RECUPERACI�N DE DATOS DE VARIAS TABLAS

Listar las facturas de ventas MAYORISTAS, generadas en el a�o 2007 por clientes de la provincia de C�rdoba.

Los clientes de la provincia de C�rdoba son aquellos cuyo c�digo postal (columna CP de la tabla CLIENTES) 
est� entre '5000' y '5999'. TENGA EN CUENTA QUE ESTA COLUMNA ES DE TIPO CHAR.

Mostrar en el resultado las columnas NOMBRE (cliente), CP, LETRA, FACTURA, FECHA y TOTAL.

Ordene por el nombre del cliente, y luego por el n�mero de factura. Excluya ventas anuladas.

TABLAS: clientes, mayorcab (EL RESULTADO DEBE RETORNAR 5327 FILAS)

*/
SELECT 
	c.cliente,
	c.cp,
	mc.letra,
	mc.factura,
	mc.fecha,
	mc.total
FROM clientes c
	inner join mayorcab mc on (c.cliente = mc.cliente)
WHERE
	c.cp between '5000' and '5999'
	and year(mc.fecha) = 2007
	and mc.anulada = 0
/*

6. RECUPERACI�N DE DATOS DE VARIAS TABLAS CON AGRUPAMIENTO

Partiendo de la base de la consulta anterior (con las mismas condiciones), muestre ahora las siguientes columnas: 

NOMBRE (cliente), CP, CANTIDAD DE FACTURAS (count), IMPORTE TOTAL (sum)

Ordene en forma DESCENDENTE por el IMPORTE TOTAL.

TABLAS: clientes, mayorcab (EL RESULTADO DEBE RETORNAR 142 FILAS)

*/
SELECT 
	c.nombre,
	c.cp,
	count(mc.factura) as 'CANTIDAD DE FACTURAS',
	SUM(mc.total) as 'IMPORTE TOTAL'
FROM clientes c
	inner join mayorcab mc on (c.cliente = mc.cliente)
WHERE
	c.cp between '5000' and '5999'
	and year(mc.fecha) = 2007
	and mc.anulada = 0
GROUP BY
	c.nombre,
	c.cp
order by
	4 desc
/*

7. RECUPERACI�N DE DATOS DE VARIAS TABLAS CON SUBCONSULTA Y AGRUPAMIENTO

El vendedor SIKORA ARIEL (144) fue quien mas ventas logr� en el a�o 2005 (en importe total). 

Se le solicita determinar qu� vendedores lo superaron (en importe total) en el a�o 2006. Debe excluir ventas anuladas en todas las consultas.

Mostrar VENDEDOR, NOMBRE, ENCARGADO (S o N), IMPORTE TOTAL. Ordene el resultado por importe total en forma decreciente.

TABLAS: vencab y vendedores (consulta principal), vencab (subconsulta). EL RESULTADO DEBE RETORNAR 4 FILAS.

*/
SELECT 
	v.vendedor,
	v.nombre,
	v.encargado,
	Sum(vc.total) as 'IMPORTE TOTAL'
FROM vencab vc
	INNER JOIN vendedores v on (vc.vendedor = v.vendedor)
where 
	vc.anulada = 0
	and year(vc.fecha) = 2006
GROUP BY
	v.vendedor,
	v.nombre,
	v.encargado
HAVING
 Sum(vc.total) > (select sum(total) from vencab where vendedor = 144 and year(fecha) = 2005)
order by
	4 desc
/*

8. INSERCI�N SIMPLE

En la empresa ha ingresado un nuevo vendedor: LASPINA MARCELA (dni 30401211). Realice la instrucci�n correspondiente para 
darla de alta en la tabla VENDEDORES, teniendo en cuenta:
	- Determine previamente en una consulta el c�digo (columna VENDEDOR) que le corresponder�a, sum�ndole 1 al m�ximo valor.
	- La sucursal donde ingresa es VILLA CABRERA (determine el c�digo previamente)
	- La fecha de ingreso debe ser tomada en el momento de la inserci�n.
	- El nuevo vendedor deber� estar ACTIVO (activo = 'S'), y ser� ENCARGADO (encargado = 'S').

*/
SELECT * FROM vendedores
SELECT max(vendedor) + 1 FROM vendedores
SELECT sucursal FROM sucursales where denominacion = 'VILLA CABRERA'
SELECT GETDATE ()

INSERT INTO vendedores
	(vendedor,nombre,sucursal,dni,ingreso,encargado,activo)
VALUES
	(1052,'LASPINA MARCELA',5,30401211,getdate(),'S','S')

SELECT * FROM vendedores where vendedor = 1052
/*

9. INSERCI�N MASIVA CON CREACI�N DE TABLA

Utilizando SELECT..INTO cree la tabla TmpVentasAccesorios. Esta tabla debe mostrar el total de ventas por rubro de
art�culo. Deber� incluir solamente los rubros: 76, 85, 77, 97, 70, 72, 87, 88.

La estructura de la tabla debe ser RUBRO (c�digo), NOMBRE, TOTAL (el total vendido de ese rubro). Tenga en cuenta:
	- Excluya ventas anuladas.
	- La nueva tabla deber� tener UNA FILA POR RUBRO, mostrando el importe total vendido.
	- Calcular el total vendido utilizando CANTIDAD * PRECIO de la tabla VENDET.

TABLAS: rubros, vencab, vendet, articulos (para el SELECT CON AGRUPAMIENTO). 

LA NUEVA TABLA DEBER� TENER 7 FILAS, UNA POR RUBRO (el rubro 72 no tuvo ventas).

*/
SELECT 
	r.rubro,
	r.nombre,
	sum(vt.precio*vt.cantidad) as 'TOTAL_VENTAS'
INTO TmpVentasAccesorios
FROM vendet vt
	inner join vencab vc on(vc.factura = vt.factura and vc.letra = vt.letra)
	inner join articulos a on (vt.articulo = a.articulo)
	inner join rubros r on (a.rubro = r.rubro)
WHERE 
	r.rubro in (76, 85, 77, 97, 70, 72, 87, 88)
GROUP BY
	r.rubro,
	r.nombre

SELECT * FROM TmpVentasAccesorios
/*

10. INSERCI�N MASIVA A TABLA EXISTENTE

Utilizando INSERT..SELECT agregue a la tabla TmpVentasAccesorios las ventas de art�culos de los rubros 89 y 99.

Tome como base la consulta del punto anterior.

TABLAS: rubros, vencab, vendet, articulos (para el SELECT). 

SE DEBER�N INSERTAR 2 FILAS EN LA TABLA.

*/
INSERT INTO TmpVentasAccesorios
SELECT 
	r.rubro,
	r.nombre,
	sum(vt.precio*vt.cantidad) as 'TOTAL_VENTAS'
FROM vendet vt
	inner join vencab vc on(vc.factura = vt.factura and vc.letra = vt.letra)
	inner join articulos a on (vt.articulo = a.articulo)
	inner join rubros r on (a.rubro = r.rubro)
WHERE 
	r.rubro in (89,99)
GROUP BY
	r.rubro,
	r.nombre
SELECT * FROM TmpVentasAccesorios
/*

11. ACTUALIZACI�N MASIVA DE FILAS

Reemplazar con valor 0 (cero) las columnas TERMINALPOSNET y CENTROCOSTO de la tabla SUCURSALES, solamente para aquellas
sucursales que NO est�n activas (Activa = 'N').

SE DEBEN ACTUALIZAR 4 FILAS DE LA TABLA SUCURSAL.

*/
UPDATE sucursales
SET terminalposnet = 0, centrocosto = 0
WHERE 
	Activa = 'N'

/*

12. ELIMINACI�N MASIVA DE FILAS

Borre de la tabla TmpVentasAccesorios creada en el punto 9 y actualizada en el punto 10, las filas correspondientes a los
rubros que NO superaron los 20.000 en el total de ventas.

SE DEBEN ELIMINAR 4 FILAS DE LA TABLA.

*/
DELETE FROM TmpVentasAccesorios 
WHERE TOTAL_VENTAS <= 20000

--BORRE TODO DE LA TABLA
TRUNCATE TABLE TmpVentasAccesorios
--ESTE TAMBINE LO HACE
DELETE TmpVentasAccesorios
--BORRE LA TALBA
DROP TABLE TmpVentasAccesorios


/*

13. MODIFICACION DE DATOS CON TRANSACCIONES

Implemente en un bloque BEGIN TRANSACTION el borrado de TODAS las filas de la tabla GASTOS (tiene 3 filas).

Verifique si qued� vac�a (con 0 filas) y en caso afirmativo haga ROLLBACK para volver a la situaci�n inicial (con 3 filas).

*/

BEGIN TRANSACTION 
	DELETE gastos 
		if EXISTS(select * from gastos)
			COMMIT TRANSACTION
		ELSE 
			ROLLBACK TRANSACTION 

/*

14. PROCEDIMIENTO ALMACENADO SIMPLE

Cree el procedimiento almacenado "sp_articulos_marca" que retorne solamente la cantidad de art�culos perteneciente
a una determinada marca. La marca debe ser solicitada como par�metro de entrada por el procedimiento.

Debe mostrar el mensaje "Existen [cantidad] art�culos de la marca [c�digo]."

Ejecute el procedimiento con la marca 'B' para probar. DEBE RETORNAR EL MENSAJE: Existen 1510 art�culos de la marca B.

*/
SELECT * FROM articulos
ALTER PROCEDURE sp_articulos_marca
	@marca char(1)
AS
DECLARE 
	@c int
BEGIN
	SELECT @c = COUNT(*) 
	FROM articulos
	where marca = @marca

	PRINT 'Existen ' + trim(str(@c)) +' articulos de la marca ' + @marca
END

EXEC sp_articulos_marca 'B'
/*

15. PROCEDIMIENTO ALMACENADO CON MANEJO DE ERRORES

Implemente un procedimiento almacenado que permita insertar nuevos rubros en la tabla correspondiente.

El procedimiento deber� tener el nombre "sp_inserta_rubro", y debe solicitar como par�metros de entrada 
el CODIGO (rubro) y NOMBRE.

Utilice manejo de transacciones para volver atr�s la inserci�n en caso de error.

Se deber� validar la ocurrencia de errores, mostrando los siguientes mensajes:
	- El rubro [c�digo] ya existe en la tabla. (CUANDO SE QUIERA INGRESAR UN RUBRO EXISTENTE).
	- El rubro [nombre] fue dado de alta correctamente. (EN CASO DE �XITO)
	- Se produjo un error durante la inserci�n. (EN CASO DE QUE FALLE LA INSERCI�N)

Realice dos ejecuciones de prueba, una con un rubro nuevo, y otra con un rubro existente.

*/
ALTER PROCEDURE sp_inserta_rubro
	@codigo int,
	@nombre char(30)
AS
DECLARE
	@e int
BEGIN
	BEGIN TRANSACTION 
			INSERT INTO rubros
				(rubro,nombre)
			VALUES
				(@codigo,@nombre)
	SET @e = @@ERROR
		IF @e = 0
			BEGIN 
				COMMIT TRANSACTION
				PRINT 'El rubro ' + TRIM(@nombre) + ' se insert� correctamente.'
			END
		ELSE
			BEGIN
				ROLLBACK TRANSACTION
				IF @e = 2627
				PRINT 'El rubro ' + TRIM(STR(@codigo)) + ' ya existe en la tabla.'
			ELSE
				PRINT 'Se produjo un error durante la inserci�n.'
		END
END
--
select max(rubro) FROM rubros
--
EXEC sp_inserta_rubro 100, 'PERRO'
--
DELETE rubros FROM rubros where rubro = 100
/*

16. PROCEDIMIENTO ALMACENADO CON USO DE TRY / CATCH

Implemente el mismo procedimiento anterior, con el mismo comportamiento, pero utilizando para el manejo de errores
los bloques TRY y CATCH.

Realice dos ejecuciones de prueba, una con un rubro nuevo, y otra con un rubro existente.

*/

ALTER PROCEDURE sp_inserta_rubro
	@codigo int,
	@nombre char(30)
AS

BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO rubros
			(rubro,nombre)
		VALUES
			(@codigo,@nombre)
	COMMIT TRANSACTION
	PRINT 'El rubro ' + TRIM(@nombre) + ' se insert� correctamente.'
END TRY

BEGIN CATCH 
	ROLLBACK TRANSACTION 
	IF ERROR_NUMBER() = 2627
		PRINT 'El rubro ' + TRIM(STR(@codigo)) + ' ya existe en la tabla.'
	ELSE
		PRINT 'Se produjo un error durante la inserci�n.'
END CATCH

EXEC sp_inserta_rubro 100, 'PERRO'

select max(rubro) FROM rubros 

DELETE rubros FROM rubros where rubro = 100
		