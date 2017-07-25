RSpec.describe Search::QueryBuilder do
  describe "per_page" do
    it "defaults to 25" do
      query = Search::QueryBuilder.new.build
      expect(query.per_page).to eq(25)
    end

    it "coerces strings to integers" do
      query = Search::QueryBuilder.new
        .per_page("3")
        .build
      expect(query.per_page).to eq(3)
    end

    it "limits to 100" do
      query = Search::QueryBuilder.new
        .per_page(101)
        .build
      expect(query.per_page).to eq(100)
    end
  end

  describe "page" do
    it "defaults to 1" do
      query = Search::QueryBuilder.new.build
      expect(query.page).to eq(1)
    end

    it "coerces strings to integers" do
      query = Search::QueryBuilder.new
        .page("3")
        .build
      expect(query.page).to eq(3)
    end

    it "sets to 1 if <= 0" do
      query = Search::QueryBuilder.new
        .page(0)
        .build
      expect(query.page).to eq(1)

      query = Search::QueryBuilder.new
        .page(-123)
        .build
      expect(query.page).to eq(1)
    end
  end

  describe "sort" do
    it "defaults to page_views_desc" do
      query = Search::QueryBuilder.new.build
      expect(query.sort.identifier).to eq(:page_views_desc)
    end
  end

  it "does not apply any filters by default" do
    query = Search::QueryBuilder.new.build
    expect(query.filters).to be_empty
  end

  describe "audit_status" do
    it "adds a filter" do
      query = Search::QueryBuilder.new
        .audited
        .build
      expect(query.filters).to be_present
    end
  end

  describe "theme" do
    it "does not add a filter if an unrecognised type" do
      query = Search::QueryBuilder.new
        .theme("Unknown_123")
        .build
      expect(query.filters).to be_empty
    end

    context "when filtering by theme" do
      let(:theme) { create(:theme) }
      let(:identifier) { "Theme_#{theme.id}" }

      it "adds a rules filter when setting the theme" do
        query = Search::QueryBuilder.new
          .theme(identifier)
          .build

        expect(query.filters).to be_present
        expect(query.filters.first).to be_a(Search::RulesFilter)
      end

      it "raises an error if theme doesn't exist" do
        query_builder = Search::QueryBuilder.new
        expect { query_builder.theme("Theme_999") }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when filtering by subtheme" do
      let(:subtheme) { create(:subtheme) }
      let(:identifier) { "Subtheme_#{subtheme.id}" }

      it "adds a rules filter when setting the theme" do
        query = Search::QueryBuilder.new
          .theme(identifier)
          .build

        expect(query.filters).to be_present
        expect(query.filters.first).to be_a(Search::RulesFilter)
      end

      it "raises an error if subtheme doesn't exist" do
        query_builder = Search::QueryBuilder.new
        expect { query_builder.theme("Subtheme_999") }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "document_type" do
    it "adds a filter" do
      query = Search::QueryBuilder.new
        .document_type("organisation")
        .build
      expect(query.filters).to be_present
    end
  end

  describe "#filter_by" do
    it "raises an error if a filter already exists for a type" do
      query_builder = Search::QueryBuilder.new
        .filter_by(link_type: "organisations", source_ids: nil, target_ids: "org1")

      expect { query_builder.filter_by(link_type: "organisations", source_ids: nil, target_ids: "org1") }
        .to raise_error(FilterError, /duplicate/)
    end

    it "raises an error if filtering by both source and target" do
      query_builder = Search::QueryBuilder.new
        .filter_by(link_type: "organisations", source_ids: nil, target_ids: "org1")

      expect { query_builder.filter_by(link_type: "policies", source_ids: "id2", target_ids: nil) }
        .to raise_error(FilterError, /source and target/)
    end

    it "raises errors correctly when other types of filters are set" do
      query_builder = Search::QueryBuilder.new
        .audited
        .filter_by(link_type: "organisations", source_ids: nil, target_ids: "org1")

      expect { query_builder.filter_by(link_type: "policies", source_ids:  "id2", target_ids: nil) }
        .to raise_error(FilterError, /source and target/)
    end

    it "stores the list of filters" do
      query = Search::QueryBuilder.new
        .filter_by(link_type: "organisations", source_ids: nil, target_ids: "org1")
        .filter_by(link_type: "policies", source_ids: nil, target_ids: "org2")
        .build

      expect(query.filters.count).to eq(2)
    end
  end
end
