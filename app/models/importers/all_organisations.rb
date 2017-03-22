module Importers
  class AllOrganisations
    def run
      OrganisationsService.new.find_each do |attributes|
        create_or_update!(attributes)
      end
    end

  private

    def create_or_update!(attributes)
      organisation_id = attributes.fetch(:content_id)
      organisation = Organisation.find_or_create_by(content_id: organisation_id)
      organisation.update!(attributes)
    end
  end
end
