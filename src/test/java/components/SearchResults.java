package components;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.text;
import static com.codeborne.selenide.Condition.visible;
import static com.codeborne.selenide.Selectors.byText;
import com.codeborne.selenide.ex.ElementNotFound;
import java.time.Duration;

public class SearchResults {
    private static final String RESULTS_LIST_LOCATOR = ".v2-search__results";

    private final SelenideElement resultsList = $(RESULTS_LIST_LOCATOR);

    public SearchResults verifyResultsContain(String expectedText) {
        try {
            resultsList.shouldBe(visible).shouldHave(text(expectedText));
        } catch (ElementNotFound e) {
            $(byText(expectedText)).shouldBe(visible, Duration.ofSeconds(30));
        }
        return this;
    }
}
