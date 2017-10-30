class AddPassToAudits < ActiveRecord::Migration[5.1]
  def change
    add_column :audits, :pass, :boolean
  end
end
