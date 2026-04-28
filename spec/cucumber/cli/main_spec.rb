# frozen_string_literal: true

require 'yaml'

RSpec.describe Cucumber::Cli::Main do
  subject { described_class.new(args, stdout, stderr, kernel) }

  let(:args)   { [] }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:kernel) { double(:kernel) }

  before(:each) do
    allow(File).to receive(:exist?).and_return(false) # When Configuration checks for cucumber.yml
    allow(Dir).to receive(:[]).and_return([]) # to prevent cucumber's features dir to being loaded
  end

  after do
    Cucumber.logger = nil
  end

  describe '#execute!' do
    context 'when passed an existing runtime' do
      let(:existing_runtime) { double('runtime').as_null_object }

      def do_execute
        subject.execute!(existing_runtime)
      end

      it 'configures that runtime' do
        expected_configuration = double('Configuration').as_null_object

        allow(Cucumber::Cli::Configuration).to receive(:new) { expected_configuration }
        expect(existing_runtime).to receive(:configure).with(expected_configuration)
        expect(kernel).to receive(:exit).with(1)

        do_execute
      end

      it 'uses that runtime for running and reporting results' do
        expected_results = double('results', failure?: true)

        expect(existing_runtime).to receive(:run!)
        allow(existing_runtime).to receive(:results) { expected_results }
        expect(kernel).to receive(:exit).with(1)

        do_execute
      end
    end

    context 'when interrupted with ctrl-c' do
      after do
        Cucumber.wants_to_quit = false
      end

      it 'exits with error code' do
        results = double('results', failure?: false)

        allow_any_instance_of(Cucumber::Runtime).to receive(:run!)
        allow_any_instance_of(Cucumber::Runtime).to receive(:results) { results }

        Cucumber.wants_to_quit = true

        expect(kernel).to receive(:exit).with(2)

        subject.execute!
      end
    end

    thread_dump_signal = %w[INFO PWR].find { |s| Signal.list.key?(s) }

    context 'when interrupted with thread dump signal', skip: thread_dump_signal.nil? do
      let(:runtime) { double('runtime').as_null_object }

      it 'dumps the thread backtrace to the error stream' do
        kill_line = 0

        allow(runtime).to receive(:run!) do
          Process.kill(thread_dump_signal, Process.pid)
          kill_line = __LINE__ - 1
        end

        allow(runtime).to receive(:failure?).and_return(false)

        expect(kernel).to receive(:exit).with(0)

        subject.execute!(runtime)

        tid = (Thread.current.object_id ^ Process.pid).to_s(36)

        if defined?(JRUBY_VERSION)
          pattern = /Thread TID-[0-9a-z]+ SIGPWR handler /

          # JRuby runs signal handlers asynchronously on a dedicated thread
          deadline = Time.now + 2
          sleep 0.01 while stderr.string !~ pattern && Time.now < deadline

          expect(stderr.string).to match(pattern)
        elsif defined?(TruffleRuby)
          # TruffleRuby does not dump the actual Process.kill call, but rather the internal core/thread.rb call
          expect(stderr.string).to match(/Thread TID-#{tid} <no name> <internal:core> core\/thread.rb:/)
        else
          pattern = RUBY_VERSION >= '3.4' ? /'Process\.kill'/ : /`kill'/
          expect(stderr.string).to match(/Thread TID-#{tid} <no name> #{__FILE__}:#{kill_line}:in #{pattern}/)
        end
      end
    end
  end

  [Cucumber::Cli::ProfilesNotDefinedError, Cucumber::Cli::YmlLoadError, Cucumber::Cli::ProfileNotFound].each do |exception_klass|
    it "rescues #{exception_klass}, prints the message to the error stream" do
      configuration = double('configuration')

      allow(Cucumber::Cli::Configuration).to receive(:new) { configuration }
      allow(configuration).to receive(:parse!).and_raise(exception_klass.new('error message'))
      allow(kernel).to receive(:exit).with(2)

      subject.execute!

      expect(stderr.string).to eq "error message\n"
    end
  end
end
