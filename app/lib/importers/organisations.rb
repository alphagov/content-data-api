module Importers
  class Organisations
    def import_all
      Collectors::Organisations.new.find_each do |attributes|
        organisation = ::Organisation.find_or_create_by(slug: attributes.fetch(:slug))
        organisation.assign_attributes(attributes)
        organisation.save!
      end
    end
  end
end
