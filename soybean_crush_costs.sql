SELECT 
    date_trunc('week', report_begin_date) AS week_of, 
    ROUND(CAST(AVG(avg_price) AS numeric), 2), 
    trans_mode, 
    delivery_point,
    market_location_state AS "trade Loc",
    trade_loc
FROM mars_grain_bids
WHERE commodity IN ('Soybeans')
    AND current IN ('Yes')
    AND market_location_state IN ('IL', 'IN', 'OH', 'MN', 'IA')
    AND delivery_point IN ('Mills and Processors')
GROUP BY week_of, trans_mode, delivery_point, trade_loc, market_location_state
ORDER BY week_of desc, trans_mode, delivery_point, trade_loc, market_location_state
;