class Organisation
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :id, :name, :acronym
end
