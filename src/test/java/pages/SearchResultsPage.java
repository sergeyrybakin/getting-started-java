package pages;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.visible;
import static com.codeborne.selenide.Condition.text;
import static com.codeborne.selenide.Selectors.byText;
import com.codeborne.selenide.ex.ElementNotFound;
import java.time.Duration;
import io.qameta.allure.Step;

public class SearchResultsPage {
    private static final String RESULTS_LIST_LOCATOR = "[data-testid='results-list']";
    private static final String SEARCH_RESULTS_COUNT_LOCATOR = "body main #search-results-count";

    private SelenideElement resultsList = $(RESULTS_LIST_LOCATOR);
    private SelenideElement resultsCount = $(SEARCH_RESULTS_COUNT_LOCATOR);

    @Step("Verify search results contain '{expectedText}'")
    public SearchResultsPage verifyResultsContain(String expectedText) {
        try {
            resultsList.shouldBe(visible).shouldHave(text(expectedText));
        } catch (ElementNotFound e) {
            $(byText(expectedText)).shouldBe(visible, Duration.ofSeconds(30));
        }
        return this;
    }

    @Step("Verify search results count is '{expectedCount}'")
    public SearchResultsPage verifyResultsCount(String expectedCount) {
        resultsCount.shouldBe(visible, Duration.ofSeconds(30)).shouldHave(text(expectedCount));
        return this;
    }
}