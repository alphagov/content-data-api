class Api::SinglePageRequest < Api::BaseRequest
  attr_reader :metrics, :base_path

  def initialize(params)
    super(params)
    @base_path = params[:base_path]
  end
end
