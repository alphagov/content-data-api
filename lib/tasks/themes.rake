namespace :themes do
  desc "Backup themes, subthemes and inventory rules to a file"
  task backup: :environment do
    db = Rails.configuration.database_configuration.dig(Rails.env, "database")
    cmd = "pg_dump --data-only -t themes -t subthemes -t inventory_rules #{db} > themes.sql"
    puts cmd
    system(cmd)
  end

  desc "Restore themes, subthemes and inventory rules from a file"
  task restore: :environment do
    db = Rails.configuration.database_configuration.dig(Rails.env, "database")
    cmd = "psql #{db} < themes.sql"
    puts cmd
    system(cmd)
  end
end
