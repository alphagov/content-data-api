class DeleteInvalidAllocations < ActiveRecord::Migration[5.1]
  def up
    Audits::Allocation.where(uid: 'anyone').delete_all
  end
end
