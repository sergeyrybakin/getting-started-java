package pages;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.visible;
import static com.codeborne.selenide.Condition.text;
import static com.codeborne.selenide.Selectors.byText;
import com.codeborne.selenide.ex.ElementNotFound;
import java.time.Duration;

public class SearchResultsPage {
    private static final String RESULTS_LIST_LOCATOR = "[data-testid='results-list']";
    private static final String SEARCH_RESULTS_COUNT_LOCATOR = "body main #search-results-count";

    private SelenideElement resultsList = $(RESULTS_LIST_LOCATOR);

    public SearchResultsPage verifyResultsContain(String expectedText) {
        try {
            resultsList.shouldBe(visible).shouldHave(text(expectedText));
        } catch (ElementNotFound e) {
            $(byText(expectedText)).shouldBe(visible, Duration.ofSeconds(30));
        }
        return this;
    }

    public SearchResultsPage verifyResultsCount(String expectedCount) {
        $(SEARCH_RESULTS_COUNT_LOCATOR).shouldBe(visible, Duration.ofSeconds(30)).shouldHave(text(expectedCount));
        return this;
    }
}
