require 'spec_helper'

module Cucumber
  describe Runtime::ForProgrammingLanguages do

    let(:user_interface)  { double('user interface') }
    subject               { Runtime::SupportCode.new(user_interface,{}) }
    let(:runtime_facade)  { Runtime::ForProgrammingLanguages.new(subject, user_interface) }

    it 'should produce Ast::DocString by #doc_string with default content-type' do
      str = runtime_facade.doc_string('DOC')
      str.should be_kind_of(Ast::DocString)
      str.content_type.should eq('')
    end

    it 'should produce Ast::DocString by #doc_string with ruby content-type' do
      str = runtime_facade.doc_string('DOC','ruby')
      str.should be_kind_of(Ast::DocString)
      str.content_type.should eq('ruby')
    end

    it 'should produce Ast::Table by #table' do
      runtime_facade.table(%{
      | account | description | amount |
      | INT-100 | Taxi        | 114    |
      | CUC-101 | Peeler      | 22     |
      }).should be_kind_of(Ast::Table)
    end

  end
end
