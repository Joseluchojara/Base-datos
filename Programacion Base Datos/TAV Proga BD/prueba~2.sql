 DECLARE
    CURSOR C_DATOS ID_VENDEDOR
                    ,RUT_VENDEDOR
                    ,SUELDO
                    ,ID_CATEGORIA
                    ,ID_GRUPO
                        FROM VENDEDOR;
        R_DATOS C_DATOS%ROWTYPE;
        
        V_ID_VENDEDOR HABER_MES_VENDEDOR.ID_VENDEDOR%TYPE;
        V_NUMRUT_VENDEDOR	HABER_MES_VENDEDOR.NUMRUT_VENDEDOR%TYPE;
        V_MES_PROCESO	HABER_MES_VENDEDOR.MES_PROCESO%TYPE := 5;
        V_ANNO_PROCESO HABER_MES_VENDEDOR.ANNO_PROCESO%TYPE := 2021;	
        V_SUELDO_BASE	HABER_MES_VENDEDOR.SUELDO_BASE%TYPE;
        V_ASIG_ANTIGUEDAD	HABER_MES_VENDEDOR.ASIG_ANTIGUEDAD%TYPE;
        V_ASIG_CARGA_FAM	HABER_MES_VENDEDOR.ASIG_CARGA_FAM%TYPE;
        V_COMISION_VENTAS	HABER_MES_VENDEDOR.COMISION_VENTAS%TYPE;
        V_BONO_CATEG	HABER_MES_VENDEDOR.BONO_CATEG%TYPE;
        V_TOTAL_HABERES	HABER_MES_VENDEDOR.TOTAL_HABERES%TYPE;
        
        V_PORCETANJE_ANTIGUEDAD BONIFICACIONES_ANNIO.PORC_BONIF%TYPE;
        V_ANNIOS_TRABAJANDO INT;
        V_CANTIDAD_CARGAS INT;
        V_PORCENTAJE_CATEGORIA CATEGORIA.PORCENTAJE%TYPE;
        V_VENTAS_RENTAS COMISION_VENTA
BEGIN
    OPEN C_DATOS
    LOOP
        FETCH C_DATOS INTO R_DATOS
        EXIT WHEN C_DATOS%NOTFOND;
        
        V_ID_VENDEDOR := R_DATOS.ID_VENDEDOR;
        V_NUMRUT_VENDEDOR := R_DATOS.RUT_VENDEDOR;
        V_SUELDO_BASE := R_DATOS.SUELDO;
        
        V_ANNIOS_TRABAJANDO := MONTHSS_BETWEEN(SYSDATE,R_DATOS.FECCONTRATO)/12);
        SELECT PORC_BONIF INTO V_PORCENTAJE_ANTIGUEDAD
                        FROM BONIFICACIONES_ANTIG
                        WHERE V_ANNOS_TRABAJANDO BETWEEN ANTIG_INF AND ANTIG_SUP;
                        
        V_ASIG_ATIEGUEDAD := V_SUELDO_BASE * (V_PORCENTAJE_ANTIGUEDAD/100);                
        
        --V_CANTIDAD_CARGAS
        
        V_ASIG_CARGAS := V_CANTIDAD_CARGAS * 6300;
    
        
        --V_COMISIONES := 
        SELECT NVL(SUM(MONTO_COMISION)) INTO V_COMISIONES FROM COMISION_VENTA
                                    WHERE ID_VENDEDOR =V_ID_VENDEDOR
                                    AND MES = V_MES_PROCESO
                                    AND ANNIO= V_ANIIO_PROCESO;
        
        V_VENTAS_NETAS
        SELECT NVL(SUM(TOTAL_VENTAS))  INTO V_VENTAS_NETAS FROM COMISION_VENTA
                WHERE ID_VENDEDOR = 20
                AND ANNIO = V_ANNIO_PROCESO
                AND MES= V_MES_PROCESO
                
        IF R_DATOS.ID_CATEGORIA = 'A' OR R_DATOS.ID_CATEGORIA = 'B' OR R_DATOS.ID_CATEGORIA= 'C')
        THEN V_BONO_CATEO
        
        --V_BONO_POS
        IF (V_VENTAS_NETAS > 5500000)
            THEN V_BONO_GRUPOS := CASE R_DATOS.ID_GRUPO
                                WHEN 'A' THEN V_SUELDO_BASE * 35/100
                                WHEN 'B' THEN V_SUELDO_BASE * 30/100
                                WHEN 'C' THEN V_SUELDO_BASE * 25/100
                                WHEN 'D' THEN V_SUELDO_BASE * 20/100
                                ELSE V_SUELDO_BASE *(15/100)
                                END;
        ELSE V_BONO_GRUPOS := 0;
        END IF;
        
        V_DESCUENTOS
            SELECT NVL(SUM(MONTO), 0) INTO V_DESCUENTOS FROM ANTICIPO
                                        WHERE ID_VENDEDOR = V_ID_VENDEDOR
                                        AND MES = V_MES_PROCESO - 1);
        V_TOTAL_HABERES :=SUELDO_BASE
                        + ASIG_ANTIGUEDAD
                        + ASIG_CARGA_FAM
                        + COMISION_VENTAS
                        + BONO_CATEG
                        + V_BONO_GRUPOS
                        - V_DESCUENTOS;
        
        INSERT INTO HABER_MES(ID_VENDEDOR
                                ,NUMRUT_VENDEDOR
                                ,MES_PROCESO
                                ,ANNO_PROCESO
                                ,SUELDO_BASE
                                ,ASIG_ANTIGUEDAD
                                ,ASIG_CARGA_FAM
                                ,COMISION_VENTAS
                                ,BONO_CATEG
                                ,TOTAL_HABERES)
                        VALUES(V_ID_VENDEDOR
                                    V_NUMRUT_VENDEDOR
                                    V_MES_PROCESO
                                    V_ANNO_PROCESO
                                    V_SUELDO_BASE
                                    V_ASIG_ANTIGUEDAD
                                    V_ASIG_CARGA_FAM
                                    V_COMISION_VENTAS
                                    V_BONO_CATEG
                                    V_TOTAL_HABERES);
        -- Mostrar los resultados en la consola
        DBMS_OUTPUT.PUT_LINE(
            V_ID_VENDEDOR || ' ' || V_NUMRUT_VENDEDOR || ' ' || V_MES_PROCESO ||
            ' ' || V_ANNO_PROCESO || ' ' || V_SUELDO_BASE || ' ' || V_ASIG_ANTIGUEDAD ||
            ' ' || V_ASIG_CARGA_FAM || ' ' || V_COMISION_VENTAS || ' ' || V_BONO_CATEG ||
            ' ' || V_TOTAL_HABERES
        );
        END LOOP;
        CLOSE C_DATOS;

END;




