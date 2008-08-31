require File.dirname(__FILE__) + '/../../../lib/cucumber/core_ext/string'

describe String, "#gzub" do
  it "should format groups with format string" do
    "I ate 1 egg this morning".gzub(/I (\w+) (\d+) (\w+) this (\w+)/, "<span>%s</span>").should ==
    "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
  end

  it "should format groups with format string when there are dupes" do
    "I bob 1 bo this bobs".gzub(/I (\w+) (\d+) (\w+) this (\w+)/, "<span>%s</span>").should ==
    "I <span>bob</span> <span>1</span> <span>bo</span> this <span>bobs</span>"
  end

  it "should format groups with block" do
    f = "I ate 1 egg this morning".gzub(/I (\w+) (\d+) (\w+) this (\w+)/) do |m|
      "<span>#{m}</span>"
    end
    f.should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
  end

  it "should format match groups in a textile table row" do
    f = "I ate 1 egg this morning".gzub(/I (\w+) (\d+) (\w+) this (\w+)/) do |m|
      "<span>#{m}</span>"
    end
    f.should == "I <span>ate</span> <span>1</span> <span>egg</span> this <span>morning</span>"
  end
end
