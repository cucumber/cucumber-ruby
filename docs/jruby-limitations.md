# Cucumber and JRuby limitations

`cucumber` can be executed on `JRuby` (tested with `9.2`), although some of the features
are not available on this platform.

## Defining steps with native languages

There are currently three languages (Russian, Ukrainian and Uzbek) for which the step definition
can not be written in native language.
That means, for example, that you can not write the following code:

```ruby
Допустим('я ввожу число {int}') do |число|
  calc.push число
end
```

Instead, you have to write:
```ruby
Given('я ввожу число {int}') do |number|
  calc.push number
end
```

Of course, you can still write your feature files in a native language, for example, the following
feature file can be executed on JRuby:

```gherkin
# language: ru
Функционал: Сложение чисел
  Чтобы не складывать в уме
  Все, у кого с этим туго
  Хотят автоматическое сложение целых чисел

  Сценарий: Сложение двух целых чисел
    Допустим я ввожу число 50
    И затем ввожу число 70
    Если я нажимаю "+"
    То результатом должно быть число 120
```
