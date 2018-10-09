class Reports::Organisation
  def self.retrieve
    new.retrieve
  end

  def retrieve
    Dimensions::Edition.latest
      .select(:organisation_id, :primary_organisation_title)
      .distinct
      .order(:primary_organisation_title).to_a
  end
end
