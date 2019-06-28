json.parent_base_path @parent.base_path
json.documents @documents do |document|
  json.base_path document.base_path
  json.title document.title
  json.primary_organisation_id document.primary_organisation_id
  json.document_type document.document_type
  json.sibling_order document.sibling_order
  json.upviews document.upviews
  json.pviews document.pviews
  json.feedex document.feedex
  json.useful_yes document.useful_yes
  json.useful_no document.useful_no
  json.satisfaction document.satisfaction
  json.searches document.searches
end
