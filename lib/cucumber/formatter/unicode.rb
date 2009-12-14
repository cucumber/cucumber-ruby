# Require this file if you need Unicode support.
require 'cucumber/platform'
require 'cucumber/formatter/ansicolor'
$KCODE='u' unless Cucumber::RUBY_1_9

if Cucumber::WINDOWS && `cmd /c chcp` =~ /(\d+)/
  require 'iconv'
  codepage = $1.to_i
  Cucumber::CODEPAGE = "cp#{codepage}"

  module Cucumber
    module WindowsOutput #:nodoc:
      def self.extended(o)
        o.instance_eval do
          alias cucumber_print print
          def print(*a)
            begin
              cucumber_print(*Iconv.iconv(Cucumber::CODEPAGE, "UTF-8", *a.map{|a|a.to_s}))
            rescue Iconv::IllegalSequence
              cucumber_print(*a)
            end
          end

          alias cucumber_puts puts
          def puts(*a)
            begin
              cucumber_puts(*Iconv.iconv(Cucumber::CODEPAGE, "UTF-8", *a.map{|a|a.to_s}))
            rescue Iconv::IllegalSequence
              cucumber_puts(*a)
            end
          end
        end
      end

      Kernel.extend(self)
      STDOUT.extend(self)
      STDERR.extend(self)
    end
  end
end
