require 'cucumber/ast/step_invocation'

module Cucumber
  module Ast
    describe StepInvocation do
      let(:step_invocation) do
        matched_cells = []
        StepInvocation.new(stub, stub, stub, matched_cells)
      end

      describe "filtering backtraces" do
        context "when disabled" do
          before { Cucumber.stub use_full_backtrace: true }

          it "return the exception unmodified" do
            exception = stub
            step_invocation.filter_backtrace(exception).should == exception
           end
        end

        context "when enabled" do
          before { Cucumber.stub use_full_backtrace: false }

          it "removes lines with 'gems/' in the path" do
            original_backtrace = ['/foo/bar/gems/baz', '/path/to/my/file.rb']
            exception = StandardError.new
            exception.set_backtrace(original_backtrace)
            result = step_invocation.filter_backtrace(exception).backtrace
            result.should == ['/path/to/my/file.rb']
          end

          it "removes lines with '.gem' in the path" do
            original_backtrace = ['/foo/bar/.gem/baz', '/path/to/my/file.rb']
            exception = StandardError.new
            exception.set_backtrace(original_backtrace)
            result = step_invocation.filter_backtrace(exception).backtrace
            result.should == ['/path/to/my/file.rb']
          end
        end

      end
    end
  end
end

