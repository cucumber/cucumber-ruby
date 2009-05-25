STDERR.puts <<-EOF
WARNING: The cucumber/formatters/unicode file is deprecated.
It will be removed in version 0.4.0
Please use cucumber/formatter/unicode instead
EOF
# This is for backwards compatibility
require 'cucumber/formatter/unicode'