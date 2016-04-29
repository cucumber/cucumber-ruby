require 'spec_helper'

module Cucumber
  describe Suite do
    def empty_suite
      Suite.new
    end
    module CustomWorld
    end
    it "has an array for filters" do
      expect(empty_suite.filters << "filter1").to eq(["filter1"])
    end

    it "has an array for world modules" do
      expect(empty_suite.world_modules << CustomWorld).to eq([CustomWorld])
    end
  end
end
