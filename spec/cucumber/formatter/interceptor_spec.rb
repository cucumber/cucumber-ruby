# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/interceptor'

module Cucumber
  module Formatter
    describe Interceptor::Pipe do
      let(:pipe) { instance_spy(IO) }

      describe '#wrap!' do
        it 'raises an ArgumentError if its not passed :stderr/:stdout' do
          expect { described_class.wrap(:nonsense) }.to raise_error(ArgumentError)
        end

        context 'when passed :stderr' do
          before :each do
            @stderr = $stderr
          end

          after :each do
            $stderr = @stderr
          end

          it 'wraps $stderr' do
            wrapped = described_class.wrap(:stderr)

            expect($stderr).to be_instance_of described_class
            expect($stderr).to be wrapped
          end
        end

        context 'when passed :stdout' do
          before :each do
            @stdout = $stdout
          end

          after :each do
            $stdout = @stdout
          end

          it 'wraps $stdout' do
            wrapped = described_class.wrap(:stdout)

            expect($stdout).to be_instance_of described_class
            expect($stdout).to be wrapped
          end
        end
      end

      describe '#unwrap!' do
        before :each do
          @stdout = $stdout
          $stdout = pipe
          @wrapped = described_class.wrap(:stdout)
          @stderr = $stderr
        end

        after :each do
          $stdout = @stdout
          $stderr = @stderr
        end

        it "raises an ArgumentError if it wasn't passed :stderr/:stdout" do
          expect { described_class.unwrap!(:nonsense) }.to raise_error(ArgumentError)
        end

        it 'resets $stdout when #unwrap! is called' do
          interceptor = described_class.unwrap! :stdout

          expect(interceptor).to be_instance_of described_class
          expect($stdout).not_to be interceptor
        end

        it 'noops if $stdout or $stderr has been overwritten' do
          $stdout = StringIO.new
          pipe = described_class.unwrap! :stdout
          expect(pipe).to eq $stdout

          $stderr = StringIO.new
          pipe = described_class.unwrap! :stderr
          expect(pipe).to eq $stderr
        end

        it 'disables the pipe bypass' do
          buffer = '(::)'
          described_class.unwrap! :stdout

          @wrapped.write(buffer)

          expect(@wrapped.buffer_string).not_to end_with(buffer)
        end
      end

      describe '#write' do
        let(:buffer) { 'Some stupid buffer' }
        let(:pi) { described_class.new(pipe) }

        it 'writes arguments to the original pipe' do
          expect(pipe).to receive(:write).with(buffer) { buffer.size }
          expect(pi.write(buffer)).to eq buffer.size
        end

        it 'adds the buffer to its stored output' do
          expect(pipe).to receive(:write).with(buffer)

          pi.write(buffer)

          expect(pi.buffer_string).not_to be_empty
          expect(pi.buffer_string).to eq buffer
        end
      end

      describe '#method_missing' do
        let(:pi) { described_class.new(pipe) }

        it 'passes #tty? to the original pipe' do
          expect(pipe).to receive(:tty?).and_return(true)
          expect(pi.tty?).to be true
        end
      end

      describe '#respond_to' do
        let(:pi) { described_class.wrap(:stderr) }

        it 'responds to all methods $stderr has' do
          puts 'problematic methods'
          puts %w[pread pwrite nonblock? ioctl pathconf]
          true_methods, false_methods = $stderr.methods.partition { |m| pi.respond_to?(m) }
          puts "\n\n\nPASSING\n\n\n"
          puts true_methods
          puts "\n\n\nFAILING\n\n\n"
          puts false_methods

          $stderr.methods.each do |m|
            expect(pi.respond_to?(m)).to be true
          end
        end
      end

      describe 'when calling `methods` on the stream' do
        it 'does not raise errors' do
          allow($stderr).to receive(:puts)

          described_class.wrap(:stderr)
          expect { $stderr.puts('Oh, hi here !') }.not_to raise_exception(NoMethodError)
        end

        it 'does not shadow errors when method do not exist on the stream' do
          described_class.wrap(:stderr)
          expect { $stderr.not_really_puts('Oh, hi here !') }.to raise_exception(NoMethodError)
        end
      end
    end
  end
end
