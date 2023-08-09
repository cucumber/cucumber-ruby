# frozen_string_literal: true

module StepDefinitionsWorld
  def step_definition(expression, content, keyword: 'Given')
    if content.is_a?(String)
      one_line_step_definition(keyword, expression, content)
    else
      block_step_definition(keyword, expression, content)
    end
  end

  def one_line_step_definition(keyword, expression, content)
    "#{keyword}(#{expression}) { #{content} }"
  end

  def block_step_definition(keyword, expression, content)
    indented_content = content
                       .map { |line| "  #{line}" }
                       .join("\n")

    "#{keyword}(#{expression}) do\n#{indented_content}\nend"
  end
end

World(StepDefinitionsWorld)
