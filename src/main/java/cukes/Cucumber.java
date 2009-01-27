package cukes;

import java.io.InputStream;
import java.util.List;
import java.util.ArrayList;
import org.jruby.Ruby;
import org.jruby.RubyRuntimeAdapter;
import org.jruby.RubyInstanceConfig;
import org.jruby.javasupport.JavaEmbedUtils;  

public class Cucumber {
    public static void main(String[] argv) {
        RubyInstanceConfig config = new RubyInstanceConfig();
        config.setArgv(argv);

        List<String> loadPaths = new ArrayList<String>();
    	loadPaths.add("lib");
        Ruby runtime = JavaEmbedUtils.initialize(loadPaths, config);

        RubyRuntimeAdapter evaler = JavaEmbedUtils.newRuntimeAdapter();

        String main = "bin/cucumber";
        InputStream mainScript = Cucumber.class.getClassLoader().getResourceAsStream(main);
        try {
            evaler.parse(runtime, mainScript, "cucumber", 0).run();
        } catch(Exception e) {
            // Hmm we always seem to get an exception....
        } finally {
            JavaEmbedUtils.terminate(runtime);
        }
    }
}