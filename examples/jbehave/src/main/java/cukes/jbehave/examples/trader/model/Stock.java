package cukes.jbehave.examples.trader.model;

import static cukes.jbehave.examples.trader.model.Stock.AlertStatus.OFF;
import static cukes.jbehave.examples.trader.model.Stock.AlertStatus.ON;

import java.util.List;

public class Stock {

    public enum AlertStatus {
        ON, OFF
    };

    private List<Double> prices;
    private double alertPrice;
    private AlertStatus status = OFF;

    public Stock(List<Double> prices, double alertPrice) {
        this.prices = prices;
        this.alertPrice = alertPrice;
    }

    public List<Double> getPrices() {
        return prices;
    }

    public void tradeAt(double price) {
        this.prices.add(price);
        if (price > alertPrice) {
            status = ON;
        }
    }

    public void resetAlert() {
        status = OFF;
    }

    public AlertStatus getStatus() {
        return status;
    }

}
