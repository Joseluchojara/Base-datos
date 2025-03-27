/*1. Creación del Paquete
Un paquete en PL/SQL agrupa funciones,
procedimientos y otros elementos reutilizables.
Primero, definimos la especificación (spec) y luego el cuerpo (body).

Especificación del Paquete*/
CREATE OR REPLACE PACKAGE Gestion_Clientes AS
    FUNCTION Obtener_Saldo(p_cliente_id NUMBER) RETURN NUMBER;
    FUNCTION Calcular_Descuento(p_cliente_id NUMBER) RETURN NUMBER;
    FUNCTION Verificar_Estado(p_cliente_id NUMBER) RETURN VARCHAR2;
    
    PROCEDURE Aplicar_Descuento(p_cliente_id NUMBER);
    PROCEDURE Registrar_Pago(p_cliente_id NUMBER, p_monto NUMBER);
    PROCEDURE Generar_Reporte_Clientes;
END Gestion_Clientes;
/
/* Explicación:
Obtener_Saldo: Retorna el saldo actual del cliente.
Calcular_Descuento: Calcula un descuento según el historial de pagos.
Verificar_Estado: Indica si un cliente es "Activo" o "Moroso".
Aplicar_Descuento: Aplica el descuento al saldo del cliente.
Registrar_Pago: Registra un pago en la base de datos.
Generar_Reporte_Clientes: Muestra un reporte con los clientes y sus estados.*/

2. Implementación del Cuerpo del Paquete

CREATE OR REPLACE PACKAGE BODY Gestion_Clientes AS

    FUNCTION Obtener_Saldo(p_cliente_id NUMBER) RETURN NUMBER IS
        v_saldo NUMBER;
    BEGIN
        SELECT saldo INTO v_saldo FROM clientes WHERE id = p_cliente_id;
        RETURN v_saldo;
    END Obtener_Saldo;

    FUNCTION Calcular_Descuento(p_cliente_id NUMBER) RETURN NUMBER IS
        v_descuento NUMBER := 0;
        v_historial_pagos NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_historial_pagos FROM pagos WHERE cliente_id = p_cliente_id;
        
        IF v_historial_pagos > 10 THEN
            v_descuento := 10;  -- 10% de descuento si tiene más de 10 pagos
        END IF;
        
        RETURN v_descuento;
    END Calcular_Descuento;

    FUNCTION Verificar_Estado(p_cliente_id NUMBER) RETURN VARCHAR2 IS
        v_saldo NUMBER;
    BEGIN
        v_saldo := Obtener_Saldo(p_cliente_id);
        RETURN CASE WHEN v_saldo > 0 THEN 'Moroso' ELSE 'Activo' END;
    END Verificar_Estado;

    PROCEDURE Aplicar_Descuento(p_cliente_id NUMBER) IS
        v_descuento NUMBER;
        v_saldo NUMBER;
    BEGIN
        v_descuento := Calcular_Descuento(p_cliente_id);
        v_saldo := Obtener_Saldo(p_cliente_id);
        
        UPDATE clientes SET saldo = saldo - (saldo * v_descuento / 100) WHERE id = p_cliente_id;
    END Aplicar_Descuento;

    PROCEDURE Registrar_Pago(p_cliente_id NUMBER, p_monto NUMBER) IS
    BEGIN
        INSERT INTO pagos (cliente_id, monto, fecha) VALUES (p_cliente_id, p_monto, SYSDATE);
        UPDATE clientes SET saldo = saldo - p_monto WHERE id = p_cliente_id;
    END Registrar_Pago;

    PROCEDURE Generar_Reporte_Clientes IS
        CURSOR c_clientes IS SELECT id, nombre, Obtener_Saldo(id) saldo FROM clientes;
        v_cliente_id NUMBER;
        v_nombre VARCHAR2(100);
        v_saldo NUMBER;
    BEGIN
        OPEN c_clientes;
        LOOP
            FETCH c_clientes INTO v_cliente_id, v_nombre, v_saldo;
            EXIT WHEN c_clientes%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre || ' - Saldo: ' || v_saldo);
        END LOOP;
        CLOSE c_clientes;
    END Generar_Reporte_Clientes;

END Gestion_Clientes;
/
/*
Explicación:
Obtener_Saldo: Recupera el saldo del cliente.
Calcular_Descuento: Aplica un descuento si el cliente tiene más de 10 pagos.
Verificar_Estado: Determina si el cliente está activo o moroso.
Aplicar_Descuento: Reduce el saldo aplicando el descuento calculado.
Registrar_Pago: Inserta un pago y actualiza el saldo del cliente.
Generar_Reporte_Clientes: Usa un cursor para recorrer la tabla y mostrar los clientes.*/

3. Uso de Cursores

DECLARE
    CURSOR c_clientes IS SELECT id, nombre, saldo FROM clientes;
    v_cliente_id NUMBER;
    v_nombre VARCHAR2(100);
    v_saldo NUMBER;
BEGIN
    OPEN c_clientes;
    LOOP
        FETCH c_clientes INTO v_cliente_id, v_nombre, v_saldo;
        EXIT WHEN c_clientes%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre || ' - Saldo: ' || v_saldo);
    END LOOP;
    CLOSE c_clientes;
END;
/
/*
Explicación:
Se declara un cursor c_clientes que obtiene los clientes.
Se abre, se recorre con un loop y se imprime la información de cada cliente.
*/



4. Creación de un Trigger con OLD y NEW

CREATE OR REPLACE TRIGGER trg_actualizar_estado_cliente
BEFORE UPDATE ON clientes
FOR EACH ROW
BEGIN
    IF :NEW.saldo = 0 THEN
        :NEW.estado := 'Activo';
    ELSE
        :NEW.estado := 'Moroso';
    END IF;
END;
/
/*
Explicación:
Se ejecuta antes de actualizar clientes.
Usa :NEW.saldo para actualizar automáticamente el estado.
Si el saldo llega a 0, cambia el estado a ‘Activo’; si no, a ‘Moroso’.
*/




4. Ejecutar un Cursor
Los cursores son parte del código PL/SQL y se ejecutan dentro de bloques BEGIN...END;.

DECLARE
    CURSOR c_clientes IS SELECT id, nombre, saldo FROM clientes;
    v_cliente_id NUMBER;
    v_nombre VARCHAR2(100);
    v_saldo NUMBER;
BEGIN
    OPEN c_clientes;
    LOOP
        FETCH c_clientes INTO v_cliente_id, v_nombre, v_saldo;
        EXIT WHEN c_clientes%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre || ' - Saldo: ' || v_saldo);
    END LOOP;
    CLOSE c_clientes;
END;
/
5. Probar el Trigger
El trigger se activa automáticamente cuando se actualiza la tabla clientes.

Ejemplo: Actualizar saldo de un cliente

UPDATE clientes SET saldo = 0 WHERE id = 1;
Luego, verifica si el estado cambió a Activo:


SELECT id, nombre, saldo, estado FROM clientes WHERE id = 1;
