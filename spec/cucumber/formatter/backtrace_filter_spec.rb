require 'cucumber/formatter/backtrace_filter'
require 'tmpdir'

module Cucumber
  module Formatter
    describe BacktraceFilter, :isolated_home => true do
      context '#exception' do
        before do
          trace = %w(a b
                     _anything__/vendor/rails__anything_
                     _anything__lib/cucumber__anything_
                     _anything__bin/cucumber:__anything_
                     _anything__lib/rspec__anything_
                     _anything__gems/__anything_
                     _anything__minitest__anything_
                     _anything__test/unit__anything_
                     _anything__Xgem/ruby__anything_
                     _anything__lib/ruby/__anything_
                     _anything__.rbenv/versions/2.3/bin/bundle__anything_)
          @exception = Exception.new
          @exception.set_backtrace(trace)
        end

        it 'filters unnecessary traces' do
          BacktraceFilter.new(@exception).exception
          expect(@exception.backtrace).to eql %w(a b)
        end

        context 'when backtrace contains absolute paths starting with current directory' do
          let(:current_dir) { Dir.mktmpdir }
          around(:example) do |example|
            original_dir = Dir.pwd
            begin
              FileUtils.cd current_dir
              example.call
            ensure
              FileUtils.cd original_dir
              FileUtils.rm_rf current_dir
            end
          end

          it 'replaces current directory with ./' do
            exception = Exception.new
            exception.set_backtrace(["#{current_dir}/app/some.rb"])
            BacktraceFilter.new(exception).exception

            expect(exception.backtrace).to eql ['./app/some.rb']
          end

          it 'avoids replacing relative parts of path matching to current directory' do
            exception = Exception.new
            exception.set_backtrace(["./#{current_dir}/some.rb"])
            BacktraceFilter.new(exception).exception

            expect(exception.backtrace).to eql ["./#{current_dir}/some.rb"]
          end
        end
      end
    end
  end
end


