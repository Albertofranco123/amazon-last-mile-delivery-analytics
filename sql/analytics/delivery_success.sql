-- Amazon Last-Mile Delivery Analytics
-- Delivery Success Analysis
-- Engine: Amazon Athena
-- Tables: packages, routes, stops

-- ============================================================
-- QUESTION 1: Which route-quality groups have the highest
-- non-delivery rates?
--
-- Non-delivered = DELIVERY_ATTEMPTED or REJECTED.
-- This compares unsuccessful-delivery rates across High,
-- Medium, and Low route-score groups.
-- ============================================================

SELECT
    r.route_score,
    COUNT(p.package_id) AS total_packages,
    SUM(
        CASE
            WHEN p.scan_status IN ('DELIVERY_ATTEMPTED', 'REJECTED')
            THEN 1
            ELSE 0
        END
    ) AS non_delivered_packages,
    ROUND(
        SUM(
            CASE
                WHEN p.scan_status IN ('DELIVERY_ATTEMPTED', 'REJECTED')
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(p.package_id),
        2
    ) AS non_delivery_rate_pct
FROM packages AS p
JOIN routes AS r
    ON p.route_id = r.route_id
GROUP BY r.route_score
ORDER BY non_delivery_rate_pct DESC;


-- ============================================================
-- QUESTION 2: Does route zone complexity relate to
-- non-delivery rates?
--
-- Each route is assigned to a bucket based on its number of
-- distinct zones. Package outcomes are then aggregated within
-- those route-complexity buckets.
-- ============================================================

WITH route_zones AS (
    SELECT
        route_id,
        COUNT(DISTINCT zone_id) AS number_of_zones
    FROM stops
    GROUP BY route_id
),

packages_with_zone_bucket AS (
    SELECT
        p.package_id,
        p.scan_status,
        CASE
            WHEN rz.number_of_zones < 10 THEN '<10 zones'
            WHEN rz.number_of_zones BETWEEN 10 AND 19 THEN '10-19 zones'
            WHEN rz.number_of_zones BETWEEN 20 AND 29 THEN '20-29 zones'
            WHEN rz.number_of_zones BETWEEN 30 AND 39 THEN '30-39 zones'
            ELSE '40+ zones'
        END AS zone_bucket,
        CASE
            WHEN rz.number_of_zones < 10 THEN 1
            WHEN rz.number_of_zones BETWEEN 10 AND 19 THEN 2
            WHEN rz.number_of_zones BETWEEN 20 AND 29 THEN 3
            WHEN rz.number_of_zones BETWEEN 30 AND 39 THEN 4
            ELSE 5
        END AS zone_bucket_order
    FROM packages AS p
    JOIN route_zones AS rz
        ON p.route_id = rz.route_id
)

SELECT
    zone_bucket,
    COUNT(package_id) AS total_packages,
    SUM(
        CASE
            WHEN scan_status IN ('DELIVERY_ATTEMPTED', 'REJECTED')
            THEN 1
            ELSE 0
        END
    ) AS non_delivered_packages,
    ROUND(
        SUM(
            CASE
                WHEN scan_status IN ('DELIVERY_ATTEMPTED', 'REJECTED')
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(package_id),
        2
    ) AS non_delivery_rate_pct
FROM packages_with_zone_bucket
GROUP BY zone_bucket, zone_bucket_order
ORDER BY zone_bucket_order;
