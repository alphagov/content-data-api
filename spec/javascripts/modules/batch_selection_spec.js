describe('Batch allocation module', function () {
  'use strict';

  describe('on a table with ten checkboxes', function () {
    var $batchInput;
    var $selectAll;
    var $checkboxes;

    beforeEach(function () {
      var module = new GOVUKAdmin.Modules.BatchSelection();
      fixture.load('batch_selection/ten_rows.html.erb');
      var $root = $(fixture.el);
      module.start($root);

      $batchInput = $root.find(".js-batch-size");
      $selectAll = $root.find(".js-select-all");
      $checkboxes = $root.find("tbody input[type=checkbox]");
    });

    describe("using the batch input to select", function () {
      describe("4 items", function () {
        beforeEach(function () {
          $batchInput.val(4).trigger("keyup");
        });

        it("selects the first 4 checkboxes in the table", function () {
          $checkboxes.slice(0, 4).each(function () {
            expect(this).toBeChecked();
          });

          $checkboxes.slice(4, 10).each(function () {
            expect(this).not.toBeChecked();
          });
        });

        it("leaves the select all unchecked", function () {
          expect($selectAll).not.toBeChecked();
        });
      });

      describe("all 10 items", function () {
        beforeEach(function () {
          $batchInput.val(10).trigger("keyup");
        });

        it("selects all the checkboxes in the table", function () {
          $checkboxes.each(function () {
            expect(this).toBeChecked();
          });
        });

        it("checks the select all", function () {
          expect($selectAll).toBeChecked();
        });
      });

      describe("more than 10 items", function () {
        beforeEach(function () {
          $batchInput.val(11).trigger("keyup");
        });

        it("selects all the checkboxes in the table", function () {
          $checkboxes.each(function () {
            expect(this).toBeChecked();
          });
        });

        it("checks the select all", function () {
          expect($selectAll).toBeChecked();
        });

        describe("and then deselecting a single checkbox", function () {
          beforeEach(function () {
            $checkboxes.eq(0).click();
          });

          it("shows 9 in the batch input", function () {
            expect($batchInput).toHaveValue("9");
          });

          it("deselects the select all checkbox", function () {
            expect($selectAll).not.toBeChecked();
          });
        });
      });
    });

    describe("manually selecting checkboxes one-by-one", function () {
      describe("3 items", function () {
        beforeEach(function () {
          [6, 3, 2].forEach(function (index) {
            $checkboxes.eq(index).click();
          });
        });

        it("shows 3 in the batch size input", function () {
          expect($batchInput).toHaveValue("3");
        });

        it("leaves the select all unchecked", function () {
          expect($selectAll).not.toBeChecked();
        });
      });

      describe("all 10 items", function () {
        beforeEach(function () {
          $checkboxes.each(function () {
            $(this).click();
          });
        });

        it("shows 10 in the batch size input", function () {
          expect($batchInput).toHaveValue("10");
        });

        it("checkes the select all box", function () {
          expect($selectAll).toBeChecked();
        });
      });
    });

    describe("clicking the select all checkbox", function () {
      describe("with nothing already selected", function () {
        beforeEach(function () {
          $selectAll.click();
        });

        it("shows 10 in the batch size input", function () {
          expect($batchInput).toHaveValue("10");
        });

        it("selects all the checkboxes", function () {
          $checkboxes.each(function () {
            expect(this).toBeChecked();
          });
        });
      });

      describe("with 2 items already selected", function () {
        beforeEach(function () {
          $checkboxes.slice(2).each(function () {
            $(this).click();
          });

          $selectAll.click();
        });

        it("shows 10 in the batch size input", function () {
          expect($batchInput).toHaveValue("10");
        });

        it("selects all the checkboxes", function () {
          $checkboxes.each(function () {
            expect(this).toBeChecked();
          });
        });
      });

      describe("with all 10 items already selected", function () {
        beforeEach(function () {
          $checkboxes.each(function () {
            $(this).click();
          });

          $selectAll.click();
        });

        it("shows 0 in the batch size input", function () {
          expect($batchInput).toHaveValue("0");
        });

        it("deselects all of the checkboxes", function () {
          $checkboxes.each(function () {
            expect(this).not.toBeChecked();
          });
        });
      });

      describe("with more than 10 items already selected", function () {
        beforeEach(function () {
          $batchInput.val(20).trigger("keyup");
          $selectAll.click();
        });

        it("shows 0 in the batch size input", function () {
          expect($batchInput).toHaveValue("0");
        });

        it("deselects all of the checkboxes", function () {
          $checkboxes.each(function () {
            expect(this).not.toBeChecked();
          });
        });
      });
    });
  });
});
