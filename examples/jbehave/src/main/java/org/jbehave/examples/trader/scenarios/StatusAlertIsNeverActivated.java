package org.jbehave.examples.trader.scenarios;

import org.jbehave.scenario.PropertyBasedConfiguration;
import org.jbehave.scenario.JUnitScenario;
import org.jbehave.scenario.parser.PatternScenarioParser;
import org.jbehave.scenario.parser.ClasspathScenarioDefiner;
import org.jbehave.scenario.parser.UnderscoredCamelCaseResolver;


public class StatusAlertIsNeverActivated extends JUnitScenario {

    public StatusAlertIsNeverActivated() {
        this(Thread.currentThread().getContextClassLoader());
    }

    public StatusAlertIsNeverActivated(final ClassLoader classLoader) {
        super(new PropertyBasedConfiguration() {
            @Override
            public ClasspathScenarioDefiner forDefiningScenarios() {
                return new ClasspathScenarioDefiner(new UnderscoredCamelCaseResolver(".scenario"), new PatternScenarioParser(new PropertyBasedConfiguration()), classLoader);
            }
        }, new TraderSteps(classLoader));
    }

}
