# Require this file if you need Unicode support.
require 'cucumber/platform'
require 'cucumber/formatters/ansicolor'

$KCODE='u'

if $CUCUMBER_WINDOWS_MRI
  if `chcp` =~ /Active code page: (\d+)/
    codepage = $1
    codepages = %w{1252 65001}
    if !codepages.include?(codepage)
      STDERR.puts %{
=====================================================================
Your console's current code page is #{codepage}.
You should change it to one of #{codepages.join(', ')} - for example:

  chcp 1252
=====================================================================
      }
    end
  end

  require 'iconv'
  module Kernel
    alias cucumber_print print
    def print(*a)
      cucumber_print Iconv.iconv("LATIN1", "UTF-8", *a)
    end

    alias cucumber_puts puts
    def puts(*a)
      cucumber_puts *Iconv.iconv("LATIN1", "UTF-8", *a)
    end
  end
end