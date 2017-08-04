class AddQualitativeMeasuresToAudits < ActiveRecord::Migration[5.1]
  def change
    add_column :audits, :change_title, :boolean
    add_column :audits, :change_description, :boolean
    add_column :audits, :change_body, :boolean
    add_column :audits, :change_attachments, :boolean
    add_column :audits, :outdated, :boolean
    add_column :audits, :redundant, :boolean
    add_column :audits, :reformat, :boolean
    add_column :audits, :similar, :boolean
    add_column :audits, :similar_urls, :text
    add_column :audits, :notes, :text
  end
end
