module Cucumber
  class Query
    attr_reader :repository
    private :repository

    def initialize(repository)
      @repository = repository
    end

    def find_all_pickles
      repository.values
    end
  end
end
