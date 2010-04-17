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

function assertMatches(expected, actual){
  if(actual.indexOf(expected) == -1){
    throw 'Expected <' + expected + "> to contain <" + actual + "> but it did not";
  }
}

function assertNotEqual(expected, actual){
  if(expected == actual){
    throw 'Did not Expected <' + expected + "> but got <" + actual + ">";
  }
}

Before(function(){
  fibResult = 0;
});

After(function(){
  //throw 'Sabotage scenario'
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
  var hashes = table.hashes();
  assertMatches(hashes[0]['cell 1'], fibResult);
  assertMatches(hashes[0]['cell 2'], fibResult);
});
