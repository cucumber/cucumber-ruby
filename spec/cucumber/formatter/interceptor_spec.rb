require 'spec_helper'
require 'cucumber/formatter/interceptor'

module Cucumber::Formatter
  describe Interceptor::Pipe do
    let(:pipe) do
      pipe = double('original pipe')
      pipe.stub(:instance_of?).and_return(true)
      pipe
    end

    describe '#unwrap!' do
      before :each do
        $mockpipe = subject
      end

      subject do
        Interceptor::Pipe.new(pipe)
      end

      it 'should revert $mockpipe when #unwrap! is called' do
        $mockpipe.should_not be pipe
        $mockpipe = subject.unwrap!
        $mockpipe.should be pipe
      end

      it 'should disable the pipe bypass' do
        buffer = '(::)'
        subject.unwrap!

        pipe.should_receive(:write).with(buffer)
        subject.buffer.should_not_receive(:<<)
        subject.write(buffer)
      end

      after :each do
        $mockpipe = nil
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
  end
end
