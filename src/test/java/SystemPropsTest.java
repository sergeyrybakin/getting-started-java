import org.junit.jupiter.api.Test;
import java.util.Properties;
import java.util.stream.Collectors;

public class SystemPropsTest {
    @Test
    void printSelenideProps() {
        Properties props = System.getProperties();
        props.stringPropertyNames().stream()
            .filter(k -> k.startsWith("selenide"))
            .forEach(k -> System.out.println(k + "=" + props.getProperty(k)));
    }
}
