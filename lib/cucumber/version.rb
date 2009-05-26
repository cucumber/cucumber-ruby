module Cucumber #:nodoc:
  class VERSION #:nodoc:
    MAJOR = 0
    MINOR = 3
    TINY  = 7
    PATCH = 5 # Set to nil for official release

    STRING = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
    STABLE_STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
