require 'cucumber/events/bus'

describe Cucumber::Events::Bus do
  subject(:bus) { described_class.new(name_resolver) }

  let(:name_resolver) { instance_double('Cucumber::Events::NameResolver') }

  let!(:test_event_klass) do
    class_double('Events::TestEvent').tap do |double|
      stub_const('Events::TestEvent', double)
      allow(double).to receive(:new).and_return(test_event_instance)
      allow(double).to receive(:to_s).and_return('Events::TestEvent')
      allow(double).to receive(:is_a?).with(Class).and_return(true)
    end
  end

  let!(:test_event_instance) do
    instance_double('Events::TestEvent').tap do |double|
      allow(double).to receive(:is_a?).with(Class).and_return(false)
      allow(double).to receive(:class).and_return('Events::TestEvent')
    end
  end

  let!(:another_test_event_klass) do
    class_double('Events::AnotherTestEvent').tap do |double|
      stub_const('Events::AnotherTestEvent', double)
      allow(double).to receive(:new).and_return(another_test_event_instance)
      allow(double).to receive(:to_s).and_return('Events::AnotherTestEvent')
      allow(double).to receive(:is_a?).with(Class).and_return(true)
    end
  end

  let!(:another_test_event_instance) do
    class_double('Events::AnotherTestEvent').tap do |double|
      stub_const('Events::AnotherTestEvent', double)
      allow(double).to receive(:is_a?).with(Class).and_return(false)
      allow(double).to receive(:class).and_return('Events::AnotherTestEvent')
    end
  end

  let!(:event_name) { test_event_klass }
  let!(:event_klass) { test_event_klass }
  let!(:event_instance) { test_event_instance }

  describe '#notify' do
    before(:each) do
      allow(name_resolver).to receive(:transform).with(event_name).and_return(event_klass)
    end

    context 'when subscriber to event, the block is called and get\'s an instance of the event passed as payload' do
      before :each do
        bus.register(event_klass) do |event|
          @received_payload = event
        end

        bus.notify event_instance
      end

      it { expect(@received_payload).to eq(event_instance) }
    end

    context 'when not subscriber to event' do
      let!(:other_event_instance) { another_test_event_instance }

      before :each do
        @received_payload = false
        bus.register(event_klass) { @received_payload = true }
        bus.notify other_event_instance
      end

      it { expect(@received_payload).to eq(false) }
    end

    context 'when multiple subscribers are given' do
      let(:received_events) { [] }

      before :each do
        bus.register(Events::TestEvent) do |event|
          received_events << event
        end
        bus.register(Events::TestEvent) do |event|
          received_events << event
        end

        bus.notify event_instance
      end

      it { expect(received_events.length).to eq 2 }
      it { expect(received_events).to all eq event_instance }
    end

    context 'when subscriber is given by string' do
      let!(:event_name) { test_event_klass.to_s }
      let(:received_payload) { [] }

      before :each do
        bus.register(event_klass.to_s) do |event|
          received_payload << event
        end

        bus.notify event_instance
      end

      it { expect(received_payload).to include event_instance }
    end

    context "when subscriber is given by symbol (for events in the Cucumber::Events namespace)" do
      let!(:event_name) { :test_event }
      let(:received_payload) { [] }

      before :each do
        bus.register(event_name) do |event|
          received_payload << event
        end

        bus.notify event_instance
      end

      it { expect(received_payload).to include event_instance }
    end

    context 'when event is not an instance of event class' do
      let!(:event_name) { :test_event }
      let(:received_payload) { [] }

      before :each do
        bus.register(event_name, proc {})
      end

      it { expect { bus.notify event_klass }.to raise_error Cucumber::NoEventError }
    end
  end

  describe '#register' do
    context 'when valid custom handler' do
      before(:each) do
        allow(name_resolver).to receive(:transform).with(event_name).and_return(event_klass)
      end

      let!(:handler_klass) do
        class_double('MyHandler').tap do |double|
          stub_const('MyHandler', double)
          allow(double).to receive(:new).and_return(handler_instance)
        end
      end

      let!(:handler_instance) do
        instance_double('MyHandler').tap do |double|
          expect(double).to receive(:call).with(event_instance)
        end
      end

      before :each do
        bus.register(event_klass, MyHandler.new)
      end

      it { expect { bus.notify event_instance }.not_to raise_error }
    end

    context 'when malformed custom handler' do
      let!(:handler_klass) do
        class_double('MyHandler').tap do |double|
          stub_const('MyHandler', double)
          allow(double).to receive(:new).and_return(handler_instance)
        end
      end

      let!(:handler_instance) { instance_double('MyHandler') }

      it { expect { bus.register(event_klass, MyHandler.new) }.to raise_error ArgumentError }
    end

    context 'when no handler is given' do
      it { expect { bus.register(event_klass) }.to raise_error ArgumentError }
    end

    context 'when malformed name resolver' do
      before(:each) do
        allow(name_resolver).to receive(:transform).with(event_name).and_return(nil)
      end

      it { expect { bus.register(event_klass, proc { }) }.to raise_error Cucumber::EventNameResolveError, %(Transforming "#{event_klass}" into an event name failed for unknown reason.) }
    end
  end
end
