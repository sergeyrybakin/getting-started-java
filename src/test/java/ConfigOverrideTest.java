import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import com.codeborne.selenide.Configuration;

public class ConfigOverrideTest extends TestBase {
    @Test
    void overrideBrowserSizeTest() {
        // Override within test
        Configuration.browserSize = "800x600";
        assertEquals("800x600", Configuration.browserSize);
    }
}
