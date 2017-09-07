(function () {
  "use strict";

  $(document).on("change", "select", trackEvent);

  function trackEvent(event) {
    var $select = $(event.target);

    var trackingEvent = {
      "event": "govuk.change",
      "govuk.value": $select.val()
    };

    dataLayer.push(trackingEvent);
  }
})();
