(function (Modules) {
  "use strict";

  Modules.OrganisationAutocomplete = function () {
    this.start = function ($element) {

      var template = organisationSelectHTML();

      appendAddButton();
      createSelectElementsForSelectedOptions();
      enableAutocomplete();

      function organisationSelectHTML() {
        var $select = organisationSelects().first();
        $select.removeAttr('multiple');
        var $wrapper = wrapper($select);
        var $template = $wrapper.clone();
        $template.find('[selected]').removeAttr('selected');
        return $template.prop('outerHTML');
      }

      function addButton() {
        return $(
          '<button type="button" ' +
          '        id="add-organisation" ' +
          '        class="add-organisation js-add-organisation">' +
          '  Add another organisation' +
          '</button>'
        ).click(addOrganisation);
      }

      function removeButton() {
        return $(
          '<button type="button" ' +
          '        class="remove-organisation js-remove-organisation">' +
          '  <span class="glyphicon glyphicon-remove"' +
          '        aria-hidden="true"></span>' +
          '  <span class="sr-only">Remove organisation</span>' +
          '</button>'
        ).click(removeOrganisation);
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
        organisationSelects().each(function (index, select) {

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

      function organisationSelects() {
        return $element.find('.js-organisation-select');
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

      function addOrganisation() {
        var $newSelectWrapper = $(template);
        enhanceSelectElement($newSelectWrapper.find('select')[0]);
        $newSelectWrapper.insertAfter(lastSelectWrapper());
      }

      function removeOrganisation(event) {
        var $removeButton = $(event.target);
        var $organisationSelectWrapper = wrapper($removeButton);

        if (organisationSelects().length === 1) {
          clearAutocompleteAndSelect($organisationSelectWrapper);
        } else {
          $organisationSelectWrapper.remove();
        }
      }

      function clearAutocompleteAndSelect($organisationSelectWrapper) {
        $organisationSelectWrapper.find('input').val('');
        // Clearing the input doesn't reset the select, so we have to reset it manually.
        // See: https://github.com/alphagov/accessible-autocomplete/issues/220
        $organisationSelectWrapper.find('select').val('');
      }

      function organisationSelects() {
        return $element.find('.js-organisation-select');
      }

      function selectedOptions() {
        return $element.find('[selected]');
      }

      function lastSelectWrapper() {
        return $element.find('.js-organisation-select-wrapper').last();
      }

      function wrapper($wrapped) {
        return $wrapped.closest('.js-organisation-select-wrapper');
      }

      function dropdownArrow() {
        return '<span class="caret"></span>';
      }
    };
  };
})(window.GOVUKAdmin.Modules);
