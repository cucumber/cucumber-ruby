require 'cucumber/reports/legacy_formatter'
require 'cucumber/reports/fan_out'
require 'cucumber/reports/rerun'
require 'cucumber/formatter/html'
require 'cucumber/formatter/pretty'
require 'cucumber/formatter/progress'
require 'cucumber/formatter/rerun'
require 'cucumber/formatter/usage'
require 'cucumber/formatter/stepdefs'
require 'cucumber/formatter/junit'
require 'cucumber/formatter/json'
require 'cucumber/formatter/json_pretty'
require 'cucumber/formatter/debug'

module Cucumber
  module Reports
    Html       = LegacyFormatter.adapt(Cucumber::Formatter::Html)
    Pretty     = LegacyFormatter.adapt(Cucumber::Formatter::Pretty)
    Progress   = LegacyFormatter.adapt(Cucumber::Formatter::Progress)
    Usage      = LegacyFormatter.adapt(Cucumber::Formatter::Usage)
    Stepdefs   = LegacyFormatter.adapt(Cucumber::Formatter::Stepdefs)
    Junit      = LegacyFormatter.adapt(Cucumber::Formatter::Junit)
    Json       = LegacyFormatter.adapt(Cucumber::Formatter::Json)
    JsonPretty = LegacyFormatter.adapt(Cucumber::Formatter::JsonPretty)
    Debug      = LegacyFormatter.adapt(Cucumber::Formatter::Debug)
  end
end
