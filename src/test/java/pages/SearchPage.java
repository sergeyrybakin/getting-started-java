package pages;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.visible;

public class SearchPage {
    private static final String SEARCH_INPUT_LOCATOR = "input[aria-label='Search GitHub']";
    private static final String CROSS_ICON_LOCATOR = ".octicon-x-circle-fill";

    private SelenideElement searchInput = $(SEARCH_INPUT_LOCATOR);
    private SelenideElement crossIcon = $(CROSS_ICON_LOCATOR);

    public SearchResultsPage searchFor(String query) {
        searchInput.shouldBe(visible).setValue(query).pressEnter();
        return new SearchResultsPage();
    }

    public SearchPage typeSearchQuery(String query) {
        searchInput.setValue(query);
        return this;
    }

    public boolean isClearIconVisible() {
        return crossIcon.exists() && crossIcon.isDisplayed();
    }

    public SearchPage clickClearIconRight() {
        crossIcon.shouldBe(visible).click();
        return this;
    }

    public String getSearchInputValue() {
        return searchInput.val();
    }
}