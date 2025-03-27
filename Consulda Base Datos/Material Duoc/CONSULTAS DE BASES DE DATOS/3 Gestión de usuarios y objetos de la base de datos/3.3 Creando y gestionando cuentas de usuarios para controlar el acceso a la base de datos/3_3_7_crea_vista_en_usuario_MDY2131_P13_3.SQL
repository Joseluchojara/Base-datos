CREATE VIEW V_DATOS_CLIENTES AS
SELECT TO_CHAR(c.numrun,'09G999G999') || '-' || UPPER(c.dvrun) "RUN CLIENTE",
       INITCAP(c.pnombre || ' ' || c.snombre || ' ' || c.appaterno || ' ' || c.apmaterno) "NOMBRE CLIENTE",
       c.direccion || ',' || co.nombre_comuna "Dirección Cliente"
FROM syn_c c JOIN syn_r r
ON c.cod_region=r.cod_region
JOIN syn_p p
ON c.cod_region=p.cod_region AND c.cod_provincia=p.cod_provincia
JOIN syn_co co
ON c.cod_region=co.cod_region AND c.cod_provincia=co.cod_provincia AND c.cod_comuna=co.cod_comuna
ORDER BY c.appaterno;
