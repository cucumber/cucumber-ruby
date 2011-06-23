# Why: http://groups.google.com/group/cukes/browse_thread/thread/5682d41436e235d7
begin
  require 'minitest/unit'
  # Don't attempt to monkeypatch if the require succeeded but didn't
  # define the actual module.
  #
  # https://github.com/cucumber/cucumber/pull/93
  # http://youtrack.jetbrains.net/issue/TW-17414
  if defined?(MiniTest::Unit)
    class MiniTest::Unit
      class << self
        @@installed_at_exit = true
      end

      def run(*)
        0
      end
    end
  end
rescue LoadError => ignore
end

# Do the same for Test::Unit
begin
  require 'test/unit'  
  # Don't attempt to monkeypatch if the require succeeded but didn't
  # define the actual module.
  #
  # https://github.com/cucumber/cucumber/pull/93
  # http://youtrack.jetbrains.net/issue/TW-17414
  if defined?(Test::Unit)
    module Test::Unit
      def self.run?
        true
      end
    end
  end
rescue LoadError => ignore
end
