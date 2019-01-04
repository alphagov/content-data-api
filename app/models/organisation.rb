class Organisation
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :id, :name

  def initialize(id:, name:)
    @id = id
    @name = name
  end

  def self.find_all(locale: 'en')
    editions = Dimensions::Edition.latest
      .select(:content_id, :title, :locale)
      .where(document_type: 'organisation', locale: locale)
      .order(:title)

    editions.map do |edition|
      self.new(id: edition[:content_id], name: edition[:title])
    end
  end
end
