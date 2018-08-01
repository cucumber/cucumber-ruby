Soit(/^une calculatrice$/) do
  @calc = Calculatrice.new
end

Etantdonné(/^qu'on tape (.*)$/) do |n|
  @calc.push n.to_i
end

Etantdonné(/^que j'entre (\d+) pour le (.*) nombre/) do |n, _x|
  @calc.push n.to_i
end

Lorsque(/^je tape sur la touche "="$/) do
  @expected_result = @calc.additionner
end

Lorsqu(/on tape additionner/) do
  @expected_result = @calc.additionner
end

Alors(/le résultat affiché doit être (\d*)/) do |result|
  expect result.to_i == @expected_result
end

Alors(/le résultat doit être (\d*)/) do |result|
  expect result.to_i == @expected_result
end

Soit(/^que je tape sur la touche "\+"$/) do
  # noop
end
