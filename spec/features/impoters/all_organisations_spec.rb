require 'rails_helper'

RSpec.feature "Import all organisations", type: :feature do
  let(:two_organisations) {
    double(body: {
      results: [
        {
          slug: 'slug-1',
          title: 'title-1',
        },
        {
          slug: 'slug-2',
          title: 'title-2',
        }
      ]
    }.to_json)
  }

  before do
    Rake::Task['import:all_organisations'].reenable

    allow(HTTParty).to receive(:get).and_return(two_organisations)
  end

  it 'creates two organisations' do
    expect { Rake::Task['import:all_organisations'].invoke('a_slug') }.to change { Organisation.count }.by(2)
  end

  it 'import the organisation attributes' do
    Rake::Task['import:all_organisations'].invoke('a_slug')

    organisation = Organisation.first
    expect(organisation.title).to eq('title-1')
    expect(organisation.slug).to eq('slug-1')
  end
end
