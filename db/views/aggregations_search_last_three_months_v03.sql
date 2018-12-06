SELECT  warehouse_item_id,
  max(agg.dimensions_edition_id) AS dimensions_edition_id,
  sum(agg.upviews) AS upviews,
  sum(agg.useful_yes) AS useful_yes,
  sum(agg.useful_no) AS useful_no,
  sum(agg.searches) AS searches
FROM(
    -- Use monthly aggregations
    SELECT  warehouse_item_id,
      max(aggregations_monthly_metrics.dimensions_edition_id) AS dimensions_edition_id,
      sum(aggregations_monthly_metrics.upviews) AS upviews,
      sum(aggregations_monthly_metrics.useful_yes) AS useful_yes,
      sum(aggregations_monthly_metrics.useful_no) AS useful_no,
      sum(aggregations_monthly_metrics.searches) AS searches
    FROM aggregations_monthly_metrics
    INNER JOIN dimensions_months ON dimensions_months.id = aggregations_monthly_metrics.dimensions_month_id
    INNER JOIN dimensions_editions ON dimensions_editions.id = aggregations_monthly_metrics.dimensions_edition_id
    WHERE dimensions_months.id >= to_char(('yesterday'::text)::date - interval '2 month','YYYY-MM')
    GROUP BY warehouse_item_id
  UNION
    -- Use daily metrics
    SELECT warehouse_item_id,
      max(facts_metrics.dimensions_edition_id) AS dimensions_edition_id,
      sum(facts_metrics.upviews) AS upviews,
      sum(facts_metrics.useful_yes) AS useful_yes,
      sum(facts_metrics.useful_no) AS useful_no,
      sum(facts_metrics.searches) AS searches
     FROM facts_metrics
       JOIN dimensions_dates ON dimensions_dates.date = facts_metrics.dimensions_date_id
       JOIN dimensions_editions ON dimensions_editions.id = facts_metrics.dimensions_edition_id
    WHERE facts_metrics.dimensions_date_id > (('yesterday'::text)::date - interval '3 month')
         AND facts_metrics.dimensions_date_id < to_char(('yesterday'::text)::date - interval '2 month','YYYY-MM-01')::date
    GROUP BY warehouse_item_id
) as agg
GROUP BY warehouse_item_id
