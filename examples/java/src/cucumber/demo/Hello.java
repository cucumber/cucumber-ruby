package cucumber.demo;

public class Hello {
    public String greet(String who, String from) {
        return "Hi, " + who + ". I'm " + from;
    }
    
    public boolean isFriend(String who) {
        return true;
    }
    
    public String getPhoneNumber(String who) {
        throw new RuntimeException("NOPE");
        //return "98219458";
    }
}