describe('A show free text question textbox module', function() {
  'use strict';

  var showFreeTextQuestion,
      $element,
      yesRadio,
      noRadio,
      textBox;

  beforeEach(function() {
    showFreeTextQuestion = new GOVUKAdmin.Modules.ShowFreeTextQuestion();
    this.fixtures = fixture.load('show-free-text-question.html');

    $element = $(':first-child', fixture.el);
    yesRadio = $element.find('.js-yes-radio');
    noRadio = $element.find('.js-no-radio');
    textBox = $element.find('.js-free-text-question');

    showFreeTextQuestion.start($element);
  });

  describe('when "yes" radio is chosen', function() {
    it('removes the if-js-hide class from the free text question', function(){
      expect(textBox).toHaveClass('if-js-hide');

      yesRadio.click();
      expect(textBox).not.toHaveClass('if-js-hide');
    });
  });

  describe('when "no" radio is chosen', function () {
    it('adds the if-js-hide class onto the free text question', function () {
      textBox.removeClass('if-js-hide');
      expect(textBox).not.toHaveClass('if-js-hide');

      noRadio.click();
      expect(textBox).toHaveClass('if-js-hide');
    })
  });
});
