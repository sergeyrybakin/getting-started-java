import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class FailingTest extends TestBase {
    @Test
    void alwaysFail() {
        fail("Intentional failure to test cleanup");
    }
}
