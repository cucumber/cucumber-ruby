$:.unshift(File.dirname(__FILE__) + '/../../target')
require 'jbehave-example-0.2-SNAPSHOT.jar'

require 'cucumber/jbehave'

import 'cukes.jbehave.examples.trader.scenarios.TraderSteps'
JBehave(TraderSteps.new)