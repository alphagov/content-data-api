require 'rails_helper'

RSpec.describe Items::OutdatedItemsProcessor do
  let(:content_id) { 'outdated1' }
  let(:later_content_id) { 'outdated_next_day' }
  let(:base_path) { '/the/base/path' }
  let(:locale) { 'en' }
  let(:date) { Date.new(2018, 2, 20) }
  let(:subject) { described_class.new(date: date + 1.second) }

  before :each do
    allow(Items::Jobs::ImportContentDetailsJob).to receive(:perform_async)
    create(
      :outdated_item,
      latest: true,
      content_id: content_id,
      base_path: base_path,
      locale: locale,
      outdated_at: date
    )
    create(
      :outdated_item,
      latest: true,
      content_id: later_content_id,
      base_path: base_path,
      outdated_at: date + 1.day,
      locale: locale
    )
    subject.process
  end

  it 'fires a Sidekiq job for the new item' do
    latest_id = Dimensions::Item.find_by(content_id: content_id, latest: true).id

    expect(Items::Jobs::ImportContentDetailsJob).to have_received(:perform_async).with(latest_id)
  end

  it 'does not touch content from later than the given date' do
    expect(Dimensions::Item.where(content_id: later_content_id, latest: true, outdated: true).count).to eq(1)
  end
end
