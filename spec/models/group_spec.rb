require "rails_helper"

RSpec.describe Group, type: :model do
  it { should validate_uniqueness_of(:slug) }
  it { should validate_presence_of(:slug) }
  it { should validate_presence_of(:group_type) }
  it { should validate_presence_of(:name) }

  it { should have_many(:children).class_name('Group').with_foreign_key(:parent_group_id) }
  it { should belong_to(:parent).class_name('Group') }
end
