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
            WHEN market_location_state IN ('MN') THEN 'Minnesota'
        END AS "trade Loc",
        trade_loc
    FROM mars_grain_bids
    WHERE commodity IN ('Soybeans')
        AND current IN ('Yes')
        AND market_location_state IN ('IL', 'IN', 'OH', 'MN', 'IA')
        AND delivery_point IN ('Mills and Processors')
    GROUP BY week_of, trans_mode, delivery_point, trade_loc, market_location_state
    ORDER BY week_of desc, trans_mode, delivery_point, trade_loc, market_location_state