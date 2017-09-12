(function (Modules) {
  "use strict";

  Modules.ExpandableFilters = function () {
    this.start = function ($element) {
      initialise();

      function initialise() {
        if (startCollapsed()) {
          collapseFilters();
        }

        showExpansionButton();
        showElement();
      }

      function startCollapsed() {
        return !$element.data('start-expanded');
      }

      function collapseFilters() {
        var $additional = $element.find('.js-additional-filters').first();
        $additional.removeClass('in');
      }

      function showExpansionButton() {
        var $expansionButton = $element.find('.js-expand-button-wrapper').first();
        $expansionButton.removeClass('hidden');
      }

      function showElement() {
        $element.removeClass('js-hidden');
      }
    };
  };
})(window.GOVUKAdmin.Modules);
