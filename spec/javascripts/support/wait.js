/**
 * Test helper for waiting for a certain condition.
 * @param conditionFunction a function that accepts no argument, and
 * returns an object:
 * {
 *   shouldResolve: truthy if the promise should resolve
 *   result: the value for the promise to resolve
 * }
 * @param errorMessage (optional) the message to show if the wait times
 * out before the condition is met
 * @returns {Promise} which will resolve the value returned by
 * conditionFunction().result
 */
function wait(conditionFunction, errorMessage) {
  var CHECK_PERIOD_MILLISECONDS = 100;
  var MAX_WAIT_MILLISECONDS = 5000;

  var promise = $.Deferred();

  var totalElapsedMilliseconds = 0;
  function checkCondition() {
    if (totalElapsedMilliseconds > MAX_WAIT_MILLISECONDS) {
      promise.reject(errorMessage || "Timed out");
    }

    var condition = conditionFunction();

    if (condition.shouldResolve || condition === true) {
      promise.resolve(condition.result);
    } else {
      totalElapsedMilliseconds += CHECK_PERIOD_MILLISECONDS;
      setTimeout(checkCondition, CHECK_PERIOD_MILLISECONDS);
    }
  }

  checkCondition();

  return promise;
}

/**
 * Waits for the presence of an element within $context, selected by selector.
 * @param context the DOM node under which to search
 * @param selector the CSS selector to be found
 * @returns {Promise} resolves the elements when found
 */
function waitForElements(context, selector) {
  return wait(
    function() {
      var $elements = $(context).find(selector);
      return {
        shouldResolve: !!$elements.length,
        result: $elements
      };
    },
    "Could not find element with selector '" + selector + "'"
  );
}
