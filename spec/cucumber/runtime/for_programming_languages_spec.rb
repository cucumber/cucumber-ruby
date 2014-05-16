require 'spec_helper'

module Cucumber
  describe Runtime::ForProgrammingLanguages do

    let(:user_interface)  { double('user interface') }
    subject               { Runtime::SupportCode.new(user_interface,{}) }
    let(:runtime_facade)  { Runtime::ForProgrammingLanguages.new(subject, user_interface) }

    it 'produces Ast::DocString by #doc_string with default content-type' do
      str = runtime_facade.doc_string('DOC')

      expect(str).to be_kind_of(Core::Ast::DocString)
      expect(str.content_type).to eq('')
    end

    it 'produces Ast::DocString by #doc_string with ruby content-type' do
      str = runtime_facade.doc_string('DOC','ruby')

      expect(str).to be_kind_of(Core::Ast::DocString)
      expect(str.content_type).to eq('ruby')
    end

    it 'produces Ast::Table by #table' do
      expect(runtime_facade.table(%{
      | account | description | amount |
      | INT-100 | Taxi        | 114    |
      | CUC-101 | Peeler      | 22     |
      })).to be_kind_of(Core::Ast::DataTable)
    end
  end
end
