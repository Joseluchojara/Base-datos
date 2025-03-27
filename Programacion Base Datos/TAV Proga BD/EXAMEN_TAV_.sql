CREATE OR REPLACE PACKAGE pkt_puntajes IS

  FUNCTION obtener_puntaje_zona_rural (cod_zona IN NUMBER) RETURN NUMBER;
  

  FUNCTION obtener_puntaje_pais (cod_pais IN NUMBER) RETURN NUMBER;
  

  v_puntaje_zona_rural NUMBER;
  v_puntaje_pueblo_ind NUMBER;
END pkt_puntajes;

CREATE OR REPLACE FUNCTION obtener_puntaje_annos_experiencia (numrun IN NUMBER) RETURN NUMBER IS
  v_puntaje NUMBER;
  v_fecha_ant DATE;
BEGIN
  SELECT MIN(fecha_contrato) INTO v_fecha_ant
  FROM ANTECEDENTES_LABORALES
  WHERE numrun = numrun;

 
  v_puntaje := (SYSDATE - v_fecha_ant) / 365;

  RETURN v_puntaje;
EXCEPTION
  WHEN OTHERS THEN
    INSERT INTO ERROR_PROCESO (numrun, rutina_error, mensaje_error)
    VALUES (numrun, 'obtener_puntaje_annos_experiencia', SQLERRM);
    RETURN 0; 
END obtener_puntaje_annos_experiencia;

CREATE OR REPLACE PROCEDURE generar_resultados_postulantes(
  p_fecha_proceso IN DATE,
  p_puntaje_extra_1 IN NUMBER,
  p_puntaje_extra_2 IN NUMBER
) IS
BEGIN

  TRUNCATE TABLE DETALLE_PUNTAJE_POSTULACION;
  TRUNCATE TABLE ERROR_PROCESO;
  TRUNCATE TABLE RESULTADO_POSTULACION;


  FOR postulante IN (SELECT numrun, nombre_postulante FROM ANTECEDENTES_PERSONALES) LOOP

    v_puntaje_zona_rural := pkt_puntajes.obtener_puntaje_zona_rural(postulante.numrun);
    v_puntaje_pueblo_ind := pkt_puntajes.obtener_puntaje_pueblo_indigena(postulante.numrun);
    v_puntaje_experiencia := obtener_puntaje_annos_experiencia(postulante.numrun);
    v_puntaje_pais := pkt_puntajes.obtener_puntaje_pais(postulante.numrun);
    

    v_puntaje_final := v_puntaje_zona_rural + v_puntaje_pueblo_ind + v_puntaje_experiencia + v_puntaje_pais;

   
    IF v_puntaje_final >= 3000 THEN
      INSERT INTO RESULTADO_POSTULACION (run_postulante, ptje_final_post, resultado_post)
      VALUES (postulante.numrun, v_puntaje_final, 'SELECCIONADO');
    ELSE
      INSERT INTO RESULTADO_POSTULACION (run_postulante, ptje_final_post, resultado_post)
      VALUES (postulante.numrun, v_puntaje_final, 'NO SELECCIONADO');
    END IF;
  END LOOP;
END generar_resultados_postulantes;



CREATE OR REPLACE TRIGGER trg_resultado_postulacion
AFTER INSERT ON DETALLE_PUNTAJE_POSTULACION
FOR EACH ROW
BEGIN
  IF :NEW.ptje_final_post >= 3000 THEN
    INSERT INTO RESULTADO_POSTULACION (run_postulante, ptje_final_post, resultado_post)
    VALUES (:NEW.run_postulante, :NEW.ptje_final_post, 'SELECCIONADO');
  ELSE
    INSERT INTO RESULTADO_POSTULACION (run_postulante, ptje_final_post, resultado_post)
    VALUES (:NEW.run_postulante, :NEW.ptje_final_post, 'NO SELECCIONADO');
  END IF;
END trg_resultado_postulacion;




