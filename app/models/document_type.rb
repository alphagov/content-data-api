class DocumentType
  include ActiveModel::Model
  include ActiveModel::Serialization

  IGNORED_TYPES = %w[
    gone
    need
    redirect
    substitute
    unpublishing
    vanish
  ].freeze

  attr_accessor :id, :name
end
