package cukes.jbehave.examples.trader.model;

import static java.util.Arrays.asList;

import java.util.List;

public class Trader {

    private final String name;
    private List<Stock> stocks;

    public Trader(String name, List<Stock> stocks) {
        this.name = name;
        this.stocks = stocks;
    }

    public String getName() {
        return name;
    }

    public List<Stock> getStocks() {
        return stocks;
    }

    public void sellAllStocks(){
        this.stocks = asList(new Stock[]{});
    }

}
