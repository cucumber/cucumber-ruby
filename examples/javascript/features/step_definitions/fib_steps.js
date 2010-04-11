function fibanacci(n){
  return n<2?n:fibanacci(n-1)+fibanacci(n-2);
}

var fibonacciSeries = function(topFibonacci) {
  var result = Array();
  var currentFibanacciValue = fibanacci(1);
  var i = 2;
  while(currentFibanacciValue < topFibonacci) {
    result.push(currentFibanacciValue);
    currentFibanacciValue  = fibanacci(i);
    i++;
  }
  return result;
}

var fib_result;

When(/^I ask Javascript to calculate fibonacci up to (\d+)$/, function(n){
  fib_result = fibonacciSeries(n);
});

Then(/^it should give me (\[.*\])$/, function(expected_result){
  fib_result = fib_result.join(",");
  if(fib_result != expected_result){
    throw 'Expected <' + expected_result + "> but got <" + fib_result + ">";
  }
});
