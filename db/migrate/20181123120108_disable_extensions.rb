class DisableExtensions < ActiveRecord::Migration[5.2]
  def change
    disable_extension "fuzzystrmatch"
    disable_extension "pg_trgm"
  end
end
