class Finders::AllOrganisations
  def self.run(locale: "en")
    new.run(locale)
  end

  def run(locale)
    editions = find_all(locale)
    editions.map { |edition| new_organisation(edition) }
  end

private

  def new_organisation(org)
    Organisation.new(
      id: org[:content_id],
      name: org[:title],
      acronym: org[:acronym],
    )
  end

  def find_all(locale)
    Dimensions::Edition.live
      .select(:content_id, :title, :locale, :acronym)
      .where(document_type: "organisation", locale:)
      .order(:title)
  end
end
