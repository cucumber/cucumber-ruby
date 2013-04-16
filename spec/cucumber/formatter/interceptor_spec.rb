require 'spec_helper'
require 'cucumber/formatter/interceptor'

module Cucumber::Formatter
  describe Interceptor::Pipe do
    let(:pipe) do
      pipe = double('original pipe')
      pipe.stub(:instance_of?).and_return(true)
      pipe
    end

    describe '#wrap!' do
      it 'should raise an ArgumentError if its not passed :stderr/:stdout' do
        expect {
          Interceptor::Pipe.wrap(:nonsense)
        }.to raise_error(ArgumentError)

      end

      context 'when passed :stderr' do
        before :each do
          @stderr = $stdout
        end

        it 'should wrap $stderr' do
          wrapped = Interceptor::Pipe.wrap(:stderr)
          $stderr.should be_instance_of Interceptor::Pipe
          $stderr.should be wrapped
        end

        after :each do
          $stderr = @stderr
        end
      end

      context 'when passed :stdout' do
        before :each do
          @stdout = $stdout
        end

        it 'should wrap $stdout' do
          wrapped = Interceptor::Pipe.wrap(:stdout)
          $stdout.should be_instance_of Interceptor::Pipe
          $stdout.should be wrapped
        end

        after :each do
          $stdout = @stdout
        end
      end
    end

    describe '#unwrap!' do
      before :each do
        @stdout = $stdout
        @wrapped = Interceptor::Pipe.wrap(:stdout)
      end

      it 'should raise an ArgumentError if it wasn\'t passed :stderr/:stdout' do
        expect {
          Interceptor::Pipe.unwrap!(:nonsense)
        }.to raise_error(ArgumentError)
      end

      it 'should reset $stdout when #unwrap! is called' do
        interceptor = Interceptor::Pipe.unwrap! :stdout
        interceptor.should be_instance_of Interceptor::Pipe
        $stdout.should_not be interceptor
      end

      it 'should noop if $stdout or $stderr has been overwritten' do
        $stdout = StringIO.new
        pipe = Interceptor::Pipe.unwrap! :stdout
        pipe.should == $stdout

        $stderr = StringIO.new
        pipe = Interceptor::Pipe.unwrap! :stderr
        pipe.should == $stderr
      end

      it 'should disable the pipe bypass' do
        buffer = '(::)'
        Interceptor::Pipe.unwrap! :stdout

        @wrapped.should_receive(:write).with(buffer)
        @wrapped.buffer.should_not_receive(:<<)
        @wrapped.write(buffer)
      end

      after :each do
        $stdout = @stdout
      end
    end

    describe '#write' do
      let(:buffer) { 'Some stupid buffer' }
      let(:pi) { Interceptor::Pipe.new(pipe) }

      it 'should write arguments to the original pipe' do
        pipe.should_receive(:write).with(buffer).and_return(buffer.size)
        pi.write(buffer).should == buffer.size
      end

      it 'should add the buffer to its stored output' do
        pipe.stub(:write)
        pi.write(buffer)
        pi.buffer.should_not be_empty
        pi.buffer.first.should == buffer
      end
    end

    describe '#method_missing' do
      let(:pi) { Interceptor::Pipe.new(pipe) }

      it 'should pass #tty? to the original pipe' do
        pipe.should_receive(:tty?).and_return(true)
        pi.tty?.should be true
      end
    end

    describe '#respond_to' do
      let(:pi) { Interceptor::Pipe.wrap(:stderr) }

      it 'should respond to all methods $stderr has' do
        $stderr.methods.each { |m| pi.respond_to?(m).should be true }
      end
    end
  end
end
