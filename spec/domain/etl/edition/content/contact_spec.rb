RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class.instance }

  it "does not return phone numbers if there is no 'phone_numbers' key" do
    json = {
      schema_name: 'contact',
      details: {
        description: 'main desc',
        email_addresses: [
          { title: 'title 1', description: '<p>desc 1</p>' },
          { title: 'title 2', description: '<p>desc 2</p>' }
        ],
        more_info_email_address: '<p>more info</p>',
        post_addresses: [
          { title: 'post1 title', description: '<p>post1 desc</p>' },
          { title: 'post2 title', description: '<p>post2 desc</p>' }
        ],
        more_info_post_address: '<p>more info post</p>'
      }
    }
    expected = [
      'main desc title 1 desc 1 title 2 desc 2',
      'more info',
      'post1 title post1 desc post2 title post2 desc',
      'more info post'
    ].join(' ')
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
  end

  it "does not return post_addresses if there is no 'post_addresses' key" do
    json = {
      schema_name: 'contact',
      details: {
        description: 'main desc',
        email_addresses: [
          { title: 'title 1', description: '<p>desc 1</p>' },
          { title: 'title 2', description: '<p>desc 2</p>' }
        ],
        more_info_email_address: '<p>more info</p>',
        more_info_post_address: '<p>more info post</p>'
      }
    }
    expected = [
      'main desc title 1 desc 1 title 2 desc 2',
      'more info',
      'more info post'
    ].join(' ')
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
  end

  it "does not return email_addresses if there is no 'email_addresses' key" do
    json = {
      schema_name: 'contact',
      details: {
        description: 'main desc',
        post_addresses: [
          { title: 'post1 title', description: '<p>post1 desc</p>' },
          { title: 'post2 title', description: '<p>post2 desc</p>' }
        ],
        more_info_post_address: '<p>more info post</p>'
      }
    }
    expected = [
      'main desc',
      'post1 title post1 desc post2 title post2 desc',
      'more info post'
    ].join(' ')
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
  end

  it "returns content if schema name is 'contact'" do
    json = {
      schema_name: 'contact',
      details: {
        description: 'main desc',
        email_addresses: [
          { title: 'title 1', description: '<p>desc 1</p>' },
          { title: 'title 2', description: '<p>desc 2</p>' }
        ],
        more_info_email_address: '<p>more info</p>',
        post_addresses: [
          { title: 'post1 title', description: '<p>post1 desc</p>' },
          { title: 'post2 title', description: '<p>post2 desc</p>' }
        ],
        more_info_post_address: '<p>more info post</p>',
        phone_numbers: [
          { title: 'phone1 title', description: '<p>phone1 desc</p>' },
          { title: 'phone2 title', description: '<p>phone2 desc</p>' }
        ],
        more_info_phone_number: '<p>more info phone</p>'
      }
    }
    expected = [
      'main desc title 1 desc 1 title 2 desc 2',
      'more info',
      'post1 title post1 desc post2 title post2 desc',
      'more info post',
      'phone1 title phone1 desc phone2 title phone2 desc more info phone'
    ].join(' ')
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
  end
end
