CREATE OR REPLACE PACKAGE PKG_TIENDA AS
    
    FUNCTION NUM_CLIENTE(correo_cli IN VARCHAR2) RETURN NUMBER;
    FUNCTION NUM_PEDIDO(cli_id IN NUMBER) RETURN NUMBER;
    FUNCTION CAN_PRODUCTOS_CLI(pedido_id IN NUMBER) RETURN NUMBER;
    FUNCTION TOTAL_PEDIDO(pedido_id IN NUMBER) RETURN NUMBER;

    -- Procedimiento para generar venta
    PROCEDURE SP_GENERA_VENTA(cli_id IN NUMBER, pedido_id IN NUMBER, cantidad_prod IN NUMBER, total IN NUMBER);
END PKG_TIENDA;
/
CREATE OR REPLACE PACKAGE BODY PKG_TIENDA AS
  
    FUNCTION NUM_CLIENTE(correo_cli IN VARCHAR2) RETURN NUMBER IS
        v_cliente_id NUMBER;
    BEGIN
        SELECT cliente_id INTO v_cliente_id
        FROM CLIENTES
        WHERE correo = correo_cli;
        RETURN v_cliente_id;
    END NUM_CLIENTE;

    -- Función para obtener el número de pedido
    FUNCTION NUM_PEDIDO(cli_id IN NUMBER) RETURN NUMBER IS
        v_pedido_id NUMBER;
    BEGIN
        SELECT pedido_id INTO v_pedido_id
        FROM PEDIDOS
        WHERE cliente_id = cli_id
        ORDER BY fecha DESC
        FETCH FIRST 1 ROWS ONLY;
        RETURN v_pedido_id;
    END NUM_PEDIDO;

    
    FUNCTION CAN_PRODUCTOS_CLI(pedido_id IN NUMBER) RETURN NUMBER IS
        v_total_cantidad NUMBER;
    BEGIN
        SELECT SUM(cantidad) INTO v_total_cantidad
        FROM DETALLE_PEDIDO
        WHERE pedido_id = pedido_id;
        RETURN v_total_cantidad;
    END CAN_PRODUCTOS_CLI;


    FUNCTION TOTAL_PEDIDO(pedido_id IN NUMBER) RETURN NUMBER IS
        v_total NUMBER := 0;
    BEGIN
        FOR rec IN (
            SELECT dp.cantidad, p.precio
            FROM DETALLE_PEDIDO dp
            JOIN PRODUCTO p ON dp.producto_id = p.producto_id
            WHERE dp.pedido_id = pedido_id
        ) LOOP
            v_total := v_total + (rec.cantidad * rec.precio);
        END LOOP;
        RETURN v_total;
    END TOTAL_PEDIDO;


    PROCEDURE SP_GENERA_VENTA(cli_id IN NUMBER, pedido_id IN NUMBER, cantidad_prod IN NUMBER, total IN NUMBER) IS
        v_nombre_cliente VARCHAR2(100);
        v_correo_cliente VARCHAR2(100);
    BEGIN
        -- Obtener datos del cliente
        SELECT nombre, correo
        INTO v_nombre_cliente, v_correo_cliente
        FROM CLIENTES
        WHERE cliente_id = cli_id;

        -- Insertar la venta en la tabla VENTA
        INSERT INTO VENTA (cliente_id, nombre, correo, pedido_id, cantidad_pro, total)
        VALUES (cli_id, v_nombre_cliente, v_correo_cliente, pedido_id, cantidad_prod, total);

        COMMIT;
    END SP_GENERA_VENTA;
END PKG_TIENDA;
/
DECLARE
    v_correo           VARCHAR2(100) := 'ROBERTO.GUERRA@GMAIL.COM';  
    v_cod_cli          NUMBER;
    v_num_pedido       NUMBER;
    v_cantidad_productos NUMBER;
    v_total            NUMBER;
BEGIN

            v_cod_cli := PKG_TIENDA.NUM_CLIENTE(v_correo);
            v_num_pedido := PKG_TIENDA.NUM_PEDIDO(v_cod_cli);
            v_cantidad_productos := PKG_TIENDA.CAN_PRODUCTOS_CLI(v_num_pedido);
            v_total := PKG_TIENDA.TOTAL_PEDIDO(v_num_pedido);
            PKG_TIENDA.SP_GENERA_VENTA(v_cod_cli, v_num_pedido, v_cantidad_productos, v_total);

END;
/

select * from VENTA;