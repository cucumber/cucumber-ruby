module Cucumber #:nodoc:
  class VERSION #:nodoc:
    MAJOR = 0
    MINOR = 3
    TINY  = 96
    PATCH = nil # Set to nil for official release

    STRING = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
  end
end
