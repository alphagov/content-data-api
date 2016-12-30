module Importers
  class AllOrganisations
    def run
      OrganisationsService.new.find_each do |attributes|
        create_or_update!(attributes)
      end
    end

  private

    def create_or_update!(attributes)
      organisation_slug = attributes.fetch(:slug)
      organisation = ::Organisation.find_or_create_by(slug: organisation_slug)
      organisation.update!(attributes)
    end
  end
end
