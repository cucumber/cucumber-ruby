# frozen_string_literal: true

require 'cucumber/formatter/backtrace_filter'

module Cucumber
  module Formatter
    describe BacktraceFilter do
      describe '#exception' do
        before do
          trace = %w[a b
                     _anything__/vendor/rails__anything_
                     _anything__lib/cucumber__anything_
                     _anything__bin/cucumber:__anything_
                     _anything__lib/rspec__anything_
                     _anything__gems/__anything_
                     _anything__minitest__anything_
                     _anything__test/unit__anything_
                     _anything__Xgem/ruby__anything_
                     _anything__.rbenv/versions/2.3/bin/bundle__anything_]
          trace << "_anything__#{RbConfig::CONFIG['rubyarchdir']}__anything_" if RbConfig::CONFIG['rubyarchdir']
          trace << "_anything__#{RbConfig::CONFIG['rubylibdir']}__anything_" if RbConfig::CONFIG['rubylibdir']

          @exception = Exception.new
          @exception.set_backtrace(trace)
        end

        it 'filters unnecessary traces' do
          described_class.new(@exception).exception
          expect(@exception.backtrace).to eql %w[a b]
        end
      end
    end
  end
end
