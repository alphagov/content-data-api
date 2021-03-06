json.results @content_items do |content_item|
  json.base_path content_item[:base_path]
  json.title content_item[:title]
  # TODO: Remove this once the Content Data Admin is using the
  # primary_organisation_id value
  json.organisation_id content_item[:primary_organisation_id]
  json.primary_organisation_id content_item[:primary_organisation_id]
  json.document_type content_item[:document_type]
  json.pviews content_item[:pviews]
  json.upviews content_item[:upviews]
  json.feedex content_item[:feedex]
  json.useful_yes content_item[:useful_yes]
  json.useful_no content_item[:useful_no]
  json.satisfaction content_item[:satisfaction]
  json.searches content_item[:searches]
  json.pdf_count content_item[:pdf_count]
  json.word_count content_item[:words]
  json.reading_time content_item[:reading_time]
end

json.page @page
json.total_pages @total_pages
json.total_results @total_results
