class Events::PublishingApi < ApplicationRecord
  self.table_name = "publishing_api_events"
  has_many :dimensions_editions, class_name: "Dimensions::Edition"
end
