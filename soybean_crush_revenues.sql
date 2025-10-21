SELECT 
        m1.report_begin_date AS week_of, 
        m1."trade Loc",
        m1.avg_price AS soy_oil_price,
        m2.avg_price AS soy_meal_price, 
        m1.trans_mode AS soy_oil_transmode,
        m2.trans_mode as soy_meal_transmode, 
        ROUND(CAST((m1.avg_price * 11.6/100) + (m2.avg_price * 47.1/2000) AS numeric), 2) AS crush_revenues
    FROM proc.mars_proc_prices AS m1
    INNER JOIN proc.mars_proc_prices AS m2
    ON m1.report_date = m2.report_date
        AND m1."trade Loc" = m2."trade Loc"
    WHERE m1.commodity IN ('Soybean Oil')
        AND m2.commodity IN ('Soybean Meal')
        -- Testing
        AND m1."trade Loc" in ('Illinois')
    ORDER BY week_of DESC, m1."trade Loc"