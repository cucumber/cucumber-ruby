# frozen_string_literal: true

module JSONWorld
  def normalise_json(json)
    json.each do |feature|
      elements = feature.fetch('elements') { [] }
      elements.each do |scenario|
        normalise_scenario_json(scenario)
      end
    end
  end

  private

  def normalise_scenario_json(scenario)
    scenario['steps']&.each do
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

  # make sure duration was captured (should be >= 0)
  # then set it to what is "expected" since duration is dynamic
  def normalise_json_step_or_hook(step_or_hook)
    update_json_step_or_hook_error_message(step_or_hook) if step_or_hook['result']['error_message']

    return unless step_or_hook['result'] && step_or_hook['result']['duration']

    raise 'Duration should always be positive' unless step_or_hook['result']['duration'].positive?

    step_or_hook['result']['duration'] = 1
  end

  def update_json_step_or_hook_error_message(step_or_hook)
    step_or_hook['result']['error_message'] =
      step_or_hook['result']['error_message'].split("\n").reject { |line| line.include?(CUCUMBER_FEATURES_PATH) }.join("\n")
  end
end

World(JSONWorld)
