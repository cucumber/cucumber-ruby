
module Cucumber
  class Suite

    attr_accessor :filters
    attr_accessor :world_modules

    def initialize()
      @filters = []
      @world_modules = []
    end

  end
end
