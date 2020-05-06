module JSONWorld
  def normalise_json(json)
    # make sure duration was captured (should be >= 0)
    # then set it to what is "expected" since duration is dynamic
    json.each do |feature|
      elements = feature.fetch('elements') { [] }
      elements.each do |scenario|
        scenario['steps'].each do |_step|
          %w[steps before after].each do |type|
            next unless scenario[type]
            scenario[type].each do |step_or_hook|
              normalise_json_step_or_hook(step_or_hook)
              next unless step_or_hook['after']
              step_or_hook['after'].each do |hook|
                normalise_json_step_or_hook(hook)
              end
            end
          end
        end
      end
    end
  end

  def normalise_json_step_or_hook(step_or_hook)
    if step_or_hook['result']['error_message']
      step_or_hook['result']['error_message'] = step_or_hook['result']['error_message']
                                                .split("\n")
                                                .reject { |line| line.include?(NORUBA_PATH) }
                                                .join("\n")
    end

    return unless step_or_hook['result'] && step_or_hook['result']['duration']
    expect(step_or_hook['result']['duration']).to be >= 0
    step_or_hook['result']['duration'] = 1
  end
end

World(JSONWorld)
