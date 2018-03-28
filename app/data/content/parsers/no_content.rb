class Content::Parsers::NoContent
  def parse(_json)
    nil
  end

  def schemas
    %w[
    redirect
    placeholder_person
    placeholder
    ]
  end
end
