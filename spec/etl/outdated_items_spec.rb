require 'rails_helper'

RSpec.describe ETL::OutdatedItems do
  let(:content_id) { 'outdated1' }
  let(:later_content_id) { 'outdated_next_day' }
  let(:base_path) { '/the/base/path' }
  let(:locale) { 'en' }
  let(:date) { Date.new(2018, 2, 20) }
  let(:subject) { described_class.new(date: date + 1.second) }

  before :each do
    allow(ImportContentDetailsJob).to receive(:perform_async)
    create(
      :dimensions_item,
      latest: true,
      outdated: true,
      content_id: content_id,
      base_path: base_path,
      locale: locale,
      outdated_at: date
    )
    create(
      :dimensions_item,
      latest: true,
      outdated: true,
      content_id: later_content_id,
      base_path: base_path,
      outdated_at: date + 1.day,
      locale: locale
    )
    subject.process
  end

  it 'resets the outdated flag on the item' do
    expect(Dimensions::Item.where(content_id: content_id, outdated: true, locale: locale).count).to eq(0)
  end

  it 'resets the latest flag on the old item' do
    expect(Dimensions::Item.where(content_id: content_id, latest: true, locale: locale).count).to eq(1)
    expect(Dimensions::Item.where(content_id: content_id, latest: false, locale: locale).count).to eq(1)
  end

  it 'fires a Sidekiq job for the new item' do
    latest_id = Dimensions::Item.find_by(content_id: content_id, latest: true).id

    expect(ImportContentDetailsJob).to have_received(:perform_async).with(latest_id)
  end

  it 'does not touch content from later than the given date' do
    expect(Dimensions::Item.where(content_id: later_content_id, latest: true, outdated: true).count).to eq(1)
  end
end
