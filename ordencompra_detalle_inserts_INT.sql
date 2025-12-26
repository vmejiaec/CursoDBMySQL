-- Archivo SQL para MySQL: Inserciones en ordencompra_detalle (cantidad INT < 30)
USE SaludTotal;

START TRANSACTION;

-- (Opcional) Limpiar la tabla si fuera necesario
-- TRUNCATE TABLE ordencompra_detalle;

-- 1) Incluir medicina_id=36 dos veces: en una orden con fecha 2024 y otra con fecha 2025
INSERT INTO ordencompra_detalle (ordennumero, medicamento_id, cantidad, costo)
SELECT (
  SELECT numero FROM ordencompra WHERE YEAR(fecha)=2024 ORDER BY fecha LIMIT 1
), 36, 1 + FLOOR(RAND()*29), (SELECT precio FROM medicinas WHERE id=36);

INSERT INTO ordencompra_detalle (ordennumero, medicamento_id, cantidad, costo)
SELECT (
  SELECT numero FROM ordencompra WHERE YEAR(fecha)=2025 ORDER BY fecha LIMIT 1
), 36, 1 + FLOOR(RAND()*29), (SELECT precio FROM medicinas WHERE id=36);

-- 2) Preparar número de detalles por orden (2 o 3) y excluir las órdenes ya usadas para med 36
CREATE TEMPORARY TABLE tmp_oc_det AS
SELECT oc.numero AS ordennumero,
       CASE WHEN RAND() < 0.5 THEN 2 ELSE 3 END AS max_det,
       YEAR(oc.fecha) AS anio
FROM ordencompra oc;

DELETE FROM tmp_oc_det
WHERE ordennumero IN (
  (SELECT numero FROM ordencompra WHERE YEAR(fecha)=2024 ORDER BY fecha LIMIT 1),
  (SELECT numero FROM ordencompra WHERE YEAR(fecha)=2025 ORDER BY fecha LIMIT 1)

-- 3) Insertar 2-3 detalles por orden con medicinas 30..119; evitar repetir medicina en la misma orden
INSERT INTO ordencompra_detalle (ordennumero, medicamento_id, cantidad, costo)
SELECT t.ordennumero, t.medicina_id, 1 + FLOOR(RAND()*29) AS cantidad, m.precio AS costo
FROM (
  SELECT d.ordennumero, m.id AS medicina_id,
         ROW_NUMBER() OVER (PARTITION BY d.ordennumero ORDER BY RAND()) AS rn
  FROM tmp_oc_det d
  JOIN medicinas m ON m.id BETWEEN 30 AND 119
) AS t
JOIN tmp_oc_det d2 ON d2.ordennumero = t.ordennumero
JOIN medicinas m ON m.id = t.medicina_id
WHERE t.rn <= d2.max_det
  AND NOT (t.medicina_id = 36 AND t.ordennumero IN (
    (SELECT numero FROM ordencompra WHERE YEAR(fecha)=2024 ORDER BY fecha LIMIT 1),
    (SELECT numero FROM ordencompra WHERE YEAR(fecha)=2025 ORDER BY fecha LIMIT 1)
  ));

DROP TEMPORARY TABLE IF EXISTS tmp_oc_det;

COMMIT;