package org.jbehave.examples.trader.scenarios;

import org.jbehave.scenario.JUnitScenario;
import org.jbehave.scenario.PropertyBasedConfiguration;
import org.jbehave.scenario.parser.ClasspathScenarioDefiner;
import org.jbehave.scenario.parser.PatternScenarioParser;
import org.jbehave.scenario.parser.ScenarioDefiner;
import org.jbehave.scenario.parser.UnderscoredCamelCaseResolver;


public class TraderSellsAllStocks extends JUnitScenario {

    public TraderSellsAllStocks() {
        this(Thread.currentThread().getContextClassLoader());
    }

    public TraderSellsAllStocks(final ClassLoader classLoader) {
        super(new PropertyBasedConfiguration() {
            public ScenarioDefiner forDefiningScenarios() {
                return new ClasspathScenarioDefiner(new UnderscoredCamelCaseResolver(".scenario"), new PatternScenarioParser(this), classLoader);
            }
        }, new TraderSteps(classLoader)); 
    }

}
