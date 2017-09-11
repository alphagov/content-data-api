describe('Batch allocation module', function () {
  'use strict';

  var $input,
    $checkboxes;

  beforeEach(function () {
    var module = new GOVUKAdmin.Modules.BatchSelection();
    fixture.load('batch-selection.html');
    var $root = $(':first-child', fixture.el);
    module.start($root);

    $input = $root.find("input[type=text]");
    $checkboxes = $root.find("input[type=checkbox]")
  });

  describe('Batch input changes', function () {
    it('Select `n` checkboxes when user enters `n` in batch input', function () {
      $input.val(3).trigger("keyup")

      var total = $checkboxes.filter(function () {
        return $(this).is(':checked');
      }).length;
      expect(total).toBe(3);
    });
  });

  describe('Updates the batch input value according to the number of selected checkboxes', function () {
    it('Increment the counter with each checkbox selection', function () {
      $checkboxes.eq(6).click();
      $checkboxes.eq(2).click();
      $checkboxes.eq(5).click();

      expect($input.val()).toBe('3');
    });

    it('Decrement the counter if a checkbox is de-selected', function () {
      $checkboxes.eq(3).click();
      expect($input.val()).toBe('1');

      $checkboxes.eq(3).click();
      expect($input.val()).toBe('0');
    });
  });
});
