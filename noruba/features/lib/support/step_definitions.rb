module StepDefinitionsWorld
  def step_definition(expression, content, keyword: 'Given')
    if content.include?("\n")
      block_step_definition(keyword, expression, content)
    else
      one_line_step_definition(keyword, expression, content)
    end
  end

  def one_line_step_definition(keyword, expression, content)
    "#{keyword}(#{expression}) { #{content} }"
  end

  def block_step_definition(keyword, expression, content)
    indented_content = content
                       .split("\n")
                       .map { |line| "  #{line}" }
                       .join("\n")

    "#{keyword}(#{expression}) do\n#{indented_content}\nend"
  end
end

World(StepDefinitionsWorld)
