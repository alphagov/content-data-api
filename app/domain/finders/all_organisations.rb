class Finders::AllOrganisations
  def self.run(locale: 'en')
    new.run(locale)
  end

  def run(locale)
    editions = Dimensions::Edition.latest
                 .select(:content_id, :title, :locale)
                 .where(document_type: 'organisation', locale: locale)
                 .order(:title)

    editions.map do |edition|
      Organisation.new(id: edition[:content_id], name: edition[:title])
    end
  end
end
