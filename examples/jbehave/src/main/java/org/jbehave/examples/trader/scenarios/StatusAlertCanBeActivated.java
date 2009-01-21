package org.jbehave.examples.trader.scenarios;

import org.jbehave.scenario.MostUsefulConfiguration;
import org.jbehave.scenario.PropertyBasedConfiguration;
import org.jbehave.scenario.JUnitScenario;
import org.jbehave.scenario.parser.PatternScenarioParser;
import org.jbehave.scenario.parser.ScenarioDefiner;
import org.jbehave.scenario.parser.ClasspathScenarioDefiner;
import org.jbehave.scenario.parser.UnderscoredCamelCaseResolver;


public class StatusAlertCanBeActivated extends JUnitScenario {

    public StatusAlertCanBeActivated() {
        this(Thread.currentThread().getContextClassLoader());
    }

    public StatusAlertCanBeActivated(final ClassLoader classLoader) {
        super(new MostUsefulConfiguration() {
            public ScenarioDefiner forDefiningScenarios() {
                return new ClasspathScenarioDefiner(new UnderscoredCamelCaseResolver(".scenario"), new PatternScenarioParser(new PropertyBasedConfiguration()), classLoader);
            }
        }, new TraderSteps(classLoader));
    }

}
