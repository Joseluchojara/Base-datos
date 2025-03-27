SELECT TO_CHAR(c.numrun,'09G999G999') || '-' || UPPER(c.dvrun) "RUN CLIENTE",
       INITCAP(c.pnombre || ' ' || c.snombre || ' ' || c.appaterno || ' ' || c.apmaterno) "NOMBRE CLIENTE",
       pi.nombre_prod_inv "PRODUCTO DE INVERSION",
       pic.monto_total_ahorrado "MONTO TOTAL AHORRADO"
FROM cliente c JOIN producto_inversion_cliente pic
ON c.nro_cliente = pic.nro_cliente
JOIN producto_inversion pi
ON pic.cod_prod_inv=pi.cod_prod_inv
AND EXTRACT(YEAR FROM pic.fecha_solic_prod)=EXTRACT(YEAR FROM SYSDATE)
AND c.cod_tipo_contrato = 1
ORDER BY c.appaterno;

