require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module StepMother
    describe 'Pending' do

      before(:each) do
        @step_mom = Object.new
        @step_mom.extend(StepMother)
        @world = @step_mom.__send__(:new_world!)
      end

      it 'should raise a Pending if no block is supplied' do
        lambda {
          @world.pending "TODO"
        }.should raise_error(Pending, /TODO/)
      end

      it 'should raise a Pending if a supplied block fails as expected' do
        lambda {
          @world.pending "TODO" do
            raise "oops"
          end
        }.should raise_error(Pending, /TODO/)
      end

      it 'should raise a Pending if a supplied block fails as expected with a mock' do
        lambda {
          @world.pending "TODO" do
            m = mock('thing')
            m.should_receive(:foo)
            m.rspec_verify
          end
        }.should raise_error(Pending, /TODO/)
      end

      it 'should raise a Pending if a supplied block starts working' do
        lambda {
          @world.pending "TODO" do
            # success!
          end
        }.should raise_error(Pending, /TODO/)
      end

    end
  end
end
