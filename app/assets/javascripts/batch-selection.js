(function (Modules) {
  "use strict";

  Modules.BatchSelection = function () {
    this.start = function ($root) {
      var $batchSizeInput = $root.find("#batch_size"),
        $checkboxes = $root.find("tbody input[type=checkbox]"),
        $selectAll = $root.find("#select-all");

      $batchSizeInput.keyup(function () {
        selectFirstCheckboxes($batchSizeInput.val());
      });

      $checkboxes.click(function () {
        var checked = $checkboxes.filter(function () {
          return $(this).is(':checked');
        });

        $batchSizeInput.val(checked.length);

        $selectAll.prop('checked', checked.length === $checkboxes.length);
      });

      $selectAll.click(function () {
        var isChecked = $selectAll.is(':checked');

        if (isChecked) {
          selectFirstCheckboxes($checkboxes.length);
        } else {
          selectFirstCheckboxes(0);
        }
      });

      function selectFirstCheckboxes(numberToSelect) {
        $checkboxes
          .prop('checked', false)
          .slice(0, numberToSelect)
          .prop('checked', true);

        $batchSizeInput.val(numberToSelect);

        $selectAll.prop('checked', numberToSelect >= $checkboxes.length);
      }
    }
  };
})(window.GOVUKAdmin.Modules);
