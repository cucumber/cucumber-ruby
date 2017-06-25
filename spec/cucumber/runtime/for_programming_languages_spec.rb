# frozen_string_literal: true
require 'spec_helper'

module Cucumber
  describe Runtime::ForProgrammingLanguages do

    let(:user_interface)  { double('user interface') }
    subject               { Runtime::SupportCode.new(user_interface) }
    let(:runtime_facade)  { Runtime::ForProgrammingLanguages.new(subject, user_interface) }

    describe '#doc_string' do

      it 'defaults to a blank content-type' do
        str = runtime_facade.doc_string('DOC')
        expect(str).to be_kind_of(MultilineArgument::DocString)
        expect(str.content_type).to eq('')
      end

      it 'can have a content type' do
        str = runtime_facade.doc_string('DOC','ruby')
        expect(str.content_type).to eq('ruby')
      end

    end

  end
end
