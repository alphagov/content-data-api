describe("Expandable filters", function () {
  "use strict";

  var $fixture;

  describe("with default settings", function () {
    beforeEach(function () {
      fixture.load("expandable_filters/default.html.erb");
      $fixture = $(fixture.el).find('[data-module="expandable-filters"]');
      new GOVUKAdmin.Modules.ExpandableFilters().start($fixture);
    });

    it("starts with the options collapsed", function () {
      expect(filters()).not.toHaveClass("in");
    });

    it("shows the expansion button", function () {
      expect(buttonWrapper()).not.toHaveClass("hidden");
    });

    it("starts with the button collapsed", function () {
      expect(button()).toHaveClass("collapsed")
    });
  });

  describe("starting expanded", function () {
    beforeEach(function () {
      fixture.load("expandable_filters/start_expanded.html.erb");
      $fixture = $(fixture.el).find('[data-module="expandable-filters"]');
      new GOVUKAdmin.Modules.ExpandableFilters().start($fixture);
    });

    it("starts with the options expanded", function () {
      expect(filters()).toHaveClass("in");
    });

    it("shows the expansion button", function () {
      expect(buttonWrapper()).not.toHaveClass("hidden");
    });

    it("starts with the button not collapsed", function () {
      expect(button()).not.toHaveClass("collapsed");
    });
  });

  function buttonWrapper() {
    return $fixture.find(".js-expand-button-wrapper").first();
  }

  function button() {
    return $fixture.find("button").first();
  }

  function filters() {
    return $fixture.find("#additionalFilters").first();
  }
});
