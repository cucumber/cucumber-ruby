module Cucumber #:nodoc:
  class VERSION #:nodoc:
    MAJOR = 0
    MINOR = 1
    TINY  = 13
    PATCH = 3 # Set to nil for official release

    STRING = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
  end
end
