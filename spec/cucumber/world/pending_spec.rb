require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module World
    describe Pending do

      before(:each) do
        @world = Object.new
        @world.extend(World::Pending)
      end

      it 'should raise a ForcedPending if no block is supplied' do
        lambda {
          @world.pending "TODO"
        }.should raise_error(ForcedPending, /TODO/)
      end

      it 'should raise a ForcedPending if a supplied block fails as expected' do
        lambda {
          @world.pending "TODO" do
            raise "oops"
          end
        }.should raise_error(ForcedPending, /TODO/)
      end

      it 'should raise a ForcedPending if a supplied block fails as expected with a mock' do
        lambda {
          @world.pending "TODO" do
            m = mock('thing')
            m.should_receive(:foo)
            m.rspec_verify
          end
        }.should raise_error(ForcedPending, /TODO/)
      end

      it 'should raise a ForcedPending if a supplied block starts working' do
        lambda {
          @world.pending "TODO" do
            # success!
          end
        }.should raise_error(ForcedPending, /TODO/)
      end

    end
  end
end
