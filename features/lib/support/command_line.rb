require 'rspec/expectations'
require 'rspec/mocks'
require 'rake'
require 'cucumber/rake/task'

class MockKernel
  attr_reader :exit_status

  def exit(status)
    @exit_status = status

    status unless status.zero?
  end
end

class CommandLine
  include ::RSpec::Mocks::ExampleMethods

  def initialize
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
    capture_stream($stdout, @stdout)
    capture_stream($stderr, @stderr)

    yield
  end

  def destroy_mocks
    # rubocop:disable Style/RedundantBegin
    # TODO: remove the begin/end block when we drop 2.3 uport and CI job.
    begin
      ::RSpec::Mocks.verify
    ensure
      ::RSpec::Mocks.teardown
    end
    # rubocop:enable Style/RedundantBegin
  end

  private

  def capture_stream(stream, redirect)
    allow(stream)
      .to receive(:puts)
      .and_wrap_original do |_, *args|
        redirect.puts(*args)
      end

    allow(stream)
      .to receive(:print)
      .and_wrap_original do |_, *args|
        redirect.print(*args)
      end

    allow(stream)
      .to receive(:flush)
      .and_wrap_original do |_, *args|
        redirect.flush(*args)
      end
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
      index.even? ? chunk.split(' ') : chunk
    end.flatten
  end
end

class RubyCommand < CommandLine
  def execute(file)
    capture_stdout { require file }
  rescue RuntimeError
    # no-op: this is raised when Cucumber fails
  rescue SystemExit
    # No-op: well, we are supposed to exit the rake task
  rescue StandardError
    @kernel.exit(1)
  end
end

class RakeCommand < CommandLine
  def execute(task)
    allow_any_instance_of(Cucumber::Rake::Task)
      .to receive(:fork)
      .and_return(false)

    allow(Cucumber::Cli::Main)
      .to receive(:execute)
      .and_wrap_original do |_, *args|
        Cucumber::Cli::Main.new(
          args[0],
          nil,
          @stdout,
          @stderr,
          @kernel
        ).execute!
      end

    Rake.with_application do |rake|
      rake.load_rakefile
      capture_stdout { rake[task.strip].invoke }
    end
  rescue RuntimeError
    # no-op: this is raised when Cucumber fails
  rescue SystemExit
    # No-op: well, we are supposed to exit the rake task
  end
end

module CLIWorld
  def execute_cucumber(args)
    execute_command(CucumberCommand, args)
  end

  def execute_extra_cucumber(args)
    execute_extra_command(CucumberCommand, args)
  end

  def execute_ruby(filename)
    execute_command(RubyCommand, "#{Dir.pwd}/#{filename}")
  end

  def execute_rake(task)
    execute_command(RakeCommand, task)
  end

  def execute_command(cls, args)
    @command_line = cls.new
    @command_line.execute(args)
  end

  def execute_extra_command(cls, args)
    @extra_commands = []
    @extra_commands << cls.new
    @extra_commands.last.execute(args)
  end

  def command_line
    @command_line
  end

  def last_extra_command
    @extra_commands&.last
  end
end

World(CLIWorld)

RSpec::Matchers.define :have_succeded do
  match do |cli|
    @actual = cli.exit_status
    @expected = '0 exit code'
    @actual.zero?
  end
end

RSpec::Matchers.define :have_failed do
  match do |cli|
    @actual = cli.exit_status
    @expected = 'non-0 exit code'
    @actual.positive?
  end
end

RSpec::Matchers.define :have_exited_with do |expected|
  match do |cli|
    @actual = cli.exit_status

    if expected.is_a?(ExecutionStatus)
      expected.validates?(@actual)
    else
      @actual == expected
    end
  end
end
