class Link < ApplicationRecord
  belongs_to :source,
    class_name: :ContentItem,
    foreign_key: :source_content_id,
    primary_key: :content_id,
    optional: true

  belongs_to :target,
    class_name: :ContentItem,
    foreign_key: :target_content_id,
    primary_key: :content_id,
    optional: true
end
