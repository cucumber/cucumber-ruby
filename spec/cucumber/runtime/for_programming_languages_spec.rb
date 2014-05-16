require 'spec_helper'

module Cucumber
  describe Runtime::ForProgrammingLanguages do

    let(:user_interface)  { double('user interface') }
    subject               { Runtime::SupportCode.new(user_interface,{}) }
    let(:runtime_facade)  { Runtime::ForProgrammingLanguages.new(subject, user_interface) }

    it 'produces Ast::DocString by #doc_string with default content-type' do
      str = runtime_facade.doc_string('DOC')
      str.should be_kind_of(Core::Ast::DocString)
      str.content_type.should eq('')
    end

    it 'produces Ast::DocString by #doc_string with ruby content-type' do
      str = runtime_facade.doc_string('DOC','ruby')
      str.should be_kind_of(Core::Ast::DocString)
      str.content_type.should eq('ruby')
    end

    it 'produces Ast::Table by #table' do
      runtime_facade.table(%{
      | account | description | amount |
      | INT-100 | Taxi        | 114    |
      | CUC-101 | Peeler      | 22     |
      }).should be_kind_of(Core::Ast::DataTable)
    end

  end
end
