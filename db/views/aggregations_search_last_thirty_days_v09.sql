SELECT
  dimensions_editions.warehouse_item_id as warehouse_item_id,
  dimensions_editions.title as title,
  dimensions_editions.document_type as document_type,
  dimensions_editions.base_path as base_path,
  dimensions_editions.primary_organisation_id as primary_organisation_id,
  dimensions_editions.id as dimensions_edition_id,
  aggregations.upviews::bigint as upviews,
  aggregations.pviews::bigint as pviews,
  aggregations.feedex::bigint as feedex,
  aggregations.useful_yes::bigint as useful_yes,
  aggregations.useful_no::bigint as useful_no,
  CURRENT_DATE as updated_at,
  CASE
    WHEN useful_yes + useful_no = 0 THEN NULL
    ELSE useful_yes::float / (useful_yes + useful_no)
  END as satisfaction,
  aggregations.searches::bigint as searches,
  facts_editions.words as words,
  facts_editions.pdf_count as pdf_count,
  facts_editions.reading_time as reading_time
FROM
  (
    SELECT warehouse_item_id,
      max(facts_metrics.dimensions_edition_id) AS dimensions_edition_id,
      sum(facts_metrics.upviews) AS upviews,
      sum(facts_metrics.pviews) AS pviews,
      sum(facts_metrics.useful_yes) AS useful_yes,
      sum(facts_metrics.useful_no) AS useful_no,
      sum(facts_metrics.feedex) AS feedex,
      sum(facts_metrics.searches) AS searches
     FROM facts_metrics
       JOIN dimensions_dates ON dimensions_dates.date = facts_metrics.dimensions_date_id
       JOIN dimensions_editions ON dimensions_editions.id = facts_metrics.dimensions_edition_id
     WHERE (facts_metrics.dimensions_date_id > (('yesterday'::text)::date - '30 days'::interval day))
       AND (facts_metrics.dimensions_date_id < ('now'::text)::date)
    GROUP BY warehouse_item_id
  ) as aggregations
INNER JOIN dimensions_editions ON aggregations.dimensions_edition_id = dimensions_editions.id
INNER JOIN facts_editions ON dimensions_editions.id = facts_editions.dimensions_edition_id
WHERE dimensions_editions.document_type NOT IN ('gone','vanish','need','unpublishing','redirect')
