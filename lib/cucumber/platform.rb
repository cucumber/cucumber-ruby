# Detect the platform we're running on so we can tweak behaviour
# in various places.
require 'rbconfig'

$CUCUMBER_JRUBY       = defined?(JRUBY_VERSION)
$CUCUMBER_IRONRUBY    = Config::CONFIG['sitedir'] =~ /IronRuby/
$CUCUMBER_WINDOWS     = Config::CONFIG['host_os'] =~ /mswin|mingw/
$CUCUMBER_WINDOWS_MRI = $CUCUMBER_WINDOWS && !$CUCUMBER_JRUBY && !$CUCUMBER_IRONRUBY
$CUCUMBER_RAILS       = defined?(Rails)
