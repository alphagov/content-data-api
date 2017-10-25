(function (Modules) {
  "use strict";

  Modules.FullHeightIframe = function () {
    this.start = function ($element) {

      initialise();

      function initialise() {
        addSpinner();
        $element.load(restyleIframe);
      }

      function addSpinner() {
        $element.parent().append(
          '<div class="spinner">\n' +
          '  <div class="bounce1"></div>\n' +
          '  <div class="bounce2"></div>\n' +
          '  <div class="bounce3"></div>\n' +
          '</div>'
        );
      }

      function removeSpinner() {
        $element.parent().find('.spinner').remove();
      }

      function restyleIframe() {
        $element.attr('scrolling', 'no');
        var $iframeDocument = $($element[0].contentWindow.document);
        $iframeDocument.find('a').attr('target', '_blank').attr('rel', 'noopener noreferrer');
        $iframeDocument.find('#search').remove();
        $iframeDocument.find('.header-proposition').remove();
        removeSpinner();

        // We have to remove this class before resizing rather than after, because it causes us to get the wrong height
        // otherwise
        $element.removeClass('if-js-hide');
        $element.height($element[0].contentWindow.document.body.offsetHeight + 'px');
      }
    };
  };
})(window.GOVUKAdmin.Modules);
