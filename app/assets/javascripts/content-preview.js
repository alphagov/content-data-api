(function (Modules) {
  "use strict";

  Modules.ContentPreview = function () {
    this.start = function ($element) {
      var $iframe = $element.find('iframe');

      initialise();

      function initialise() {
        addSpinner();
        $iframe.load(onIframeLoaded);
      }

      function addSpinner() {
        $element.append(
          '<div class="spinner"></div>'
        );
      }

      function onIframeLoaded() {
        hideSpinner();
        $iframe.removeClass('if-js-hide');
      }

      function hideSpinner() {
        $element.children('.spinner').remove();
      }
    };
  };
})(window.GOVUKAdmin.Modules);
