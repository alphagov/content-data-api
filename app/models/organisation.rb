class Organisation
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :id, :name, :acronym

  def initialize(id:, name:, acronym:)
    @id = id
    @name = name
    @acronym = acronym
  end
end
