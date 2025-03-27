 -- mi primer bloque estructura principal
-- DECLARE -- OPCIONAL
-- BEGIN
-- END;

----------------------------------------------------------------
variables escalares, soportan solo un tipo de dato
los valores se asignan a las varables por medio de clausula INTO o directamente con :=
variable de sustitución se utiliza con & para solicitar al cliente el dato a buscar

la forma de trabajo por cada bloque, el select solo ebe devolver una fila


 SET SERVEROUTPUT ON;
 DECLARE
 V_NOMBRE VARCHAR2(50);
 V_SUELDO NUMBER;
 V_EDAD NUMBER;
 V_PORCENTAJEAU NUMBER := 0.15;
 V_NUEVOSUELDO NUMBER:=0;
 v_idempleado number := &ingreseIDEMP;
 BEGIN
 SELECT FIRST_NAME || ' ' || LAST_NAME
 ,SALARY
 ,TRUNC(MONTHS_BETWEEN(SYSDATE,HIRE_DATE)/12)
 INTO V_NOMBRE,V_SUELDO,V_EDAD
 FROM EMPLOYEES
 WHERE EMPLOYEE_ID = v_idempleado;
 
 V_NUEVOSUELDO := V_SUELDO + (V_SUELDO * V_PORCENTAJEAU);
 

 DBMS_OUTPUT.PUT_LINE('NOMBRE: '|| V_NOMBRE);
 DBMS_OUTPUT.PUT_LINE('SUELDO ANTIGUO: '|| V_SUELDO);
DBMS_OUTPUT.PUT_LINE('AÑOS DE SERVICIO: '|| V_EDAD || ' AÑOS');
 DBMS_OUTPUT.PUT_LINE('SUELDO AUMENTADO: '|| V_NUEVOSUELDO);
 END;