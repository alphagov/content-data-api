RSpec.describe Api::DocumentChildrenRequest do
  let(:params) { { time_period: "past-30-days" } }

  describe "#to_filter" do
    it "returns a hash with the parameters" do
      request = described_class.new(time_period: "past-30-days", sort: "feedex:asc")

      expect(request.to_filter).to eq(
        time_period: "past-30-days",
        sort_key: "feedex",
        sort_direction: "asc",
      )
    end

    it "includes missing parameters" do
      request = described_class.new({})

      expect(request.to_filter).to eq(
        time_period: nil,
        sort_key: nil,
        sort_direction: nil,
      )
    end

    allowed_sort_keys = %w[
      title document_type sibling_order upviews pviews useful_yes useful_no searches feedex
    ]

    allowed_sort_keys.each do |key|
      it "allows #{key} as sort key" do
        request = described_class.new(params.merge(sort: key))

        expect(request.to_filter).to include(sort_key: key, sort_direction: nil)
      end
    end

    it "allows a valid sort key with asc direction" do
      request = described_class.new(params.merge(sort: "feedex:asc"))

      expect(request.to_filter).to include(sort_key: "feedex", sort_direction: "asc")
    end

    it "allows a valid sort key with desc direction" do
      request = described_class.new(params.merge(sort: "feedex:desc"))

      expect(request.to_filter).to include(sort_key: "feedex", sort_direction: "desc")
    end

    describe "#sort_key" do
      it "validates value" do
        request = described_class.new(params.merge(sort: "invalid"))
        request.valid?
        expect(request.errors[:sort]).to include("this is not a valid sort key")
      end

      it "validates presence" do
        request = described_class.new(params.merge(sort: ":desc"))
        request.valid?
        expect(request.errors[:sort]).to include("this is not a valid sort key")
      end
    end

    describe "#sort_direction" do
      it "validates value" do
        request = described_class.new(params.merge(sort: "feedex:invalid"))
        request.valid?
        expect(request.errors[:sort]).to include("this is not a valid sort direction")
      end

      it "validates presence" do
        request = described_class.new(params.merge(sort: "feedex:"))
        request.valid?
        expect(request.errors[:sort]).to include("this is not a valid sort direction")
      end
    end
  end
end
