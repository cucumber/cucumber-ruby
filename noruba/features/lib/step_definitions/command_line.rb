require 'rspec/mocks'
require 'rake'
require 'cucumber/rake/task'

class MockKernel
  attr_reader :exit_status

  def exit(status)
    @exit_status  = status
  end
end

class CommandLine
  include ::RSpec::Mocks::ExampleMethods

  def initialize()
    ::RSpec::Mocks.setup

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
    @kernel.exit_status || 0
  end

  def capture_stdout
    old_stdout = $stdout
    $stdout = @stdout
    old_stderr = $stderr
    $stderr = @stderr
    yield
  ensure
    $stdout = old_stdout
    $stderr = old_stderr
  end

  def destroy_mocks
    ::RSpec::Mocks.verify
  ensure
    ::RSpec::Mocks.teardown
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
    capture_stdout { require file }
  rescue
    @kernel.exit(1)
  end
end

class RakeCommand < CommandLine
  def execute task
    allow_any_instance_of(Cucumber::Rake::Task)
      .to receive(:fork)
      .and_return(false)

    allow(Cucumber::Cli::Main)
      .to receive(:execute)
      .and_wrap_original do |m, *args|
        Cucumber::Cli::Main.new(
          args[0],
          nil,
          @stdout,
          @stderr,
          @kernel
        ).execute!
      end

    Rake.application.load_rakefile()
    Rake.application[task.strip].invoke
  rescue RuntimeError => err
    # no-op: this is raissed when Cucumber fails
  rescue SystemExit => err
    # No-op: well, we are ssupposed to exit the rake task
  end
end