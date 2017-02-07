class MigrateManyToManyContentItemsOrganisation < ActiveRecord::Migration[5.0]
  class ContentItem < ActiveRecord::Base
    belongs_to :organisation
    has_and_belongs_to_many :organisations
  end

  def change
    MigrateManyToManyContentItemsOrganisation::ContentItem.find_each do |content_item|
      content_item.organisations << content_item.organisation
    end
  end
end
