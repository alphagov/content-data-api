SELECT  warehouse_item_id,
  max(aggregations_monthly_metrics.dimensions_edition_id) AS dimensions_edition_id,
  sum(aggregations_monthly_metrics.upviews) AS upviews,
  sum(aggregations_monthly_metrics.useful_yes) AS useful_yes,
  sum(aggregations_monthly_metrics.useful_no) AS useful_no,
  sum(aggregations_monthly_metrics.searches) AS searches
FROM aggregations_monthly_metrics
INNER JOIN dimensions_months ON dimensions_months.id = aggregations_monthly_metrics.dimensions_month_id
INNER JOIN dimensions_editions ON dimensions_editions.id = aggregations_monthly_metrics.dimensions_edition_id
WHERE dimensions_months.id = to_char(NOW() - interval '1 month','YYYY-MM')
GROUP BY warehouse_item_id