require 'spec_helper'

module Cucumber
  describe Configuration do
    describe ".default" do
      subject { Configuration.default }

      it "has an autoload_code_paths containing the standard support and step_definitions folders" do
        expect(subject.autoload_code_paths).to include('features/support')
        expect(subject.autoload_code_paths).to include('features/step_definitions')
      end
    end

    describe "with custom user options" do
      let(:user_options) { { :autoload_code_paths => ['foo/bar/baz'] } }
      subject { Configuration.new(user_options) }

      it "allows you to override the defaults" do
        expect(subject.autoload_code_paths).to eq ['foo/bar/baz']
      end
    end
  end
end
