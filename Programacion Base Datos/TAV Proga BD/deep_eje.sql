1. Paquete con Funciones y Procedimientos (Dentro del mismo Package)
Especificación del Paquete (Package Specification)

CREATE OR REPLACE PACKAGE mi_paquete AS
    -- Funciones
    FUNCTION calcular_bono(salario NUMBER, porcentaje NUMBER) RETURN NUMBER;
    FUNCTION contar_empleados(id_departamento NUMBER) RETURN NUMBER;
    FUNCTION obtener_nombre_departamento(id_departamento NUMBER) RETURN VARCHAR2;
    
    -- Procedimientos
    PROCEDURE listar_empleados; 
    PROCEDURE aumentar_salarios(porcentaje NUMBER);
    PROCEDURE eliminar_empleados_departamento(id_departamento NUMBER);
END mi_paquete;
/
Cuerpo del Paquete (Package Body)

CREATE OR REPLACE PACKAGE BODY mi_paquete AS
    -- Función 1: Calcula un bono del X% sobre el salario
    FUNCTION calcular_bono(salario NUMBER, porcentaje NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN salario * (porcentaje / 100);
    END calcular_bono;

    -- Función 2: Cuenta empleados en un departamento
    FUNCTION contar_empleados(id_departamento NUMBER) RETURN NUMBER IS
        total_empleados NUMBER;
    BEGIN
        SELECT COUNT(*) INTO total_empleados
        FROM empleados
        WHERE departamento_id = id_departamento;
        RETURN total_empleados;
    END contar_empleados;

    -- Función 3: Obtiene nombre del departamento
    FUNCTION obtener_nombre_departamento(id_departamento NUMBER) RETURN VARCHAR2 IS
        nombre_departamento VARCHAR2(100);
    BEGIN
        SELECT nombre INTO nombre_departamento
        FROM departamentos
        WHERE id = id_departamento;
        RETURN nombre_departamento;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Departamento no encontrado';
    END obtener_nombre_departamento;

    -- Procedimiento 1: Listar empleados con cursor
    PROCEDURE listar_empleados IS
        CURSOR c_empleados IS
            SELECT id, nombre, salario
            FROM empleados;
        v_id empleados.id%TYPE;
        v_nombre empleados.nombre%TYPE;
        v_salario empleados.salario%TYPE;
    BEGIN
        OPEN c_empleados;
        LOOP
            FETCH c_empleados INTO v_id, v_nombre, v_salario;
            EXIT WHEN c_empleados%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Nombre: ' || v_nombre || ', Salario: ' || v_salario);
        END LOOP;
        CLOSE c_empleados;
    END listar_empleados;

    -- Procedimiento 2: Actualizar salarios con cursor
    PROCEDURE aumentar_salarios(porcentaje NUMBER) IS
        CURSOR c_empleados IS
            SELECT id, salario
            FROM empleados
            FOR UPDATE;
        v_nuevo_salario NUMBER;
    BEGIN
        FOR emp IN c_empleados LOOP
            v_nuevo_salario := emp.salario * (1 + porcentaje/100);
            UPDATE empleados
            SET salario = v_nuevo_salario
            WHERE CURRENT OF c_empleados;
        END LOOP;
        COMMIT;
    END aumentar_salarios;

    -- Procedimiento 3: Eliminar empleados de un departamento
    PROCEDURE eliminar_empleados_departamento(id_departamento NUMBER) IS
        CURSOR c_emp IS
            SELECT id
            FROM empleados
            WHERE departamento_id = id_departamento
            FOR UPDATE;
    BEGIN
        FOR emp IN c_emp LOOP
            DELETE FROM empleados
            WHERE CURRENT OF c_emp;
        END LOOP;
        COMMIT;
    END eliminar_empleados_departamento;

END mi_paquete;
/
2. Triggers (Fuera del Paquete, ya que son objetos independientes)
Trigger 1: Auditoría de cambios en salarios

CREATE OR REPLACE TRIGGER tr_auditar_salario
BEFORE UPDATE ON empleados
FOR EACH ROW
BEGIN
    IF :OLD.salario <> :NEW.salario THEN
        INSERT INTO auditoria_empleados (empleado_id, salario_anterior, salario_nuevo, fecha)
        VALUES (:OLD.id, :OLD.salario, :NEW.salario, SYSDATE);
    END IF;
END;
/
Trigger 2: Validar aumento máximo del 20%
sql
Copy
CREATE OR REPLACE TRIGGER tr_validar_aumento
BEFORE UPDATE ON empleados
FOR EACH ROW
BEGIN
    IF :NEW.salario > :OLD.salario * 1.20 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El aumento no puede superar el 20%');
    END IF;
END;
/
Trigger 3: Histórico al eliminar empleados
sql
Copy
CREATE OR REPLACE TRIGGER tr_historico_eliminacion
AFTER DELETE ON empleados
FOR EACH ROW
BEGIN
    INSERT INTO historico_empleados (id, nombre, fecha_eliminacion)
    VALUES (:OLD.id, :OLD.nombre, SYSDATE);
END;
/
/*
Explicaciones Clave
Paquete:

Funciones y Procedimientos están agrupados dentro del mismo paquete (mi_paquete).

Las funciones se llaman usando mi_paquete.nombre_funcion(...).

Los procedimientos se ejecutan con mi_paquete.nombre_procedimiento(...).

Procedimientos con Cursores:

listar_empleados: Usa un cursor explícito para recorrer todos los empleados.

aumentar_salarios: Usa un cursor con FOR UPDATE para modificar salarios de forma segura.

eliminar_empleados_departamento: Elimina empleados de un departamento usando un cursor.

Triggers:

Son objetos independientes (no pueden estar dentro de un paquete).

Usan OLD y NEW para acceder a valores antiguos y nuevos de las filas.
*/
Cómo Usar el Paquete y Triggers

Llamar a una Función del Paquete:

SELECT mi_paquete.calcular_bono(3000, 15) FROM DUAL; -- Retorna 450 (15% de 3000)
--Ejecutar un Procedimiento del Paquete:

BEGIN
    mi_paquete.listar_empleados(); -- Lista todos los empleados
    mi_paquete.aumentar_salarios(10); -- Aumenta salarios en 10%
END;
Ejemplo de Trigger en Acción:

-- Al actualizar un salario, el trigger tr_auditar_salario registra el cambio.
UPDATE empleados SET salario = 3500 WHERE id = 100