namespace :heroku do
  task :deploy, %i[identifier organisation_name number_of_content_items link_types] => :environment do |_task, options|
    raise 'Invalid parameters' unless options.identifier
    options.with_defaults(
      link_types: %w(organisations primary_publishing_organisation topics parent),
      number_of_content_items: 1000,
      organisation_name: 'HM Revenue & Customs',
    )

    ## Find the organisation
    organisation = item.find_by!(title: options.organisation_name, document_type: "organisation")

    ## Application name
    app_name = "cpm-prototype-#{options.identifier}"

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
    content_item_ids = query.new.
      primary_organisation(organisation.content_id).
      content_items.
      limit(options.number_of_content_items).
      pluck(:content_id)
    content_item_ids.push(organisation.content_id)

    # Add topics
    content_item_ids.concat(Item.where(document_type: 'topic').pluck(:content_id))

    ## Export Content Items and Links
    system %{psql content_performance_manager_development -c "COPY (#{content_items_query(content_item_ids)}) TO STDOUT" > '#{content_items_file}'}
    system %{psql content_performance_manager_development -c "COPY (#{links_query(content_item_ids, options)}) TO STDOUT" > '#{links_file}'}

    ## Clean-up data if this is a redeployment
    system %{heroku pg:psql -c "DELETE FROM ALLOCATIONS" --app #{app_name}}
    system %{heroku pg:psql -c "DELETE FROM LINKS" --app #{app_name}}
    system %{heroku pg:psql -c "DELETE FROM CONTENT_ITEMS" --app #{app_name}}
    system %{heroku pg:psql -c "DELETE FROM USERS" --app #{app_name}}

    ## Import Content Items and Links
    system %{heroku pg:psql -c "\\COPY CONTENT_ITEMS FROM '#{content_items_file}'" --app #{app_name}}
    system %{heroku pg:psql -c "\\COPY lINKS FROM '#{links_file}'" --app #{app_name}}

    ## Creates default user
    system %{heroku run rails runner "Heroku.create_users '#{organisation.id}'" --app #{app_name}}

    ## Opens the application in the browser
    system %{heroku open --app #{app_name}}
  end

  def content_items_file
    '/var/govuk/content-performance-manager/tmp/content_items.sql'
  end

  def links_file
    '/var/govuk/content-performance-manager/tmp/links.sql'
  end

  def content_items_query(content_item_ids)
    Item.where(content_id: content_item_ids).to_sql
  end

  def links_query(content_item_ids, options)
    Link.where(source_content_id: content_item_ids, link_type: options.link_types).to_sql
  end
end
