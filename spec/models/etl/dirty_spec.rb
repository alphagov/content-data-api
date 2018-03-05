require 'rails_helper'

RSpec.describe ETL::Dirty do
  let(:content_id) { 'dirty1' }
  let(:base_path) { '/the/base/path' }
  let(:date) {}

  before :each do
    allow(ImportContentDetailsJob).to receive(:perform_async)
    create(:dimensions_item,
      latest:     true,
      dirty:      true,
      content_id: content_id,
      base_path: base_path)
    subject.process
  end

  it 'resets the dirty flag on the item' do
    expect(Dimensions::Item.where(content_id: content_id, dirty: true).count).to eq(0)
  end

  it 'resets the latest flag on the old item' do
    expect(Dimensions::Item.where(content_id: content_id, latest: true).count).to eq(1)
    expect(Dimensions::Item.where(content_id: content_id, latest: false).count).to eq(1)
  end

  it 'fires a Sidekiq job for the new item' do
    expect(ImportContentDetailsJob).to have_received(:perform_async).with(content_id, base_path)
  end
end
