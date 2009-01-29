require 'cucumber/jbehave'

project_code = File.expand_path(File.dirname(__FILE__) + '/../../target/jbehave-example-0.2-SNAPSHOT.jar')
require project_code

import 'cukes.jbehave.examples.trader.scenarios.TraderSteps'
JBehave(TraderSteps.new)
