import org.junit.jupiter.api.Test;

import static com.codeborne.selenide.Condition.visible;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Selenide.refresh;
import static com.codeborne.selenide.Selenide.open;
import static com.codeborne.selenide.Condition.text;
import org.openqa.selenium.Keys;

public class SearchTests extends TestBase {
    @Test
    void successfulSearchTest() {
        open("/search");
        // Clear browser cache and reload page before typing
        // Use static import refresh directly
        refresh();
        // Use generic input selector
        $("input[name='q']").shouldBe(visible).setValue("qa.guru").pressEnter();
        $("[data-testid='results-list']").shouldHave(text("QA.GURU"));
    }
}
