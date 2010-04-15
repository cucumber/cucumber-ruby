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

function assertEqual(expected, actual){
  if(expected != actual){
    throw 'Expected <' + expected + "> but got <" + actual + ">";
  }
}

Before(function(n){
  fibResult = 0;
});

When(/^I ask Javascript to calculate fibonacci up to (\d+)$/, function(n){
  assertEqual(0, fibResult)
  fibResult = fibonacciSeries(parseInt(n));
});

Then(/^it should give me (\[.*\])$/, function(expectedResult){
  assertEqual(expectedResult, fibResult)
});

Then(/^it should give me:$/, function(string){
  assertEqual(string, fibResult);
});

Then(/^it should contain:$/, function(table){
  var cell_1 = table.hashes[0]['cell 1'];
  assertEqual(true, (fibResult.indexOf(cell_1) != -1));
});
