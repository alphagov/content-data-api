RSpec.describe Findable do
  class FindableTestClass
    extend Findable

    def self.all
      [new(:identifier)]
    end

    attr_accessor :identifier

    def initialize(identifier)
      self.identifier = identifier
    end
  end

  it "finds the instance with the given identifier" do
    instance = FindableTestClass.find(:identifier)
    expect(instance.identifier).to eq(:identifier)
  end

  it "raises an error if no instance can be found" do
    expect { FindableTestClass.find(:missing) }
      .to raise_error(NotFoundError, "'missing' unrecognised")
  end
end
