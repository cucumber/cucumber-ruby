# frozen_string_literal: true

require 'spec_helper'

module Html end

module Cucumber
  describe Constantize do
    include Constantize

    it 'loads pretty formatter' do
      clazz = constantize('Cucumber::Formatter::Pretty')

      expect(clazz.name).to eq 'Cucumber::Formatter::Pretty'
    end

    it 'fails to load a made up class' do
      expect { constantize('My::MadeUp::ClassName') }.to raise_error(LoadError)
    end
  end
end
