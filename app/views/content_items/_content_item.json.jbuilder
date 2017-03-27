json.extract! content_item, :content_id, :base_path, :title, :document_type, :description, :public_updated_at, :unique_page_views, :number_of_pdfs
json.govuk_url url_for(content_item.url)
json.url content_item_url(content_item, format: :json)
