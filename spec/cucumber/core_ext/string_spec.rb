require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/core_ext/string'
require 'cucumber/rb_support/rb_group'

describe String, "#gzub" do
  def groups(a)
    a.map{|c| Cucumber::RbSupport::RbGroup.new(c[0], c[1])}
  end
  
  it "should format groups with format string" do
    "I ate 1 egg this morning".gzub(groups([['ate', 2], ['1', 6], ['egg', 8],  ['morning', 17]]), "<span>%s</span>").should ==
    "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
  end

  it "should format groups with format string when there are dupes" do
    "I bob 1 bo this bobs".gzub(groups([['bob', 2], ['1', 6], ['bo', 8],  ['bobs', 16]]), "<span>%s</span>").should ==
    "I <span>bob</span> <span>1</span> <span>bo</span> this <span>bobs</span>"
  end

  it "should format groups with block" do
    f = "I ate 1 egg this morning".gzub(groups([['ate', 2], ['1', 6], ['egg', 8],  ['morning', 17]])) do |m|
      "<span>#{m}</span>"
    end
    f.should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
  end

  it "should format groups with proc object" do
    proc = lambda do |m|
      "<span>#{m}</span>"
    end
    f = "I ate 1 egg this morning".gzub(groups([['ate', 2], ['1', 6], ['egg', 8],  ['morning', 17]]), proc)
    f.should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
  end
  
  it "should format groups with block with not all placeholders having a value" do
    f = "another member named Bob joins the group".gzub(groups([['another', 0], ['member', 8], ['Bob', 21]])) do |m|
      "<span>#{m}</span>"
    end
    f.should == "<span>another</span> <span>member</span> named <span>Bob</span> joins the group"
  end
end
