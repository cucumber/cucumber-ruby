fibonacci = function(n){
	return Math.round(Math.pow((Math.sqrt(5) + 1) / 2, Math.abs(n)) / Math.sqrt(5)) * (n < 0 && n % 2 ? -1 : 1);
};

var fib_result;

When(/^I ask Javascript to calculate fibonacci up to (\d+)$/, function(n){
  fib_result = fibonacci(n);
});

Then(/^it should give me (\[.*\])$/, function(n){
  expected_result = fibonacci(n)
  if(fib_result != expected_result){
    throw fib_result + " is not equal to " + expected_result;
  }
});
