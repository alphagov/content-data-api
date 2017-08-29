namespace :frog do
  desc "Add format and pageview data to CSV output from screaming frog (SERP reports)"
  task :enhance, [:csv_path, :output_csv_path] => :environment do |_, args|
    ScreamingFrog.enhance(args[:csv_path], args[:output_csv_path])
  end
end
