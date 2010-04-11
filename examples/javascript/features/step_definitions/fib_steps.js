var registerStepDefinition = function(regexp, func) {
  var argumentsFrom = function(stepName, stepDefinition) {
    var match = regexp.exec(stepName);
    if(match) {
      var arguments = Array();
      var s = match[0];
      for(i = 1; i < match.length; i++) {
        var arg = match[i];
        var charOffset = s.indexOf(arg, charOffset);

        //arguments.add(new StepArgument(arg, charOffset, stepName));
      }

      stepDefinition.addArguments(arguments);
    }
  };
  jsLanguage.addStepDefinition(this, argumentsFrom, regexp, func);
};

var Given = registerStepDefinition;
var When = registerStepDefinition;
var Then = registerStepDefinition;

When(/^I ask Javascript to calculate fibonacci up to (\d+)$/, function(n){
  fib_result = fibonacci(n);
});

Then(/^it should give me (\[.*\])$/, function(n){
  fib_result == fibonacci(n);
});
