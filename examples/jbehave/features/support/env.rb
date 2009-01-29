$:.unshift(File.dirname(__FILE__) + '/../../target')

require 'cucumber/jbehave'

import 'cukes.jbehave.examples.trader.scenarios.TraderSteps'
JBehave(TraderSteps.new)