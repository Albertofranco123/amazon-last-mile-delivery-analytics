-- Amazon Last-Mile Delivery Analytics
-- Route Quality Analysis
-- Engine: Amazon Athena
-- Tables: routes, stops, packages

-- ============================================================
-- QUESTION 1: How are routes distributed across High, Medium,
-- and Low route-quality scores?
-- ============================================================

SELECT
    route_score,
    COUNT(DISTINCT route_id) AS total_routes,
    ROUND(
        COUNT(DISTINCT route_id) * 100.0
        / SUM(COUNT(DISTINCT route_id)) OVER (),
        2
    ) AS pct_routes
FROM routes
GROUP BY route_score
ORDER BY total_routes DESC;


-- ============================================================
-- QUESTION 2: Do lower-quality routes have more stops?
-- ============================================================

WITH stops_per_route AS (
    SELECT
        r.route_id,
        r.route_score,
        COUNT(s.stop_id) AS number_of_stops
    FROM routes AS r
    JOIN stops AS s
        ON r.route_id = s.route_id
    GROUP BY r.route_id, r.route_score
)

SELECT
    route_score,
    COUNT(route_id) AS total_routes,
    SUM(number_of_stops) AS total_stops,
    ROUND(AVG(number_of_stops), 2) AS avg_stops_per_route
FROM stops_per_route
GROUP BY route_score
ORDER BY avg_stops_per_route DESC;


-- ============================================================
-- QUESTION 3: Do lower-quality routes carry more packages?
-- ============================================================

WITH packages_per_route AS (
    SELECT
        r.route_id,
        r.route_score,
        COUNT(p.package_id) AS number_of_packages
    FROM routes AS r
    JOIN packages AS p
        ON r.route_id = p.route_id
    GROUP BY r.route_id, r.route_score
)

SELECT
    route_score,
    COUNT(route_id) AS total_routes,
    SUM(number_of_packages) AS total_packages,
    ROUND(AVG(number_of_packages), 0) AS avg_packages_per_route
FROM packages_per_route
GROUP BY route_score
ORDER BY avg_packages_per_route DESC;


-- ============================================================
-- QUESTION 4: Do lower-quality routes cover more distinct zones?
-- ============================================================

WITH zones_per_route AS (
    SELECT
        r.route_id,
        r.route_score,
        COUNT(DISTINCT s.zone_id) AS number_of_zones
    FROM routes AS r
    JOIN stops AS s
        ON r.route_id = s.route_id
    GROUP BY r.route_id, r.route_score
)

SELECT
    route_score,
    COUNT(route_id) AS total_routes,
    SUM(number_of_zones) AS total_zones,
    ROUND(AVG(number_of_zones), 2) AS avg_zones_per_route
FROM zones_per_route
GROUP BY route_score
ORDER BY avg_zones_per_route DESC;


-- ============================================================
-- QUESTION 5: Do lower-quality routes have more planned
-- service time?
-- ============================================================

WITH service_time_per_route AS (
    SELECT
        r.route_id,
        r.route_score,
        SUM(p.planned_service_time_seconds) AS total_service_time_seconds
    FROM routes AS r
    JOIN packages AS p
        ON r.route_id = p.route_id
    GROUP BY r.route_id, r.route_score
)

SELECT
    route_score,
    COUNT(route_id) AS total_routes,
    ROUND(AVG(total_service_time_seconds), 2) AS avg_service_time_seconds,
    ROUND(AVG(total_service_time_seconds) / 3600, 2) AS avg_service_time_hours
FROM service_time_per_route
GROUP BY route_score
ORDER BY avg_service_time_seconds DESC;


-- ============================================================
-- QUESTION 6: Which route-quality groups have the highest
-- average package workload per stop?
-- ============================================================

WITH packages_per_stop AS (
    SELECT
        route_id,
        stop_id,
        COUNT(package_id) AS number_of_packages
    FROM packages
    GROUP BY route_id, stop_id
)

SELECT
    r.route_score,
    COUNT(DISTINCT r.route_id) AS total_routes,
    ROUND(AVG(p.number_of_packages), 2) AS avg_packages_per_stop
FROM packages_per_stop AS p
JOIN routes AS r
    ON p.route_id = r.route_id
GROUP BY r.route_score
ORDER BY avg_packages_per_stop DESC;


-- ============================================================
-- QUESTION 7: Do route-quality groups differ in average
-- package volume per route?
--
-- Package volume is estimated from depth × height × width.
-- NULLIF excludes zero-height records from the multiplication.
-- ============================================================

WITH package_volume_per_route AS (
    SELECT
        p.route_id,
        r.route_score,
        SUM(
            p.depth_cm * NULLIF(p.height_cm, 0) * p.width_cm
        ) AS total_package_volume_cm3
    FROM packages AS p
    JOIN routes AS r
        ON p.route_id = r.route_id
    GROUP BY p.route_id, r.route_score
)

SELECT
    route_score,
    COUNT(route_id) AS total_routes,
    ROUND(AVG(total_package_volume_cm3), 2) AS avg_package_volume_cm3
FROM package_volume_per_route
GROUP BY route_score
ORDER BY avg_package_volume_cm3 DESC;


-- ============================================================
-- QUESTION 8: Do lower-quality routes have higher estimated
-- vehicle capacity utilization?
--
-- Estimated utilization =
-- total package volume / executor vehicle capacity * 100.
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
        r.route_score,
        r.executor_capacity_cm3,
        rv.total_package_volume_cm3,
        rv.total_package_volume_cm3
            / r.executor_capacity_cm3 * 100.0 AS capacity_utilization_pct
    FROM routes AS r
    JOIN route_volume AS rv
        ON r.route_id = rv.route_id
    WHERE r.executor_capacity_cm3 > 0
)

SELECT
    route_score,
    COUNT(route_id) AS total_routes,
    ROUND(AVG(capacity_utilization_pct), 2) AS avg_capacity_utilization_pct
FROM route_utilization
GROUP BY route_score
ORDER BY avg_capacity_utilization_pct DESC;
