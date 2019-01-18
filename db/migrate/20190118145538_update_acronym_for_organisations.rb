class UpdateAcronymForOrganisations < ActiveRecord::Migration[5.2]
  def up
    Dimensions::Edition.where(document_type: 'organisation').find_each do |edition|
      event = edition.publishing_api_event
      acronym = event.payload.dig('details', 'acronym')

      edition.update(acronym: acronym.blank? ? nil : acronym)
    end
  end
end
