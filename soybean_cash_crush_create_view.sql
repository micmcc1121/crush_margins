-- proc.soy_cash_crush_margins source

CREATE OR REPLACE VIEW proc.soy_cash_crush_margins
AS WITH soybean_costs AS (
         SELECT date_trunc('week'::text, mars_grain_bids.report_begin_date) AS week_of,
            round(avg(mars_grain_bids.avg_price)::numeric, 2) AS crush_costs,
            mars_grain_bids.trans_mode,
            mars_grain_bids.delivery_point,
            mars_grain_bids.market_location_state,
                CASE
                    WHEN mars_grain_bids.market_location_state = 'IA'::text THEN 'Iowa'::text
                    WHEN mars_grain_bids.market_location_state = 'IL'::text THEN 'Illinois'::text
                    WHEN mars_grain_bids.market_location_state = 'IN'::text THEN 'Indiana-Ohio'::text
                    WHEN mars_grain_bids.market_location_state = 'MN'::text THEN 'Minnesota'::text
                    ELSE NULL::text
                END AS "trade Loc",
            mars_grain_bids.trade_loc
           FROM mars_grain_bids
          WHERE mars_grain_bids.commodity = 'Soybeans'::text AND mars_grain_bids.current = 'Yes'::text AND (mars_grain_bids.market_location_state = ANY (ARRAY['IL'::text, 'IN'::text, 'OH'::text, 'MN'::text, 'IA'::text])) AND mars_grain_bids.delivery_point = 'Mills and Processors'::text
          GROUP BY (date_trunc('week'::text, mars_grain_bids.report_begin_date)), mars_grain_bids.trans_mode, mars_grain_bids.delivery_point, mars_grain_bids.trade_loc, mars_grain_bids.market_location_state
          ORDER BY (date_trunc('week'::text, mars_grain_bids.report_begin_date)) DESC, mars_grain_bids.trans_mode, mars_grain_bids.delivery_point, mars_grain_bids.trade_loc, mars_grain_bids.market_location_state
        ), soybean_revenues AS (
         SELECT m1.report_begin_date AS week_of,
            m1."trade Loc",
            m1.avg_price AS soy_oil_price,
            m2.avg_price AS soy_meal_price,
            m1.trans_mode AS soy_oil_transmode,
            m2.trans_mode AS soy_meal_transmode,
            round((m1.avg_price * 11.6::double precision / 100::double precision)::numeric, 2) AS soy_oil_revenues,
            round((m2.avg_price * 47.1::double precision / 2000::double precision)::numeric, 2) AS soy_meal_revenues,
            round((m1.avg_price * 11.6::double precision / 100::double precision + m2.avg_price * 47.1::double precision / 2000::double precision)::numeric, 2) AS crush_revenues
           FROM proc.mars_proc_prices m1
             JOIN proc.mars_proc_prices m2 ON m1.report_date = m2.report_date AND m1."trade Loc" = m2."trade Loc"
          WHERE m1.commodity = 'Soybean Oil'::text AND m2.commodity = 'Soybean Meal'::text
          ORDER BY m1."trade Loc", m1.report_begin_date DESC
        )
 SELECT r.week_of,
    r."trade Loc" AS trade_loc,
    c.trans_mode AS soy_transmode,
    r.soy_oil_transmode,
    r.soy_meal_transmode,
    c.crush_costs AS soy_costs,
    r.soy_oil_revenues,
    r.soy_meal_revenues,
    r.crush_revenues,
    c.crush_costs,
    r.crush_revenues - c.crush_costs AS crush_margin,
    round(r.soy_oil_revenues / r.crush_revenues * 100::numeric, 2) AS crush_oil_share,
    round(r.soy_meal_revenues / r.crush_revenues * 100::numeric, 2) AS crush_meal_share
   FROM soybean_revenues r
     LEFT JOIN soybean_costs c ON r.week_of = c.week_of AND r."trade Loc" = c."trade Loc";