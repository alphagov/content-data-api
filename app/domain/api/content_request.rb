class Api::ContentRequest < Api::BaseRequest
  attr_reader :organisation_id
  validate :valid_organisation_id

  def initialize(params)
    super(params)
    @organisation_id = params[:organisation_id]
  end

private

  def valid_organisation_id
    return true if UUID.validate organisation_id
    errors.add('organisation_id', 'this is not a valid organisation id')
  end
end
