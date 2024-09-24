/*
    Trigger: ActualizarInventario

    Descripción:
    Este trigger se ejecuta automáticamente después de que se inserta un nuevo registro en la tabla `Detalle_Factura`.
    Su propósito es:
    1. Actualizar el stock de los productos en la tabla `Producto` según la cantidad comprada.
    2. Registrar la operación en la tabla `Auditoria`, incluyendo información sobre el empleado que realizó la venta, 
       el producto vendido y la cantidad comprada.

    Tablas involucradas:
    - Detalle_Factura: Contiene el detalle de cada producto incluido en una factura.
    - Producto: Almacena información sobre cada producto, incluido su stock disponible.
    - Factura: Almacena información general sobre las facturas emitidas, incluyendo el cliente y el empleado.
    - Auditoria: Guarda un registro de las operaciones importantes, como la venta de productos.
*/

DELIMITER //

CREATE TRIGGER ActualizarInventario
AFTER INSERT ON Detalle_Factura
FOR EACH ROW
BEGIN
    /*
        1. Actualización del stock del producto:
        Se descuenta del stock la cantidad comprada registrada en `Detalle_Factura` (NEW.Cantidad).
        El producto afectado es el que corresponde al ID en `NEW.ID_Producto`.
    */
    UPDATE Producto
    SET Stock = Stock - NEW.Cantidad
    WHERE ID_Producto = NEW.ID_Producto;
    
    /*
        2. Registro en la tabla Auditoria:
        Se registra la operación realizada, especificando:
        - ID del empleado que gestionó la factura (obtenido de la tabla Factura a través de NEW.ID_Factura).
        - Una descripción de la operación que incluye el ID del producto vendido y la cantidad.
        - La fecha y hora en que ocurrió la operación (NOW()).
    */
    INSERT INTO Auditoria (ID_Usuario, Operacion, Fecha)
    VALUES (
        (SELECT ID_Empleado FROM Factura WHERE ID_Factura = NEW.ID_Factura),  -- Empleado que realizó la venta
        CONCAT('Venta de producto ID: ', NEW.ID_Producto, ' Cantidad: ', NEW.Cantidad),  -- Descripción de la operación
        NOW()  -- Fecha y hora de la operación
    );
END//

DELIMITER ;

/*
    Ejemplo de uso:
    1. Inserta una nueva factura en la tabla `Factura`.
    2. Inserta el detalle de los productos vendidos en `Detalle_Factura`.
    3. El trigger `ActualizarInventario` se ejecutará automáticamente y hará lo siguiente:
       - Descontará del stock el número de unidades vendidas de cada producto.
       - Insertará un registro en la tabla `Auditoria` con información sobre la venta.
*/
