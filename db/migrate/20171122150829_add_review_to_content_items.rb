class AddReviewToContentItems < ActiveRecord::Migration[5.1]
  def change
    add_column :content_items, :review_by, :date
  end
end
