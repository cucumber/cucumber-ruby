using System;

namespace Cucumber.Demo {
	public class Hello {
    public string Greet(string who, string from) {
        return "Hi, " + who + ". I'm " + from;
    }
   
    public bool IsFriend(string who) {
        return true;
    }
   
    public string GetPhoneNumber(string who) {
       	return "99999";
//throw new Exception("My phone is secret!");
    }
	}
}