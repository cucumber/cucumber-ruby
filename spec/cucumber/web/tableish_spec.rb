require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")
require 'cucumber/web/tableish'

module Cucumber
  module Web
    describe Tableish do
      include Tableish
      
      unless RUBY_PLATFORM =~ /java/
        it "should convert a table" do
          html = <<-HTML
            <table>
              <tr>
                <th>tool</th>
                <th>dude</th>
              </tr>
              <tr>
                <td>webrat</td>
                <td>bryan</td>
              </tr>
              <tr>
                <td>cucumber</td>
                <td>aslak</td>
              </tr>
            </table>
          HTML

          _tableish(html, :parent => 'table', :row => ['tr th, tr td']).should == [
            %w{tool dude},
            %w{webrat bryan},
            %w{cucumber aslak}
          ]
        end

        it "should convert a dl" do
          html = <<-HTML
            <dl>
              <dt>webrat</dt>
              <dd>bryan</dd>
              <dt>cucumber</dt>
              <dd>aslak</dd>
            </dl>
          HTML

          _tableish(html, :columns => ["dl dt:nth-child(%s)", "dl dd:nth-child(%s+1)"]).should == [
            %w{webrat bryan},
            %w{cucumber aslak}
          ]
        end

        it "should convert a ul" do
          html = <<-HTML
            <ul>
              <li>webrat</li>
              <li>bryan</li>
              <li>cucumber</li>
              <li>aslak</li>
            </ul>
          HTML

          _tableish(html, :rows => 'ul li').should == [
            %w{webrat},
            %w{bryan},
            %w{cucumber},
            %w{aslak},
          ]
        end
      end
    end
  end
end