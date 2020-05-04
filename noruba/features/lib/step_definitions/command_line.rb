require 'rspec/mocks'

class MockKernel
  attr_reader :exit_status

  def exit(status)
    @exit_status  = status
  end
end

class CommandLine
  def initialize()
    @stdout = StringIO.new
    @stderr = StringIO.new
    @kernel = MockKernel.new
  end

  def stderr
    @stderr.string
  end

  def stdout
    @stdout.string
  end

  def all_output
    [stdout, stderr].reject(&:empty?).join("\n")
  end

  def exit_status
    @kernel.exit_status
  end
end

class CucumberCommand < CommandLine
  attr_reader :args

  def execute(args)
    @args = args
    argument_list = make_arg_list(args)

    Cucumber::Cli::Main.new(
      argument_list,
      nil,
      @stdout,
      @stderr,
      @kernel
    ).execute!
  end

  private

  def make_arg_list(args)
    index = -1
    args.split(/'|"/).map do |chunk|
      index += 1
      index % 2 == 0 ? chunk.split(' ') : chunk
    end.flatten
  end
end

class RubyCommand < CommandLine
  def execute(file)
    require file
  end

  def puts(*msg)
    @stdout.puts(*msg)
  end

  def exit_status
    @exit_status || 0
  end
end
