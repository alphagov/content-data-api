(function () {
  $(window).load(function () {
    $(".inventory .content a[data-remote]").on("ajax:success", function (e, data) {
      if (data === "created") {
        $(e.target).addClass("active");
      } else if (data === "destroyed") {
        $(e.target).removeClass("active");
      }
    });
  });
})();
