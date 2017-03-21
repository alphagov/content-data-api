class Group < ApplicationRecord
  validates :slug, uniqueness: true
  validates :slug, :name, :group_type, presence: true

  belongs_to :parent, class_name: 'Group', foreign_key: :parent_group_id, optional: true
  has_many :children, class_name: 'Group', foreign_key: :parent_group_id
end
