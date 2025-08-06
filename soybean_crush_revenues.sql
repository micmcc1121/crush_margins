SELECT 
    m1.report_begin_date, 
    m1."trade Loc",
    m1.avg_price AS oil_price,
    m2.avg_price AS meal_price, 
    m1.trans_mode AS oil_transmode,
    m2.trans_mode as meal_trans_mode, 
    ROUND(CAST((m1.avg_price * 11.6/100) + (m2.avg_price * 47.1/2000) AS numeric), 2) AS crush_revenues
FROM mars_proc_prices AS m1
INNER JOIN mars_proc_prices AS m2
ON m1.report_date = m2.report_date
    AND m1."trade Loc" = m2."trade Loc"
WHERE m1.commodity IN ('Soybean Oil')
    AND m2.commodity IN ('Soybean Meal')
ORDER BY m1."trade Loc", report_begin_date desc
LIMIT 1000;