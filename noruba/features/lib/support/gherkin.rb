module GherkinWorld
  def feature(name, scenarios, keyword: 'Feature', language: nil)
    content = "#{keyword}: #{name}\n#{indent(scenarios.join("\n"))}"

    language.nil? ? content : "# language: #{language}\n#{content}"
  end

  def scenario(name, content, keyword: 'Scenario')
    "#{keyword}: #{name}\n#{indent(content)}"
  end

  def indent(content, indent: '  ')
    content.split("\n").map { |line| "#{indent}#{line}" }.join("\n")
  end
end

World(GherkinWorld)
