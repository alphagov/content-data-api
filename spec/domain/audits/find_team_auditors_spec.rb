module Audits
  RSpec.describe FindTeamAuditors do
    subject { described_class }

    let!(:user) { create :user, :with_allocated_content, organisation_slug: "organisation_slug" }

    it "returns only auditors belonging to my organisation" do
      create :user, organisation_slug: :other_org_slug

      expect(subject.call(organisation_slug: user.organisation_slug)).to match_array(user)
    end
  end
end
