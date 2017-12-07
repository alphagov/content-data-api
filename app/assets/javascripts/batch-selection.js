(function (Modules) {
  "use strict";

  Modules.BatchSelection = function () {
    this.start = function ($root) {
      var $batchSizeInput = $root.find(".js-batch-size");
      var $checkboxes = $root.find("tbody input[type=checkbox]");
      var $selectAll = $root.find(".js-select-all");

      $batchSizeInput.keyup(batchSelectFromTextInput);
      $checkboxes.click(updateBatchInputAndSelectAll);
      $selectAll.click(toggleSelectAll);

      function batchSelectFromTextInput() {
        selectFirstFewCheckboxes($batchSizeInput.val());
      }

      function updateBatchInputAndSelectAll() {
        var checkedCheckboxes = $checkboxes.filter(function () {
          return $(this).is(':checked');
        });

        $batchSizeInput.val(checkedCheckboxes.length);

        $selectAll.prop('checked', checkedCheckboxes.length === $checkboxes.length);
      }

      function toggleSelectAll() {
        var isChecked = $selectAll.is(':checked');

        if (isChecked) {
          selectFirstFewCheckboxes($checkboxes.length);
        } else {
          selectFirstFewCheckboxes(0);
        }
      }

      function selectFirstFewCheckboxes(numberToSelect) {
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
