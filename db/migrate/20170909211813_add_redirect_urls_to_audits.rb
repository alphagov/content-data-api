class AddRedirectUrlsToAudits < ActiveRecord::Migration[5.1]
  def change
    add_column :audits, :redirect_urls, :text
  end
end
