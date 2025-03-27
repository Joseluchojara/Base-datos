CREATE OR REPLACE VIEW V_TOTAL_CREDITOS_CLIENTE AS
SELECT c.numrun || '-' || c.dvrun "RUN CLIENTE",
       INITCAP(c.pnombre || ' ' || c.snombre || ' ' || c.appaterno || ' ' || c.appaterno) "NOMBRE CLIENTE",
       COUNT(cc.nro_cliente) "CREDITOS SOLICITADOS"
FROM syn_c c JOIN syn_cc cc
ON cc.nro_cliente = c.nro_cliente
GROUP BY c.numrun, c.dvrun,c.pnombre,c.snombre,c.appaterno,c.appaterno
ORDER BY c.appaterno;

