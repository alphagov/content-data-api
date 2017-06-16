class Report
  def self.generate(*args)
    new(*args).generate
  end

  attr_accessor :audits

  def initialize(audits)
    self.audits = audits.includes(:content_item, :user)
  end

  def generate
    CSV.generate do |csv|
      csv << headers

      each do |_audit, item, user|
        csv << [item.title, user.name]
      end
    end
  end

private

  def headers
    ["Title", "Audited by"]
  end

  def each
    audits.find_each do |audit|
      yield [audit, audit.content_item, audit.user]
    end
  end
end
