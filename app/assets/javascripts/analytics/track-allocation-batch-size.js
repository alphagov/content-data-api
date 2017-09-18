(function (Modules) {
  "use strict";

  Modules.TrackAllocationBatchSize = function () {
    var TRACKING_ID = "allocation-batch-size";

    this.start = function ($form) {
      $form.submit(trackAllocationBatchSize);

      function trackAllocationBatchSize() {
        var trackingEvent = {
          "event": "govuk.submit",
          "govuk.trackingId": TRACKING_ID,
          "govuk.value": allocationBatchSize()
        };

        dataLayer.push(trackingEvent);
      }

      function allocationBatchSize() {
        return $form.find("[data-tracking-id=" + TRACKING_ID + "]").val();
      }
    };
  };
})(window.GOVUKAdmin.Modules);
