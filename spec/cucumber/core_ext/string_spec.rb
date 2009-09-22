require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/cucumber/core_ext/string'

describe String, "#gzub" do
  it "should format groups with format string" do
    "I ate 1 egg this morning".gzub(%w{ate 1 egg morning}, [2, 6, 8, 17], "<span>%s</span>").should ==
    "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
  end

  it "should format groups with format string when there are dupes" do
    "I bob 1 bo this bobs".gzub(%w{bob 1 bo bobs}, [2, 6, 8, 16], "<span>%s</span>").should ==
    "I <span>bob</span> <span>1</span> <span>bo</span> this <span>bobs</span>"
  end

  it "should format groups with block" do
    f = "I ate 1 egg this morning".gzub(%w{ate 1 egg morning}, [2, 6, 8, 17]) do |m|
      "<span>#{m}</span>"
    end
    f.should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
  end

  it "should format groups with proc object" do
    proc = lambda do |m|
      "<span>#{m}</span>"
    end
    f = "I ate 1 egg this morning".gzub(%w{ate 1 egg morning}, [2, 6, 8, 17], proc)
    f.should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
  end
  
  it "should format groups with block with not all placeholders having a value" do
    f = "another member named Bob joins the group".gzub(%w{another member Bob}, [0, 8, 21]) do |m|
      "<span>#{m}</span>"
    end
    f.should == "<span>another</span> <span>member</span> named <span>Bob</span> joins the group"
  end
end
