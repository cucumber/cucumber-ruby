# Require this file if you need Unicode support.
require 'cucumber/platform'
require 'cucumber/formatters/ansicolor'

$KCODE='u'

if $CUCUMBER_WINDOWS_MRI && `chcp` =~ /Active code page: (\d+)/
  codepage = $1.to_i
  codepages = (1251..1252)

  if codepages.include?(codepage)
    $CUCUMBER_CODEPAGE = "cp#{codepage}"
  
    require 'iconv'
    module Kernel
      alias cucumber_print print
      def print(*a)
        cucumber_print *Iconv.iconv($CUCUMBER_CODEPAGE, "UTF-8", *a)
      end

      alias cucumber_puts puts
      def puts(*a)
        cucumber_puts *Iconv.iconv($CUCUMBER_CODEPAGE, "UTF-8", *a)
      end
    end
  end
end