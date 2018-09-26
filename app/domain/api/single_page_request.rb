class Api::SinglePageRequest < Api::BaseRequest
  attr_reader :metrics, :base_path

  validates :base_path, presence: true

  def initialize(params)
    super(params)
    @base_path = params[:base_path]
  end
end
