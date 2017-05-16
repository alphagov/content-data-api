class ContentItemsService
  PER_PAGE = 1_000

  def content_ids
    results = paginate do |p|
      publishing_api.get_content_items({
        fields: %w(content_id),
        states: %w(published),
      }.merge(p))
    end

    results.map { |r| r.fetch(:content_id) }
  end

  def fetch(content_id)
    normalise(publishing_api.get_content(content_id))
  end

  def links(content_id)
    normalise(publishing_api.get_links(content_id)).fetch(:links)
  end

private

  def paginate
    page = 1
    results = []

    loop do
      response = yield(page: page, per_page: PER_PAGE)
      results += normalise(response).fetch(:results)
      return results if last_page?(response)
      page += 1
    end
  end

  def normalise(response)
    response.to_hash.deep_symbolize_keys
  end

  def publishing_api
    Services.publishing_api
  end

  def last_page?(response)
    response["current_page"] == response["pages"]
  end
end
