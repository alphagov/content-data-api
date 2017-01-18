require 'rails_helper'

RSpec.feature 'rake import:all_organisations', type: :feature do
  let(:two_organisations) {
    {
      results: [
        { slug: 'slug-1', title: 'title-1' },
        { slug: 'slug-2', title: 'title-2' }
      ]
    }.to_json
  }

  before do
    Rake::Task['import:all_organisations'].reenable
    stub_request(:get, %r{.*}).to_return(:status => 200, :body => two_organisations)
  end

  it 'creates all organisations' do
    expect { Rake::Task['import:all_organisations'].invoke }.to change { Organisation.count }.by(2)
  end

  it 'saves an organisation attributes' do
    Rake::Task['import:all_organisations'].invoke

    organisation = Organisation.find_by(slug: 'slug-1')
    expect(organisation.title).to eq('title-1')
    expect(organisation.slug).to eq('slug-1')
  end
end
