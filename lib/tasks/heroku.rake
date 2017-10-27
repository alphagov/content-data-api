namespace :heroku do
  task :deploy, %i[pr_number organisation_name number_of_content_items link_types] => :environment do |_task, options|
    raise 'Invalid parameters' unless options.pr_number && options.organisation_name
    options.with_defaults(
      link_types: %w(organisations primary_publishing_organisation),
      number_of_content_items: 1000,
      organisation_name: 'HM Revenue & Customs',
    )

    ## Find the organisation
    (organisation = Content::Item.find_by(title: options.organisation_name)) || raise("Error -> Organisation not found: #{options.organisation_name}")

    ## Application name
    app_name = "cpm-prototype-#{options.pr_number}"

    ## Create the Heroku app
    heroku_remote = "heroku-#{app_name}"
    system %{heroku apps:create --region eu --remote #{heroku_remote} --app #{app_name}}
    system %{heroku config:set RUNNING_IN_HEROKU=true RAILS_ENV=development RACK_ENV=development --app #{app_name}}

    ## Push code to Heroku
    current_branch = `git branch | grep "^\*" | cut -d" " -f2`.strip
    system %{git push #{heroku_remote} #{current_branch}:master --force}

    ## Prepare database
    system %{heroku run rake db:migrate --app #{app_name}}

    ## Find the content items for the organisation
    content_item_ids = Content::Query.new.
      primary_organisation(organisation.content_id).
      content_items.
      limit(options.number_of_content_items).
      pluck(:content_id)
    content_item_ids.push(organisation.content_id)

    # Export Content Items and Links
    system %{psql content_performance_manager_development -c "COPY (#{content_items_query(content_item_ids)}) TO STDOUT" > '#{content_items_file}'}
    system %{psql content_performance_manager_development -c "COPY (#{links_query(content_item_ids, options)}) TO STDOUT" > '#{links_file}'}

    # Clean-up data if this is a redeployment
    system %{heroku pg:psql -c "DELETE FROM ALLOCATIONS" --app #{app_name}}
    system %{heroku pg:psql -c "DELETE FROM LINKS" --app #{app_name}}
    system %{heroku pg:psql -c "DELETE FROM CONTENT_ITEMS" --app #{app_name}}
    system %{heroku pg:psql -c "DELETE FROM USERS" --app #{app_name}}

    #Import Contetn Items and Links
    system %{heroku pg:psql -c "\\COPY CONTENT_ITEMS FROM '#{content_items_file}'" --app #{app_name}}
    system %{heroku pg:psql -c "\\COPY lINKS FROM '#{links_file}'" --app #{app_name}}

    # Creates default user
    system %{heroku run rails runner "Heroku.create_users '#{organisation.id}'" --app #{app_name}}

    # Opens the application in the browser
    system %{heroku open --app #{app_name}}
  end

  def content_items_file
    '/var/govuk/content-performance-manager/tmp/content_items.sql'
  end

  def links_file
    '/var/govuk/content-performance-manager/tmp/links.sql'
  end

  def content_items_query(content_item_ids)
    Content::Item.where(content_id: content_item_ids).to_sql
  end

  def links_query(content_item_ids, options)
    Content::Link.where(source_content_id: content_item_ids, link_type: options.link_types).to_sql
  end
end
