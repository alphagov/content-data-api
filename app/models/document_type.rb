class DocumentType
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :id, :name

  def initialize(id:, name:)
    @id = id
    @name = name
  end

  def self.find_all
    editions = Dimensions::Edition.latest
      .relevant_content
      .select(:document_type)
      .distinct
      .order(:document_type)

    editions.map do |edition|
      self.new(id: edition[:document_type], name: edition[:document_type])
    end
  end
end
