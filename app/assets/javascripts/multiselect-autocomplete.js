(function (Modules) {
  "use strict";

  Modules.MultiselectAutocomplete = function () {
    this.start = function ($element) {

      var template = selectHTML();

      appendAddButton();
      createSelectElementsForSelectedOptions();
      enableAutocomplete();

      function selectHTML() {
        var $select = selects().first();
        $select.removeAttr('multiple');
        var $wrapper = wrapper($select);
        var $template = $wrapper.clone();
        $template.find('[selected]').removeAttr('selected');
        return $template.prop('outerHTML');
      }

      function addButton() {
        return $(
          '<button type="button" ' +
          '        class="btn btn-link add-select js-add-select">' +
          '  Add another ' + selectType() +
          '</button>'
        ).click(addSelect);
      }

      function removeButton() {
        return $(
          '<button type="button" ' +
          '        class="remove-select js-remove-select">' +
          '  <span class="glyphicon glyphicon-remove"' +
          '        aria-hidden="true"></span>' +
          '  <span class="sr-only">Remove ' + selectType() + '</span>' +
          '</button>'
        ).click(removeSelect);
      }

      function appendAddButton() {
        $element.append(addButton());
      }

      function createSelectElementsForSelectedOptions() {
        selectedOptions().each(function (index, option) {
          if (index > 0) {
            $(template)
              .insertAfter(lastSelectWrapper())
              .find('option[value="' + $(option).val() + '"]')
              .attr('selected', 'selected')
          }
        });
      }

      function enableAutocomplete() {
        selects().each(function (index, select) {

          // When we have a select with the multiple attribute set and no
          // option is selected, the selectedIndex property will return -1. We
          // have a blank option at index 0. Selecting the blank option
          // circumvents a regression in the accessible autocomplete component
          // where it assumes `selectedIndex` is always a positive number.
          if (select.selectedIndex === -1) {
            select.selectedIndex = 0;
          }

          enhanceSelectElement(select);
        });
      }

      function enhanceSelectElement(select) {
        accessibleAutocomplete.enhanceSelectElement({
          selectElement: select,
          showAllValues: true,
          autoselect: false,
          dropdownArrow: dropdownArrow
        });

        wrapper($(select)).append(removeButton());
      }

      function addSelect() {
        var $newSelectWrapper = $(template);
        enhanceSelectElement($newSelectWrapper.find('select')[0]);
        $newSelectWrapper.insertAfter(lastSelectWrapper());
      }

      function removeSelect(event) {
        var $removeButton = $(event.target);
        var $selectWrapper = wrapper($removeButton);

        if (selects().length === 1) {
          clearAutocompleteAndSelect($selectWrapper);
        } else {
          $selectWrapper.remove();
        }
      }

      function clearAutocompleteAndSelect($selectWrapper) {
        var $input = $selectWrapper.find('input');
        $input.val('');
        // Changing the value will expand the autocomplete, but without focus, meaning that
        // it won't close if you click outside it. Here we manually focus and blur it, so
        // the options don't display
        $input.click().focus().blur();
        // Clearing the input doesn't reset the select, so we have to reset it manually.
        // See: https://github.com/alphagov/accessible-autocomplete/issues/220
        $selectWrapper.find('select').val('');
      }

      function selects() {
        return $element.find('.js-select');
      }

      function selectedOptions() {
        return $element.find('[selected]');
      }

      function lastSelectWrapper() {
        return $element.find('.js-select-wrapper').last();
      }

      function wrapper($wrapped) {
        return $wrapped.closest('.js-select-wrapper');
      }

      function dropdownArrow() {
        return '<span class="caret"></span>';
      }

      function selectType() {
        return $element.data('select-type');
      }
    };
  };
})(window.GOVUKAdmin.Modules);
