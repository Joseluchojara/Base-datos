declare
    CURSOR CUR_DESPIDOS IS
     SELECT EMPLOYEE_ID
                , END_DATE
                , JOB_ID
                , DEPARTAMENT_ID
            FROM JOB_HISTORY;
    TYPE TOIPO_RECORD_DESPEDIDOS IS RECORD(
    EMPLOYEE_ID NUMBER,
    FEC_TERMINO DATE,
    JOB_ID VARCHAR(10),
    DEPARTMENT_ID NUMBER
    
    );
    
    R_DESPEDIDOS TIPO_RECORD_DESPEDIDOS;
            
BEGIN
    
    IF NOT CUR_DESPEDIDOS%ISOPEN THEN
        OPEN CUR_DESPEDIDOS;
    END IF;
    
    LOOP
        FETCH CUR_DESPEDIDOS INTO R_DESPEDIDO;
    
    EXIT WHEN CUR_DESPEDIDOS%NOTFOUND;
    END LOOP;
      CLOSE CUR_DESPEDIDOS;
--------------------------------------------------------------
    
    CLOSE CUR_DESPEDIDOS;
    

END;


-------------------------------------------------------------------
declare
    CURSOR CUR_EMPLEADOS IS
    SELECT FIRST_NAME||' '||LAST_NAME NOMBRE
        ,JOB_ID
        ,SALARY+500 SUELDO
        FROM EMPLOYEES;

BEGIN

    FOR R_EMPLEADO IN CUR_EMPLEADOS
    LOOP

        DBMS_OUTPUT.put_line(R_EMPLEADO.NOMBRE||'-'||R_EMPLEADO.JOB_ID||' '||R_EMPLEADO.SUELDO);
        

    END LOOP;
    
END;
















