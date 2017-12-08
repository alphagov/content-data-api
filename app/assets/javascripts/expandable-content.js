(function (Modules) {
  "use strict";

  Modules.ExpandableContent = function () {
    this.start = function ($element) {
      initialise();

      function initialise() {
        if (startCollapsed()) {
          collapse();
        }

        showExpansionButton();
        showElement();
      }

      function startCollapsed() {
        return !$element.data('start-expanded');
      }

      function collapse() {
        var $additional = $element.find('.js-additional-content').first();
        $additional.removeClass('in');
      }

      function showExpansionButton() {
        var $expansionButton = $element.find('.js-expand-button-wrapper').first();
        $expansionButton.removeClass('hidden');
      }

      function showElement() {
        $element.removeClass('if-js-hide');
      }
    };
  };
})(window.GOVUKAdmin.Modules);
