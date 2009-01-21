package org.jbehave.examples.trader.persistence;

import org.jbehave.examples.trader.model.Trader;

public class TraderPersister {

    private Trader[] traders;

    public TraderPersister(Trader... traders) {
        this.traders = traders;
    }

    public Trader retrieveTrader(String name) {
        for (Trader trader : traders) {
            if (trader.getName().equals(name)) {
                return trader;
            }
        }
        return null;
    }

}
