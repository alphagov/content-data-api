class FindOrganisationUsers
  def self.call(*args)
    new(*args).call
  end

  attr_reader :organisation_slug

  def initialize(organisation_slug:)
    @organisation_slug = organisation_slug
  end

  def call
    User
      .where(organisation_slug: organisation_slug)
      .distinct
  end
end
