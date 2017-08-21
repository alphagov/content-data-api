(function (Modules) {
  "use strict";

  Modules.SelectAll = function () {
    this.start = function ($element) {
      function addEventListener() {
        var $selectAll = $element.find('#select_all');
        var $selectAllPages = $element.find('#select_all_pages');
        var $selectAllPagesContainer = $selectAllPages.closest('.if-js-hide');

        if ($selectAll.length) {
          $selectAll.on('change', function (e) {
            var $checked = $selectAll.prop('checked');
            var $checkboxes = $('.select-content-item');
            $checkboxes.prop('checked', $checked);

            if ($selectAllPages.length) {
              $selectAllPages.prop('checked', false);
            }

            if ($selectAllPagesContainer.length) {
              $selectAllPagesContainer.toggleClass('if-js-hide', !$checked);
            }
          });
        }
      }

      addEventListener();
    }
  };
})(window.GOVUKAdmin.Modules);
