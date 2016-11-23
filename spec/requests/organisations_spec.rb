require 'rails_helper'

RSpec.describe "Organisations", type: :request do
  describe "GET /organisations" do

    it "returns 200 when listing the organisations" do
      get organisations_path
      expect(response).to have_http_status(200)
    end

    it 'returns a JSON with the ids of the organisation and the number of content_items' do
      content_item1 = ContentItem.new
      content_item2 = ContentItem.new
      Organisation.create!(slug: 'a_slug', content_items: [content_item1, content_item2])

      get organisations_path
      expect(response.body).to eq([{slug: 'a_slug', total_content_items: 2}].to_json)
    end
  end
end
