
class DeleteInvalidAllocations < ActiveRecord::Migration[5.1]
  module Audits
    class Allocation < ApplicationRecord
    end
  end

  def up
    Audits::Allocation.where(uid: 'anyone').delete_all
  end
end
