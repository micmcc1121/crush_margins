"""
Script to pull together cash market soybean crush costs and revenues
to create a cash crush margin SQL table

created by: Michael McConnell
created on: August 6, 2025

To do:
    1)
"""

# Libraries
import os
import pandas as pd
from sqlalchemy import create_engine

# Create Postgres connection

# SELECT crush costs data

costs_stmt = '''
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
'''

# SELECT crush revenues

rev_stmt = '''
SELECT 
    m1.report_begin_date, 
    m1."trade Loc",
    m1.avg_price AS soy_oil_price,
    m2.avg_price AS soy_meal_price, 
    m1.trans_mode AS soy_oil_transmode,
    m2.trans_mode as soy_meal_trans_mode, 
    ROUND(CAST((m1.avg_price * 11.6/100) + (m2.avg_price * 47.1/2000) AS numeric), 2) AS crush_revenues
FROM mars_proc_prices AS m1
INNER JOIN mars_proc_prices AS m2
ON m1.report_date = m2.report_date
    AND m1."trade Loc" = m2."trade Loc"
WHERE m1.commodity IN ('Soybean Oil')
    AND m2.commodity IN ('Soybean Meal')
ORDER BY m1."trade Loc", report_begin_date desc
;
'''

# Create mapping to JOIN two datasets

# Output data