-- Amazon Last-Mile Delivery Analytics
-- Vehicle Capacity Analysis
-- Engine: Amazon Athena
-- Tables: packages, routes

-- ============================================================
-- QUESTION 1: How is estimated vehicle capacity utilization
-- distributed across routes?
--
-- Estimated utilization =
-- total package volume / executor vehicle capacity * 100.
--
-- NULLIF(height_cm, 0) prevents zero-height package records
-- from contributing invalid package-volume estimates.
-- Percentiles show the distribution instead of relying only
-- on the overall average.
-- ============================================================

WITH route_volume AS (
    SELECT
        route_id,
        SUM(
            depth_cm * NULLIF(height_cm, 0) * width_cm
        ) AS total_package_volume_cm3
    FROM packages
    GROUP BY route_id
),

route_utilization AS (
    SELECT
        r.route_id,
        rv.total_package_volume_cm3,
        r.executor_capacity_cm3,
        rv.total_package_volume_cm3
            / r.executor_capacity_cm3 * 100.0 AS capacity_utilization_pct
    FROM routes AS r
    JOIN route_volume AS rv
        ON r.route_id = rv.route_id
    WHERE r.executor_capacity_cm3 > 0
)

SELECT
    COUNT(*) AS total_routes,
    ROUND(MIN(capacity_utilization_pct), 2) AS min_utilization_pct,
    ROUND(APPROX_PERCENTILE(capacity_utilization_pct, 0.25), 2) AS p25_utilization_pct,
    ROUND(APPROX_PERCENTILE(capacity_utilization_pct, 0.50), 2) AS median_utilization_pct,
    ROUND(AVG(capacity_utilization_pct), 2) AS avg_utilization_pct,
    ROUND(APPROX_PERCENTILE(capacity_utilization_pct, 0.75), 2) AS p75_utilization_pct,
    ROUND(APPROX_PERCENTILE(capacity_utilization_pct, 0.90), 2) AS p90_utilization_pct,
    ROUND(MAX(capacity_utilization_pct), 2) AS max_utilization_pct
FROM route_utilization;
