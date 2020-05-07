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
    capture_stream(STDOUT, @stdout)
    capture_stream(STDERR, @stderr)

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
  # rubocop:disable Lint/HandleExceptions
  rescue RuntimeError
    # no-op: this is raised when Cucumber fails
  rescue SystemExit
    # No-op: well, we are supposed to exit the rake task
  rescue StandardError
    @kernel.exit(1)
  end
  # rubocop:enable Lint/HandleExceptions
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
  # rubocop:disable Lint/HandleExceptions
  rescue RuntimeError
    # no-op: this is raised when Cucumber fails
  rescue SystemExit
    # No-op: well, we are supposed to exit the rake task
  end
  # rubocop:enable Lint/HandleExceptions
end

module CLIWorld
  def execute_cucumber(args)
    @command_line = CucumberCommand.new
    @command_line.execute(args)
  end

  def execute_ruby(filename)
    @command_line = RubyCommand.new
    @command_line.execute("#{Dir.pwd}/#{filename}")
  end

  def execute_rake(task)
    @command_line = RakeCommand.new
    @command_line.execute(task)
  end

  def command_line
    @command_line
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
