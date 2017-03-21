json.groups @groups do |group|
  json.slug group.slug
  json.total group.content_item_ids.length
end
