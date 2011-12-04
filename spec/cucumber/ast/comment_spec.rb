require 'spec_helper'
require "cucumber/ast/comment"

include Cucumber::Ast

describe Comment do 
  before do 
    @comment = Comment.new("nobi")
    @comment_1 = Comment.new('')
    @comment_2 = Comment.new(nil)
    @empty_comments = [@comment_1,@comment_2]
  end


  it "should @value is 'hello\nworld'" do 
    @comment.value.should == "nobi"
  end

  context "Comment#to_sexp" do 
    it "should return empty when @value is nil or ''" do 
      @empty_comments.each{|comment| comment.empty?.should == true}
    end
    it "should return nil when to_sexp('') or to_sexp(nil)" do
      @empty_comments.each{|comment|  comment.to_sexp.should == nil}
    end
    it "should return [:comment,@value],when call to_sexp('nobi')" do 
      @comment.to_sexp.should == [:comment,"nobi"]
    end
  end
end







    
