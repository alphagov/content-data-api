class Organisation
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :id, :name

  def initialize(id:, name:)
    @id = id
    @name = name
  end
end
