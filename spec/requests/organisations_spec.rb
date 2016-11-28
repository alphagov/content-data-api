require 'rails_helper'

RSpec.describe 'Organisations', type: :request do
  describe 'GET /organisations' do
    it 'returns 200 when listing the organisations' do
      get organisations_path
      expect(response).to have_http_status(200)
    end

    it 'returns a JSON with the ids of the organisation and the number of content_items' do
      FactoryGirl.create(:organisation_with_content_items, slug: 'a_slug', content_items_count: 2)

      get organisations_path
      expect(response.body).to eq([{ slug: 'a_slug', total_content_items: 2 }].to_json)
    end
  end
end
