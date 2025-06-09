# frozen_string_literal: true

require 'cucumber/formatter/backtrace_filter'

describe Cucumber::Formatter::BacktraceFilter do
  let(:exception_klass) do
    Class.new(Exception) do
      def _trace
        static_trace + dynamic_trace + realistic_trace
      end

      private

      def static_trace
        %w[
          a
          b
          _anything__/vendor/rails__anything_
          _anything__lib/cucumber__anything_
          _anything__bin/cucumber:__anything_
          _anything__lib/rspec__anything_
          _anything__gems/__anything_
          _anything__minitest__anything_
          _anything__test/unit__anything_
          _anything__Xgem/ruby__anything_
          _anything__.rbenv/versions/2.3/bin/bundle__anything_
        ]
      end

      def dynamic_trace
        [].tap do |paths|
          paths << "_anything__#{RbConfig::CONFIG['rubyarchdir']}__anything_" if RbConfig::CONFIG['rubyarchdir']
          paths << "_anything__#{RbConfig::CONFIG['rubylibdir']}__anything_" if RbConfig::CONFIG['rubylibdir']
        end
      end

      def realistic_trace
        ["./vendor/bundle/ruby/3.4.0/gems/cucumber-9.2.1/lib/cucumber/glue/invoke_in_world.rb:37:in 'BasicObject#instance_exec'"]
      end
    end
  end

  describe '#exception' do
    before do
      @exception = exception_klass.new
      @exception.set_backtrace(@exception._trace)
    end

    it 'filters unnecessary traces' do
      described_class.new(@exception).exception

      expect(@exception.backtrace).to eq(%w[a b])
    end
  end
end
