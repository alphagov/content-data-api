window.GOVUKAdmin.Modules = window.GOVUKAdmin.Modules || {};

(function (Modules) {
  "use strict";

  Modules.OrganisationMultiSelect = function () {
    this.start = function ($element) {
      accessibleAutocomplete.enhanceSelectElement({
        selectElement: $element.find('#organisations')[0],
        showAllValues: true,
        autoselect: false,
        dropdownArrow: dropdownArrow
      });
    };

    function dropdownArrow() {
      return '<span class="caret"></span>';
    }
  };
})(window.GOVUKAdmin.Modules);
