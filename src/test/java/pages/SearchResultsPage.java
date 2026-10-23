package pages;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.visible;
import static com.codeborne.selenide.Condition.text;

public class SearchResultsPage {
    private SelenideElement resultsList = $("[data-testid='results-list']");

    public void verifyResultsContain(String expectedText) {
        resultsList.shouldBe(visible).shouldHave(text(expectedText));
    }
}
