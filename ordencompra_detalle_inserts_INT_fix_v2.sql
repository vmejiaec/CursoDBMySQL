-- Archivo SQL corregido (sin funciones de ventana) para MySQL: Inserciones en ordencompra_detalle (cantidad INT < 30)
USE SaludTotal;

START TRANSACTION;

-- Tomar la primera orden de 2024 y 2025 para asegurar la medicina 36 en ambas
SET @oc2024 := (SELECT numero FROM ordencompra WHERE YEAR(fecha)=2024 ORDER BY fecha LIMIT 1);
SET @oc2025 := (SELECT numero FROM ordencompra WHERE YEAR(fecha)=2025 ORDER BY fecha LIMIT 1);

-- Si falta alguna orden en 2024/2025, se aborta para evitar violar FK
SELECT IF(@oc2024 IS NULL OR @oc2025 IS NULL,
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Faltan órdenes en 2024 o 2025';
       1) AS check_orders;

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

-- Generar lista de candidatos (ordennumero, medicina_id) y numerarlos por orden usando variables
DROP TEMPORARY TABLE IF EXISTS tmp_candidates;
CREATE TEMPORARY TABLE tmp_candidates AS
SELECT d.ordennumero, m.id AS medicina_id
FROM tmp_oc_det d
JOIN medicinas m ON m.id BETWEEN 30 AND 119
WHERE NOT (m.id = 36 AND d.ordennumero IN (@oc2024, @oc2025));

-- Ordenar aleatoriamente por orden y medicina para asignar rn con variables
DROP TEMPORARY TABLE IF EXISTS tmp_candidates_ord;
CREATE TEMPORARY TABLE tmp_candidates_ord AS
SELECT ordennumero, medicina_id
FROM tmp_candidates
ORDER BY ordennumero, RAND();

-- Asignar rn por orden usando variables de usuario
SET @curr_order := NULL;
SET @rn := 0;
DROP TEMPORARY TABLE IF EXISTS tmp_candidates_rn;
CREATE TEMPORARY TABLE tmp_candidates_rn AS
SELECT ordennumero, medicina_id,
       (@rn := IF(@curr_order = ordennumero, @rn + 1, 1)) AS rn,
       (@curr_order := ordennumero) AS _set_curr
FROM tmp_candidates_ord;

-- Insertar 2-3 detalles por orden según max_det, con cantidad 1..29 y costo desde medicinas.precio
INSERT INTO ordencompra_detalle (ordennumero, medicamento_id, cantidad, costo)
SELECT r.ordennumero, r.medicina_id, 1 + FLOOR(RAND()*29) AS cantidad, m.precio AS costo
FROM tmp_candidates_rn r
JOIN tmp_oc_det d ON d.ordennumero = r.ordennumero
JOIN medicinas m ON m.id = r.medicina_id
WHERE r.rn <= d.max_det;

DROP TEMPORARY TABLE IF EXISTS tmp_candidates_rn;
DROP TEMPORARY TABLE IF EXISTS tmp_candidates_ord;
DROP TEMPORARY TABLE IF EXISTS tmp_candidates;
DROP TEMPORARY TABLE IF EXISTS tmp_oc_det;

COMMIT;