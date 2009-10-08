module Cucumber #:nodoc:
  class VERSION #:nodoc:
    MAJOR = 0
    MINOR = 4
    TINY  = 0
    PATCH = 'rc1' # Set to nil for official release

    STRING = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
  end
end
