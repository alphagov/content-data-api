(function (Modules) {
  "use strict";

  Modules.ShowFreeTextQuestion = function () {
    this.start = function($element) {
      var $textBox = $element.find('.js-free-text-question');
      addEventListener();

      function addEventListener() {
        var $checkbox = $element.find('.js-yes-checkbox input[type=checkbox]');

        $checkbox.click(function () {
          var isChecked = $checkbox.is(':checked');

          if (isChecked) {
            showTextBox();
          } else {
            hideTextBox();
          }
        });
      }

      function showTextBox() {
        $textBox.removeClass('if-js-hide');
      }

      function hideTextBox () {
        $textBox.addClass('if-js-hide');
      }
    }
  };

})(window.GOVUKAdmin.Modules);