describe('A select-all module', function() {
  'use strict';

  var selectAll,
      selectOnAllPages,
      itemCheckboxes,
      $element;

  beforeEach(function() {
    selectAll = new GOVUKAdmin.Modules.SelectAll();
  });

  describe('when select-all checkbox is checked', function() {
    beforeEach(function() {
      this.fixtures = fixture.load('select-all.html');

      $element = $(':first-child', fixture.el);
      itemCheckboxes = $element.find('.select-content-item');
      selectOnAllPages = $element.find('#select_all_pages_container');

      selectAll.start($element);
      $element.find('#select_all')
        .prop('checked', true)
        .trigger('change');
    });

    it('checks the checkboxes of items on the page', function() {
      expect(itemCheckboxes).toBeChecked();
    });

    it('removes the if-js-hide class to display Select X items on all pages checkbox', function () {
      expect(selectOnAllPages).toHaveClass('checkbox');
      expect(selectOnAllPages).not.toHaveClass('if-js-hide');
    });

    it('displays the Select X items on all pages checkbox', function() {
      expect(selectOnAllPages).toBeVisible;
    });
  });
});
