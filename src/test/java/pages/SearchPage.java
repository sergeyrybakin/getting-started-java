package pages;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.visible;
import static com.codeborne.selenide.Condition.value;
import io.qameta.allure.Step;

public class SearchPage {
    private static final String SEARCH_INPUT_LOCATOR = "input[aria-label='Search GitHub']";
    private static final String CROSS_ICON_LOCATOR = ".octicon-x-circle-fill";

    private SelenideElement searchInput = $(SEARCH_INPUT_LOCATOR);
    private SelenideElement crossIcon = $(CROSS_ICON_LOCATOR);

    @Step("Search for query '{query}'")
    public SearchResultsPage searchFor(String query) {
        searchInput.shouldBe(visible).setValue(query).pressEnter();
        return new SearchResultsPage();
    }

    @Step("Type search query '{query}'")
    public SearchPage typeSearchQuery(String query) {
        searchInput.setValue(query);
        return this;
    }

    @Step("Verify clear icon is visible")
    public SearchPage verifyClearIconVisible() {
        crossIcon.shouldBe(visible);
        return this;
    }

    @Step("Verify clear icon is not visible")
    public SearchPage verifyClearIconHidden() {
        crossIcon.shouldNotBe(visible);
        return this;
    }

    @Step("Click clear icon")
    public SearchPage clickClearIcon() {
        crossIcon.shouldBe(visible).click();
        return this;
    }

    @Step("Verify search input is empty")
    public SearchPage verifySearchInputEmpty() {
        searchInput.shouldHave(value(""));
        return this;
    }
}