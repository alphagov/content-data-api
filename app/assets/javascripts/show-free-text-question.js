(function (Modules) {
  "use strict";

  Modules.ShowFreeTextQuestion = function () {
    this.start = function($element) {
      var $textBox = $element.find('.js-free-text-question');
      addEventListener();

      function addEventListener() {
        var $yesRadio = $element.find('.js-yes-radio');
        var $noRadio = $element.find('.js-no-radio');

        $yesRadio.click(showTextBox);
        $noRadio.click(hideTextBox);
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