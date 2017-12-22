require 'gds_api/rummager'

class ETL::Organisations
  def process
    raw_data = extract
    organisations = transform(raw_data)
    load(organisations)
  end

private

  def extract
    rummager.search_enum(
      {
        filter_format: 'organisation',
        fields: 'title,slug,description,link,organisation_state,content_id',
      },
      page_size: 1000,
      additional_headers: {},
    )
  end

  def transform(organisations)
    organisations.map do |result|
      attributes = %w(title slug description link organisation_state content_id)

      Dimensions::Organisation.new(result.slice(*attributes))
    end
  end

  def load(transformed_orgs)
    validate!(transformed_orgs)

    result = Dimensions::Organisation.import(transformed_orgs, validate: false)
    Dimensions::Organisation.where(id: result.ids)
  end

  def validate!(transformed_orgs)
    transformed_orgs.each(&:validate!)
  end

  def rummager
    @rummager ||= GdsApi::Rummager.new(Plek.new.find('rummager'))
  end
end
