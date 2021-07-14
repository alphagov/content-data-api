module Streams
  class Messages::MultipartMessage < Messages::BaseMessage
    def self.is_multipart?(payload)
      payload.dig("details", "parts").present?
    end

    def handler
      Streams::Handlers::MultipartHandler.new(
        edition_attributes,
        content_id,
        locale,
        @payload,
        @routing_key,
      )
    end

    def edition_attributes
      attrs = parts.map.with_index do |part, index|
        build_attributes(
          base_path: base_path_for_part(part, index),
          title: title_for(part),
          document_text: document_text_for_part(part["slug"]),
          warehouse_item_id: warehouse_item_id_for_part(part, index),
          sibling_order: index,
        )
      end
      parent = attrs.first
      children = attrs.drop(1)
      parent[:child_sort_order] = children.map { |h| h[:warehouse_item_id] }
      children.each { |h| h[:parent_warehouse_id] = parent[:warehouse_item_id] }
      attrs
    end

  private

    def parts
      message_parts = @payload.dig("details", "parts").dup
      if doc_type == "travel_advice"
        message_parts.prepend(
          "slug" => base_path,
          "title" => "Summary",
          "body" => [@payload.dig("details", "summary").find { |x| x["content_type"] == "text/html" }],
        )
      end
      message_parts
    end

    def title_for(part)
      "#{main_title}: #{part.fetch('title')}"
    end

    def base_path_for_part(part, index)
      part_sub_path = sub_path_for_part(part, index)

      if part_sub_path
        "#{base_path}/#{part_sub_path}"
      else
        base_path
      end
    end

    def sub_path_for_part(part, index)
      return nil if index.zero?

      part.fetch("slug")
    end

    def warehouse_item_id_for_part(part, index)
      if index.zero?
        "#{content_id}:#{locale}"
      else
        part_sub_path = sub_path_for_part(part, index)

        "#{content_id}:#{locale}:#{part_sub_path}"
      end
    end

    attr_reader :payload, :message_parts

    def doc_type
      @payload.fetch("document_type")
    end

    def base_path
      @payload.fetch("base_path")
    end

    def main_title
      @payload.fetch("title")
    end

    def document_text_for_part(slug)
      ::Etl::Edition::Content::Parser.extract_content(@payload, subpage_path: slug)
    end
  end
end
