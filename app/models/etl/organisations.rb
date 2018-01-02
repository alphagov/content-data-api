require 'gds_api/rummager'

class ETL::Organisations
  def self.process(*args)
    new(*args).process
  end

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
      names = %w(title slug description link organisation_state content_id)
      result = result.slice(*names)
      result['state'] = result.delete('organisation_state')

      Dimensions::Organisation.find_or_initialize_by(result)
    end
  end

  def load(transformed_orgs)
    validate!(transformed_orgs)

    new_records = transformed_orgs.select(&:new_record?)
    result = Dimensions::Organisation.import(new_records, validate: false)

    existing_records = transformed_orgs - new_records
    all_ids = result.ids + existing_records.pluck(:id)

    Dimensions::Organisation.where(id: all_ids)
  end

  def validate!(transformed_orgs)
    transformed_orgs.each(&:validate!)
  end

  def rummager
    @rummager ||= GdsApi::Rummager.new(Plek.new.find('rummager'))
  end
end
