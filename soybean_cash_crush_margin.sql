WITH soybean_costs AS (
    SELECT 
        date_trunc('week', report_begin_date) AS week_of, 
        ROUND(CAST(AVG(avg_price) AS numeric), 2) as crush_costs, 
        trans_mode, 
        delivery_point,
        market_location_state,
        CASE
            WHEN market_location_state IN ('IA') THEN 'Iowa'
            WHEN market_location_state IN ('IL') THEN 'Illinois'
            WHEN market_location_state IN ('IN') THEN 'Indiana-Ohio'
        END AS "trade Loc",
        trade_loc
    FROM mars_grain_bids
    WHERE commodity IN ('Soybeans')
        AND current IN ('Yes')
        AND market_location_state IN ('IL', 'IN', 'OH', 'MN', 'IA')
        AND delivery_point IN ('Mills and Processors')
    GROUP BY week_of, trans_mode, delivery_point, trade_loc, market_location_state
    ORDER BY week_of desc, trans_mode, delivery_point, trade_loc, market_location_state
),
soybean_revenues AS (
    SELECT 
    m1.report_begin_date AS week_of, 
    m1."trade Loc",
    m1.avg_price AS soy_oil_price,
    m2.avg_price AS soy_meal_price, 
    m1.trans_mode AS soy_oil_transmode,
    m2.trans_mode as soy_meal_transmode, 
    ROUND(CAST((m1.avg_price * 11.6/100) + (m2.avg_price * 47.1/2000) AS numeric), 2) AS crush_revenues
FROM mars_proc_prices AS m1
INNER JOIN mars_proc_prices AS m2
ON m1.report_date = m2.report_date
    AND m1."trade Loc" = m2."trade Loc"
WHERE m1.commodity IN ('Soybean Oil')
    AND m2.commodity IN ('Soybean Meal')
ORDER BY m1."trade Loc", week_of desc
)
SELECT r.week_of, r."trade Loc", c."trade Loc", c.trans_mode AS soy_trans_mode, r.soy_oil_transmode, r.soy_meal_transmode, r.crush_revenues, c.crush_costs, r.crush_revenues - c.crush_costs AS crush_margin
FROM soybean_revenues as r
LEFT JOIN soybean_costs as c
ON r.week_of = c.week_of AND r."trade Loc" = c."trade Loc"
;