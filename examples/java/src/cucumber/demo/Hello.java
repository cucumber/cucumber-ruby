package cucumber.demo;

public class Hello {
    public String greet(String who, String from) {
        return "Hi, " + who + ". I'm " + from;
    }
    
    public boolean isFriend(String who) {
        return true;
    }
}