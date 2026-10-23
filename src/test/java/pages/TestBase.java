import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import com.codeborne.selenide.Configuration;
import com.codeborne.selenide.Selenide;

public class TestBase {
    @BeforeEach
    void setUp() {
        Configuration.baseUrl = System.getProperty("selenide.baseUrl", "https://github.com");
        Configuration.browser = System.getProperty("selenide.browser", "chrome");
        Configuration.browserSize = System.getProperty("selenide.browserSize", "1920x1200");
        // Increase default timeout for slow pages
        Configuration.timeout = 10000;
    }

    @AfterEach
    void tearDown() {
        Selenide.closeWebDriver();
    }
}
