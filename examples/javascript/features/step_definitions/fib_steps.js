fibonacci = function(n){
	return Math.round(Math.pow((Math.sqrt(5) + 1) / 2, Math.abs(n)) / Math.sqrt(5)) * (n < 0 && n % 2 ? -1 : 1);
};

var fib_result = null;

When(/^I ask Javascript to calculate fibonacci up to (\d+)$/, function(n){
  fib_result = fibonacci(n);
});

Then(/^it should give me (\[.*\])$/, function(n){
  if(fib_result == fibonacci(n)){
    return fib_result + "==" + fibonacci(n)
  }
  else{
    return fib_result + "!=" + fibonacci(n)
  }
});
