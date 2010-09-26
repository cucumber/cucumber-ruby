require 'spec_helper'

module Cucumber
  describe Configuration do
    describe ".default" do
      subject { Configuration.default }
      
      it "has an autoload_code_paths containing the standard support and step_definitions folders" do
        subject.autoload_code_paths.should include('features/support')
        subject.autoload_code_paths.should include('features/step_definitions')
      end
    end
  end
end