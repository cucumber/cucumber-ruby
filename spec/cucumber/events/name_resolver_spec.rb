require 'cucumber/events/name_resolver'

describe Cucumber::Events::NameResolver do
  subject(:resolver) { described_class.new(default_name_space) }
  let(:default_name_space) { 'Cucumber::Events' }
  let(:resolved_name) { resolver.transform(original_name) }

  before :each do
    stub_const('Events::MyEvent', Class.new)
    stub_const('Cucumber::Events::MyEvent', Class.new)
  end

  describe '#transform' do
    context 'when name is string' do
      context 'when simple' do
        let(:original_name) { 'Events::MyEvent' }
        it { expect(resolved_name).to eq Events::MyEvent }
      end

      context 'when prefixed' do
        let(:original_name) { '::Events::MyEvent' }
        it { expect(resolved_name).to eq Events::MyEvent }
      end
    end

    context 'when name is class' do
      context 'when simple' do
        let(:original_name) { Events::MyEvent }
        it { expect(resolved_name).to eq Events::MyEvent }
      end

      context 'when prefixed' do
        let(:original_name) { ::Events::MyEvent }
        it { expect(resolved_name).to eq Events::MyEvent }
      end
    end

    context 'when name is symbol' do
      let(:original_name) { :my_event }
      it { expect(resolved_name).to eq Cucumber::Events::MyEvent }
    end

    context 'when namespace ...' do
      before :each do
        stub_const('MyLib::Events::MyEvent', Class.new)
      end

      context 'when is string' do
        let!(:default_name_space) { 'MyLib::Events' }
        let!(:original_name) { :my_event }

        it { expect(resolved_name).to eq MyLib::Events::MyEvent }
      end

      context 'when is module' do
        let!(:default_name_space) { MyLib::Events }
        let!(:original_name) { :my_event }

        it { expect(resolved_name).to eq MyLib::Events::MyEvent }
      end
    end
  end
end
