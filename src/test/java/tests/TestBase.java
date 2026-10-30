package tests;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;

import com.codeborne.selenide.Selenide;
import com.codeborne.selenide.Configuration;

public class TestBase {
    @BeforeEach
    void setUp() {
        Configuration.baseUrl = System.getProperty("selenide.baseUrl", "https://github.com");
        Configuration.browser = System.getProperty("selenide.browser", "chrome");
        Configuration.browserSize = System.getProperty("selenide.browserSize", "1920x1200");
        Configuration.timeout = 10000;
        Configuration.headless = true;
    }

    @AfterEach
    void tearDown() {
        Selenide.closeWebDriver();
    }
}
