(function (Modules) {
  "use strict";

  Modules.ExpandableMetadata = function () {
    this.start = function ($element) {
      var expanded = true;

      initialise();

      function initialise() {
        hideChildren();
        addButton();
        unhideElement();
      }

      function hideChildren() {
        $element.children("div").hide();
      }

      function addButton() {
        var $button = $('<button id="more-item-details" class="btn btn-link"></button>').click(toggleExpansion);
        var $span = $('<span class="button-container"></span>');
        $span.prepend($button);
        $element.prepend($span);

        toggleExpansion();
      }

      function unhideElement() {
        $element.removeClass("if-js-hide");
      }

      function toggleExpansion() {
        expanded = !expanded;
        var $button = $element.find("#more-item-details");

        var html;
        if (expanded) {
          html = '<span class="glyphicon glyphicon-triangle-bottom"></span> Fewer details';
        } else {
          html = '<span class="glyphicon glyphicon-triangle-right"></span> More details';
        }
        $button.html(html);

        $element.children("div").toggle(expanded);
      }
    };
  };
})(window.GOVUKAdmin.Modules);
