class Queries::FindAllOrganisations
  def self.retrieve
    new.retrieve
  end

  def retrieve
    Dimensions::Edition.latest
      .where(document_type: 'organisation')
      .order(:title)
      .pluck(:content_id, :title)
      .map(&method(:convert_result))
  end

private

  def convert_result(arry)
    { organisation_id: arry[0], title: arry[1] }
  end
end
