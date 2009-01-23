package cukes.jbehave.examples.trader.converters;

import java.lang.reflect.Type;

import cukes.jbehave.examples.trader.model.Trader;
import cukes.jbehave.examples.trader.persistence.TraderPersister;
import org.jbehave.scenario.steps.ParameterConverters.InvalidParameterException;
import org.jbehave.scenario.steps.ParameterConverters.ParameterConverter;

public class TraderConverter implements ParameterConverter {
    private TraderPersister persister;

    public TraderConverter(TraderPersister persister) {
        this.persister = persister;
    }

    public boolean accept(Type type) {
        if (type instanceof Class) {
            return Trader.class.isAssignableFrom((Class<?>) type);
        }
        return false;
    }

    public Object convertValue(String value, Type type) {
        Trader trader = persister.retrieveTrader(value);
        if (trader == null) {
            throw new InvalidParameterException("Trader not found for name " + value, null);
        }
        return trader;
    }

}
