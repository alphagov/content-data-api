class RemoveOrganisationReferenceFromContentItems < ActiveRecord::Migration[5.0]
  def change
    remove_reference :content_items, :organisation, foreign_key: true
  end
end
