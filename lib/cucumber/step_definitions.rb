require 'json'
module Cucumber
  class StepDefinitions
    def initialize(configuration = Configuration.default)
      configuration = Configuration.parse(configuration)
      @support_code = Runtime::SupportCode.new(nil, false)
      @support_code.load_files_from_paths(configuration.autoload_code_paths)
    end
    
    def to_json
      @support_code.step_definitions.map do |step_definition|
        step_definition.regexp_source
      end.to_json
    end
  end
end