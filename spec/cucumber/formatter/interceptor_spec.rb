# frozen_string_literal: true

require 'spec_helper'
require 'cucumber/formatter/interceptor'

module Cucumber::Formatter
  describe Interceptor::Pipe do
    let(:pipe) { instance_spy(IO) }

    describe '#wrap!' do
      it 'raises an ArgumentError if its not passed :stderr/:stdout' do
        expect { Interceptor::Pipe.wrap(:nonsense) }.to raise_error(ArgumentError)
      end

      context 'when passed :stderr' do
        before :each do
          @stderr = $stderr
        end

        it 'wraps $stderr' do
          wrapped = Interceptor::Pipe.wrap(:stderr)

          expect($stderr).to be_instance_of Interceptor::Pipe
          expect($stderr).to be wrapped
        end

        after :each do
          $stderr = @stderr
        end
      end

      context 'when passed :stdout' do
        before :each do
          @stdout = $stdout
        end

        it 'wraps $stdout' do
          wrapped = Interceptor::Pipe.wrap(:stdout)

          expect($stdout).to be_instance_of Interceptor::Pipe
          expect($stdout).to be wrapped
        end

        after :each do
          $stdout = @stdout
        end
      end
    end

    describe '#unwrap!' do
      before :each do
        @stdout = $stdout
        $stdout = pipe
        @wrapped = Interceptor::Pipe.wrap(:stdout)
      end

      it 'raises an ArgumentError if it wasn\'t passed :stderr/:stdout' do
        expect { Interceptor::Pipe.unwrap!(:nonsense) }.to raise_error(ArgumentError)
      end

      it 'resets $stdout when #unwrap! is called' do
        interceptor = Interceptor::Pipe.unwrap! :stdout

        expect(interceptor).to be_instance_of Interceptor::Pipe
        expect($stdout).not_to be interceptor
      end

      it 'noops if $stdout or $stderr has been overwritten' do
        $stdout = StringIO.new
        pipe = Interceptor::Pipe.unwrap! :stdout
        expect(pipe).to eq $stdout

        $stderr = StringIO.new
        pipe = Interceptor::Pipe.unwrap! :stderr
        expect(pipe).to eq $stderr
      end

      it 'disables the pipe bypass' do
        buffer = '(::)'
        Interceptor::Pipe.unwrap! :stdout

        @wrapped.write(buffer)

        expect(@wrapped.buffer_string).not_to end_with(buffer)
      end

      after :each do
        $stdout = @stdout
      end
    end

    describe '#write' do
      let(:buffer) { 'Some stupid buffer' }
      let(:pi) { Interceptor::Pipe.new(pipe) }

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
      let(:pi) { Interceptor::Pipe.new(pipe) }

      it 'passes #tty? to the original pipe' do
        expect(pipe).to receive(:tty?) { true }
        expect(pi.tty?).to be true
      end
    end

    describe '#respond_to' do
      let(:pi) { Interceptor::Pipe.wrap(:stderr) }

      it 'responds to all methods $stderr has' do
        $stderr.methods.each { |m| expect(pi.respond_to?(m)).to be true }
      end
    end
  end
end
