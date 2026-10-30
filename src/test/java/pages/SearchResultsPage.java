package pages;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.visible;
import static com.codeborne.selenide.Condition.text;
import static com.codeborne.selenide.Selectors.byText;
import com.codeborne.selenide.ex.ElementNotFound;
import static com.codeborne.selenide.Selenide.$$;

public class SearchResultsPage {
    private SelenideElement resultsList = $("[data-testid='results-list']");

    public SearchResultsPage verifyResultsContain(String expectedText) {
        try {
            resultsList.shouldBe(visible).shouldHave(text(expectedText));
        } catch (ElementNotFound e) {
            $(byText(expectedText)).shouldBe(visible);
        }
        return this;
    }

    public SearchResultsPage verifyResultsCount(String expectedCount) {
        $("#search-results-count").shouldBe(visible).shouldHave(text(expectedCount));
        return this;
    }
}
