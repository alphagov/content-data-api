window.GOVUKAdmin = window.GOVUKAdmin || {};
window.GOVUKAdmin.Modules = window.GOVUKAdmin.Modules || {};

(function (Modules) {
  "use strict";

  Modules.BatchSelection = function () {
    this.start = function ($root) {
      var $batchSizeInput = $root.find("#batch_size"),
        $checkboxes = $root.find("input[type=checkbox]");

      $batchSizeInput.keyup(function () {
          $checkboxes
            .prop('checked', false)
            .slice(0, $batchSizeInput.val())
            .prop('checked', true);
        }
      );

      $checkboxes.click(function () {
          var checked = $checkboxes.filter(function () {
            return $(this).is(':checked');
          });

          $batchSizeInput.val(checked.length);
        }
      );
    }
  };
})(window.GOVUKAdmin.Modules);
