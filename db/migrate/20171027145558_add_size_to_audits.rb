class AddSizeToAudits < ActiveRecord::Migration[5.1]
  def change
    add_column :audits, :size, :string
  end
end
