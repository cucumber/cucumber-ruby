Before(function(){
  fibResult = 0;
});

Before('@do-fibonnacci-in-before-hook', function(){
  fibResult = fibonacciSeries(3);
});

After(function(){
  //throw 'Sabotage scenario';
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
