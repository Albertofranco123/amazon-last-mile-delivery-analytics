-- Amazon Last-Mile Delivery Analytics
-- Data Quality & Exploratory Data Analysis (EDA)
-- Engine: Amazon Athena
-- Tables: packages, routes, stops

-- ============================================================
-- 1. PACKAGE GRAIN / UNIQUENESS
-- Expected grain: one row per package within route + stop
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(
        DISTINCT CONCAT(route_id, '|', stop_id, '|', package_id)
    ) AS unique_packages
FROM packages;


-- ============================================================
-- 2. PACKAGE NULL CHECKS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN route_id IS NULL THEN 1 ELSE 0 END) AS route_id_nulls,
    SUM(CASE WHEN stop_id IS NULL THEN 1 ELSE 0 END) AS stop_id_nulls,
    SUM(CASE WHEN package_id IS NULL THEN 1 ELSE 0 END) AS package_id_nulls,
    SUM(CASE WHEN scan_status IS NULL THEN 1 ELSE 0 END) AS scan_status_nulls,
    SUM(CASE WHEN time_window_start IS NULL THEN 1 ELSE 0 END) AS time_window_start_nulls,
    SUM(CASE WHEN time_window_end IS NULL THEN 1 ELSE 0 END) AS time_window_end_nulls,
    SUM(CASE WHEN planned_service_time_seconds IS NULL THEN 1 ELSE 0 END) AS service_time_nulls,
    SUM(CASE WHEN depth_cm IS NULL THEN 1 ELSE 0 END) AS depth_nulls,
    SUM(CASE WHEN height_cm IS NULL THEN 1 ELSE 0 END) AS height_nulls,
    SUM(CASE WHEN width_cm IS NULL THEN 1 ELSE 0 END) AS width_nulls
FROM packages;


-- ============================================================
-- 3. PACKAGE NUMERIC VALIDITY CHECKS
-- ============================================================

SELECT
    SUM(CASE WHEN depth_cm <= 0 THEN 1 ELSE 0 END) AS invalid_depth,
    SUM(CASE WHEN height_cm <= 0 THEN 1 ELSE 0 END) AS invalid_height,
    SUM(CASE WHEN width_cm <= 0 THEN 1 ELSE 0 END) AS invalid_width,
    SUM(CASE WHEN planned_service_time_seconds < 0 THEN 1 ELSE 0 END) AS negative_service_time
FROM packages;


-- ============================================================
-- 4. INVESTIGATE INVALID HEIGHT VALUES
-- 24 packages were found with height_cm = 0
-- ============================================================

SELECT
    route_id,
    stop_id,
    package_id,
    height_cm,
    depth_cm,
    width_cm,
    scan_status,
    planned_service_time_seconds
FROM packages
WHERE height_cm <= 0
ORDER BY height_cm;


-- ============================================================
-- 5. TIME-WINDOW MISSINGNESS CONSISTENCY
-- ============================================================

SELECT
    SUM(
        CASE
            WHEN time_window_start IS NULL
             AND time_window_end IS NULL
            THEN 1 ELSE 0
        END
    ) AS both_null,

    SUM(
        CASE
            WHEN time_window_start IS NOT NULL
             AND time_window_end IS NOT NULL
            THEN 1 ELSE 0
        END
    ) AS both_present,

    SUM(
        CASE
            WHEN time_window_start IS NULL
             AND time_window_end IS NOT NULL
            THEN 1 ELSE 0
        END
    ) AS missing_start_only,

    SUM(
        CASE
            WHEN time_window_start IS NOT NULL
             AND time_window_end IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_end_only
FROM packages;


-- ============================================================
-- 6. ROUTE DATA QUALITY CHECKS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    -- NULL checks
    SUM(CASE WHEN route_id IS NULL THEN 1 ELSE 0 END) AS route_id_nulls,
    SUM(CASE WHEN station_code IS NULL THEN 1 ELSE 0 END) AS station_code_nulls,
    SUM(CASE WHEN route_date IS NULL THEN 1 ELSE 0 END) AS route_date_nulls,
    SUM(CASE WHEN departure_time_utc IS NULL THEN 1 ELSE 0 END) AS departure_time_nulls,
    SUM(CASE WHEN executor_capacity_cm3 IS NULL THEN 1 ELSE 0 END) AS capacity_nulls,
    SUM(CASE WHEN route_score IS NULL THEN 1 ELSE 0 END) AS route_score_nulls,

    -- Zero-value check
    SUM(CASE WHEN executor_capacity_cm3 = 0 THEN 1 ELSE 0 END) AS capacity_zeros
FROM routes;


-- ============================================================
-- 7. STOP DATA QUALITY CHECKS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN route_id IS NULL THEN 1 ELSE 0 END) AS route_id_nulls,
    SUM(CASE WHEN stop_id IS NULL THEN 1 ELSE 0 END) AS stop_id_nulls,
    SUM(CASE WHEN station_code IS NULL THEN 1 ELSE 0 END) AS station_code_nulls,
    SUM(CASE WHEN route_date IS NULL THEN 1 ELSE 0 END) AS route_date_nulls,
    SUM(CASE WHEN route_score IS NULL THEN 1 ELSE 0 END) AS route_score_nulls,
    SUM(CASE WHEN latitude IS NULL THEN 1 ELSE 0 END) AS latitude_nulls,
    SUM(CASE WHEN longitude IS NULL THEN 1 ELSE 0 END) AS longitude_nulls,
    SUM(CASE WHEN stop_type IS NULL THEN 1 ELSE 0 END) AS stop_type_nulls,
    SUM(CASE WHEN zone_id IS NULL THEN 1 ELSE 0 END) AS zone_id_nulls,
    SUM(CASE WHEN latitude < -90 OR latitude > 90 THEN 1 ELSE 0 END) AS invalid_latitudes,
    SUM(CASE WHEN longitude < -180 OR longitude > 180 THEN 1 ELSE 0 END) AS invalid_longitudes
FROM stops;
