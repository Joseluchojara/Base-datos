CREATE OR REPLACE VIEW V_CLIENTES_CON_MAS_PROD_INV AS
SELECT EXTRACT(YEAR FROM SYSDATE) "AÑO TRIBUTARIO",
       TO_CHAR(c.numrun,'09G999G999') || '-' || UPPER(c.dvrun) "RUN CLIENTE",
       INITCAP(c.pnombre || ' ' || SUBSTR(c.snombre,1,1) || '. ' || c.appaterno || ' ' || c.apmaterno) "NOMBRE CLIENTE",
       COUNT(pic.nro_cliente) "TOTAL PROD. INV AFECTOS IMPTO",
       LPAD(TO_CHAR(SUM(pic.monto_total_ahorrado),'$999G999G999'),21, ' ') "MONTO TOTAL AHORRADO"
FROM cliente c JOIN producto_inversion_cliente pic
ON c.nro_cliente=pic.nro_cliente
WHERE pic.cod_prod_inv IN(30,35,40,45,50,55)
AND c.nro_cliente IN (SELECT MAX(COUNT(*))
                 FROM producto_inversion_cliente
                 GROUP BY nro_cliente)
GROUP BY numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno
ORDER BY c.appaterno;

