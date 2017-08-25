describe('A select-all module', function() {
  'use strict';

  var selectAll,
      selectOnAllPages,
      itemCheckboxes,
      element;

  beforeEach(function() {
    selectAll = new GOVUKAdmin.Modules.SelectAll();
  });

  describe('when select-all checkbox is checked', function() {
    beforeEach(function() {
      element = $('\
         <div data-module="select-all">\
          <div>\
            <label>\
              <input type="checkbox" name="select_all" id="select_all"> Select all\
            </label>\
          </div>\
          <input type="checkbox" class="select-content-item">\
          <div class="checkbox if-js-hide" id="select_all_pages_container">\
            <input type="checkbox" id="select_all_pages">\
          </div>\
        </div>\
      ');

      itemCheckboxes = element.find('.select-content-item');
      selectOnAllPages = element.find('#select_all_pages_container');

      selectAll.start(element);
      element.find('#select_all')
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
      // Attach element to DOM otherwise view is invisible
      $('body').append(element);
      expect(selectOnAllPages).toBeVisible;
    });
  });
});
