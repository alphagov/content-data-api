namespace :themes do
  desc "Backup themes, subthemes and inventory rules to a file"
  task backup: :environment do
    run("pg_dump --data-only -t themes -t subthemes -t inventory_rules #{db} > themes.sql")
  end

  desc "Restore themes, subthemes and inventory rules from a file"
  task restore: :environment do
    run("psql #{db} < themes.sql")
  end
end

def db
  ENV["DATABASE_URL"] || Rails.configuration.database_configuration.dig(Rails.env, "database")
end

def run(cmd)
  puts cmd
  system(cmd)
end
