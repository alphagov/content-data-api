RSpec.describe Streams::Consumer do
  include PublishingEventProcessingSpecHelper

  let(:subject) { described_class.new }
  let(:content_id) { SecureRandom.uuid }

  it 'grows the dimension' do
    message1 = build :message, base_path: '/base-path', content_id: content_id, attributes: { 'payload_version' => 2 }
    message2 = build :redirect_message, base_path: '/base-path', content_id: content_id

    subject.process(message1)
    old_edition = Dimensions::Edition.find_by(base_path: '/base-path', latest: true)

    subject.process(message2)

    expect(old_edition.reload).to have_attributes(latest: false, base_path: '/base-path')
    expect(old_edition.document_type).to_not eq('redirect')

    new_edition = Dimensions::Edition.find_by(base_path: '/base-path', latest: true)
    expect(new_edition).to have_attributes(
      latest: true,
      content_id: content_id,
      base_path: '/base-path',
      document_type: 'redirect',
    )
  end

  context 'when multiple locales for the same content_id' do
    it 'grows the dimensions for en and fr' do
      fr_message = build :message, base_path: '/base-path/french', content_id: content_id, attributes: { 'payload_version' => 2 }
      en_message = build :message, base_path: '/base-path/english', content_id: content_id, attributes: { 'payload_version' => 3 }

      subject.process(fr_message)
      subject.process(en_message)

      fr_redirect_message = build :redirect_message, base_path: '/base-path/french', content_id: content_id
      subject.process(fr_redirect_message)

      fr_edition = Dimensions::Edition.find_by(base_path: '/base-path/french', latest: true)
      expect(fr_edition).to have_attributes(
        latest: true,
        content_id: content_id,
        base_path: '/base-path/french',
        document_type: 'redirect'
      )

      en_edition = Dimensions::Edition.find_by(base_path: '/base-path/english', latest: true)
      expect(en_edition).to have_attributes(
        latest: true,
        content_id: content_id,
        base_path: '/base-path/english'
      )
      expect(en_edition.document_type).to_not eq('redirect')
    end
  end
end
