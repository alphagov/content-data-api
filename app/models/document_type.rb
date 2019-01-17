class DocumentType
  include ActiveModel::Model
  include ActiveModel::Serialization

  IGNORED_TYPES = %w[redirect gone vanish unpublishing need].freeze

  attr_accessor :id, :name

  def initialize(id:, name:)
    @id = id
    @name = name
  end
end
