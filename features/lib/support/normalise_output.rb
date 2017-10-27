# frozen_string_literal: true
# override aruba to filter out some stuff
module NormaliseArubaOutput
  def all_stdout
    normalise_output(super)
  end

  def sanitize_text(text)
    normalise_output(super)
  end

  def normalise_output(out)
    out.gsub(/#{Dir.pwd}\/tmp\/aruba/, '.') # Remove absolute paths
       .gsub(/tmp\/aruba\//, '')            # Fix aruba path
       .gsub(/^.*cucumber_process\.rb.*$\n/, '')
       .gsub(/^\d+m\d+\.\d+s$/, '0m0.012s') # Make duration predictable
       .gsub(/Coverage report generated .+$\n/, '') # Remove SimpleCov message
  end

  def normalise_json(json)
    #make sure duration was captured (should be >= 0)
    #then set it to what is "expected" since duration is dynamic
    json.each do |feature|
      elements = feature.fetch('elements') { [] }
      elements.each do |scenario|
        scenario['steps'].each do |step|
          %w(steps before after).each do |type|
            if scenario[type]
              scenario[type].each do |step_or_hook|
                normalise_json_step_or_hook(step_or_hook)
                if step_or_hook['after']
                  step_or_hook['after'].each do |hook|
                    normalise_json_step_or_hook(hook)
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def normalise_json_step_or_hook(step_or_hook)
    return unless step_or_hook['result'] && step_or_hook['result']['duration']
    expect(step_or_hook['result']['duration']).to be >= 0
    step_or_hook['result']['duration'] = 1
  end

end

World(NormaliseArubaOutput)
