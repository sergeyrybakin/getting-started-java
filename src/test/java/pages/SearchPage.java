package pages;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.visible;

public class SearchPage {
    private SelenideElement searchInput = $("input[aria-label='Search GitHub']");
    private SelenideElement crossIcon = $(".octicon-x-circle-fill");

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
