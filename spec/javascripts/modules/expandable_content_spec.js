describe("Expandable content", function () {
  "use strict";

  var $fixture;

  describe("with default settings", function () {
    beforeEach(function () {
      fixture.load("expandable_content/default.html.erb");
      $fixture = $(fixture.el).find('[data-module="expandable-content"]');
      new GOVUKAdmin.Modules.ExpandableContent().start($fixture);
    });

    it("starts with the content collapsed", function () {
      expect(content()).not.toHaveClass("in");
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
      fixture.load("expandable_content/start_expanded.html.erb");
      $fixture = $(fixture.el).find('[data-module="expandable-content"]');
      new GOVUKAdmin.Modules.ExpandableContent().start($fixture);
    });

    it("starts with the content expanded", function () {
      expect(content()).toHaveClass("in");
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

  function content() {
    return $fixture.find("#additionalContent").first();
  }
});
