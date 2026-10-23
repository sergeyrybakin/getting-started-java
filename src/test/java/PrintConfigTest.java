import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;
import com.codeborne.selenide.Configuration;

public class PrintConfigTest extends TestBase {
    @Test
    void checkBaseUrl() {
        assertEquals("https://d3.ru", Configuration.baseUrl);
    }
}
