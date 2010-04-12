function fibonacci(n){
  return n<2?n:fibonacci(n-1)+fibonacci(n-2);
}

var fibonacciSeries = function(fibonacciLimit) {
  var result = Array();
  var currentfibonacciValue = fibonacci(1);
  var i = 2;
  while(currentfibonacciValue < fibonacciLimit) {
    result.push(currentfibonacciValue);
    currentfibonacciValue  = fibonacci(i);
    i++;
  }
  return "[" + result.join(", ") + "]";
}

var fibResult;

When(/^I ask Javascript to calculate fibonacci up to (\d+)$/, function(n){
  fibResult = fibonacciSeries(parseInt(n));
});

Then(/^it should give me (\[.*\])$/, function(expectedResult){
  if(fibResult != expectedResult){
    throw 'Expected <' + expectedResult + "> but got <" + fibResult + ">";
  }
});
