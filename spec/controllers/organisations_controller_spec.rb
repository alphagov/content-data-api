require 'rails_helper'

RSpec.describe OrganisationsController, type: :controller do
  describe "#show" do
    before :each do
      @organisation = create(
        :organisation, id: 1,
        number_of_pages: 3,
        content_id: "fdur5845-fu54-fd86-gy75-5fjdkjfjkfe3-1"
      )
    end

    it "retrieves an organisation details" do
      get :show, id: 1

      expect(response).to be_success
      expect(json['number_of_pages']).to eq(3)
      expect(json['content_id']).to eq("fdur5845-fu54-fd86-gy75-5fjdkjfjkfe3-1")
    end
  end
end
