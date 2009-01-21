$:.unshift(File.dirname(__FILE__) + '/../../target')
require 'jbehave-example-0.2-SNAPSHOT.jar'

require 'cucumber/jbehave'

JBehave(org.jbehave.examples.trader.scenarios.TraderSteps.new)