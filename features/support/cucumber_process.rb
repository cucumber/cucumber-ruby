require 'shellwords'
require 'stringio'
require 'cucumber/rspec/disable_option_parser'
require 'cucumber/cli/main'

class CucumberProcess
  include Shellwords

  class FakeKernel
    attr_reader :exitstatus
    
    def initialize
      @exitstatus = 0
    end
    
    def exit(exitstatus)
      @exitstatus = exitstatus
    end
  end

  def initialize(cmd, exit_timeout, io_wait)
    args = shellwords(cmd)
    @argv = args[1..-1]
    @stdout = StringIO.new
    @stderr = StringIO.new
    @kernel = FakeKernel.new
  end

  def run!(&block)
    Cucumber::Cli::Main.new(@argv, @stdout, @stderr, @kernel).execute!
    yield self if block_given?
  end

  def stop(reader)
    @kernel.exitstatus
  end

  def stdout
    @stdout.string
  end

  def stderr
    @stderr.string
  end
end
