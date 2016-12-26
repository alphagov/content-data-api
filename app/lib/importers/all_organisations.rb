module Importers
  class AllOrganisations
    def run
      OrganisationsService.new.find_each do |attributes|
        organisation = ::Organisation.find_or_create_by(slug: attributes.fetch(:slug))
        organisation.assign_attributes(attributes)
        organisation.save!
      end
    end
  end
end
