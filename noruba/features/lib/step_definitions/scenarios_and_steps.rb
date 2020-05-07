def snake_case(name)
  name.downcase.gsub(/\W/, '_')
end

Given('the standard step definitions') do
  write_file(
    'features/step_definitions/steps.rb',
    [
      step_definition('/^this step passes$/', ''),
      step_definition('/^this step raises an error$/', "raise 'error'"),
      step_definition('/^this step is pending$/', 'pending'),
      step_definition('/^this step fails$/', 'fail'),
      step_definition('/^this step is a table step$/', '|t|')
    ].join("\n")
  )
end

Given('a scenario with a step that looks like this:') do |string|
  create_feature do
    create_scenario { string }
  end
end

Given('a scenario with a step that looks like this in japanese:') do |string|
  create_feature_ja do
    create_scenario_ja { string }
  end
end

Given('a scenario {string} that passes') do |name|
  create_feature(name) do
    create_scenario(name) do
      '  Given it passes'
    end
  end

  write_file(
    "features/step_definitions/#{name}_steps.rb",
    step_definition('/^it passes$/', 'expect(true).to be true')
  )
end

Given('a scenario {string} that fails') do |name|
  create_feature(name) do
    create_scenario(name) do
      '  Given it fails'
    end
  end

  write_file(
    "features/step_definitions/#{name}_steps.rb",
    step_definition('/^it fails$/', 'expect(false).to be true')
  )
end


Given('a scenario {string} that fails once, then passes') do |full_name|
  name = snake_case(full_name)

  create_feature("#{full_name} feature") do
    create_scenario(full_name) do
      '  Given it fails once, then passes'
    end
  end

  write_file(
    "features/step_definitions/#{name}_steps.rb",
    step_definition(
      '/^it fails once, then passes$/',
      [
        "$#{name} += 1",
        "expect($#{name}).to be > 1"
      ]
    )
  )

  write_file(
    "features/support/#{name}_init.rb",
    "  $#{name} = 0"
  )
end

Given('a scenario {string} that fails twice, then passes') do |full_name|
  name = snake_case(full_name)

  create_feature("#{full_name} feature") do
    create_scenario(full_name) do
      '  Given it fails twice, then passes'
    end
  end

  write_file(
    "features/step_definitions/#{name}_steps.rb",
    step_definition(
      '/^it fails twice, then passes$/',
      [
        "$#{name} ||= 0",
        "$#{name} += 1",
        "expect($#{name}).to be > 2"
      ]
    )
  )

  write_file(
    "features/support/#{name}_init.rb",
    "  $#{name} = 0"
  )
end

Given('a step definition that looks like this:') do |content|
  write_file("features/step_definitions/steps#{SecureRandom.uuid}.rb", content)
end
