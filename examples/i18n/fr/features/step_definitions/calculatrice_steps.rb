Soit(/^une calculatrice$/) do
  @calc = Calculatrice.new
end

Etantdonnéqu('on tape {int}') do |entier|
  @calc.push entier
end

Soit("j'entre {int} pour le premier/second nombre") do |entier|
  @calc.push entier
end

Soit('je tape sur la touche {string}') do |_touche|
  @result = @calc.additionner
end

Lorsqu(/on tape additionner/) do
  @result = @calc.additionner
end

Alors('le résultat affiché doit être {float}') do |resultat_attendu|
  expect(@result).to eq(resultat_attendu)
end

Alors('le résultat doit être {float}') do |resultat_attendu|
  expect(@result).to eq(resultat_attendu)
end
