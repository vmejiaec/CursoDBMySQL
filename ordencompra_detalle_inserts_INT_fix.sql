-- Archivo SQL corregido para MySQL: Inserciones en ordencompra_detalle (cantidad INT < 30)
USE SaludTotal;

START TRANSACTION;

-- Tomar la primera orden de 2024 y 2025 para asegurar la medicina 36 en ambas
SET @oc2024 := (SELECT numero FROM ordencompra WHERE YEAR(fecha)=2024 ORDER BY fecha LIMIT 1);
SET @oc2025 := (SELECT numero FROM ordencompra WHERE YEAR(fecha)=2025 ORDER BY fecha LIMIT 1);

-- Inserciones específicas para medicina_id = 36
INSERT INTO ordencompra_detalle (ordennumero, medicamento_id, cantidad, costo)
SELECT @oc2024, 36, 1 + FLOOR(RAND()*29), (SELECT precio FROM medicinas WHERE id=36);

INSERT INTO ordencompra_detalle (ordennumero, medicamento_id, cantidad, costo)
SELECT @oc2025, 36, 1 + FLOOR(RAND()*29), (SELECT precio FROM medicinas WHERE id=36);

-- Preparar número de detalles por orden (2 o 3), excluyendo @oc2024 y @oc2025
DROP TEMPORARY TABLE IF EXISTS tmp_oc_det;
CREATE TEMPORARY TABLE tmp_oc_det AS
SELECT oc.numero AS ordennumero,
       CASE WHEN RAND() < 0.5 THEN 2 ELSE 3 END AS max_det
FROM ordencompra oc
WHERE oc.numero NOT IN (@oc2024, @oc2025);

-- Insertar 2-3 detalles por orden con medicinas 30..119; evitar repetir medicina en la misma orden
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
  AND NOT (t.medicina_id = 36 AND t.ordennumero IN (@oc2024, @oc2025));

DROP TEMPORARY TABLE IF EXISTS tmp_oc_det;

COMMIT;