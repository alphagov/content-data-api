describe("Tracking select change events", function () {
  "use strict";

  fixture.preload("analytics/track_select_change.html");

  var $fixture;
  beforeEach(function () {
    loadFixture();
    clearDataLayer();
  });

  describe("Changing a select element", function () {
    it("pushes an event on to the dataLayer", function () {
      expect(changeEventsInDataLayer()).toHaveLength(0);

      var $select = $fixture.find("select");
      $select.change();

      expect(changeEventsInDataLayer()).toHaveLength(1);

      var event = changeEventsInDataLayer()[0];

      expect(event).toEqual(jasmine.objectContaining({
        "event": "govuk.change",
        "govuk.value": "2",
        "govuk.trackingId": "some-tracking-id"
      }));
    });
  });

  describe("Changing an input element", function () {
    it("does not push an event on to the dataLayer", function () {
      var $input = $fixture.find("input");
      $input.change();

      expect(changeEventsInDataLayer()).toHaveLength(0);
    });
  });

  function loadFixture() {
    fixture.load("analytics/track_select_change.html");
    $fixture = $(fixture.el);
  }

  function clearDataLayer() {
    dataLayer.length = 0;
  }

  function changeEventsInDataLayer() {
    return dataLayer.filter(function (obj) {
      return obj.event === "govuk.change";
    });
  }
});
