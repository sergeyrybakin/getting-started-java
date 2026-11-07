package components;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.attribute;
import static com.codeborne.selenide.Condition.visible;

public class SearchInput {
    private static final String SEARCH_INPUT_LOCATOR = "input[name='q']";

    private final SelenideElement searchInput = $(SEARCH_INPUT_LOCATOR);

    public SearchInput searchFor(String query) {
        searchInput.shouldBe(visible).setValue(query).pressEnter();
        return this;
    }

    public SearchInput typeSearchQuery(String query) {
        searchInput.setValue(query);
        return this;
    }

    public SearchInput shouldHavePlaceholder(String expectedText) {
        searchInput.shouldHave(attribute("placeholder", expectedText));
        return this;
    }

    public String getValue() {
        return searchInput.val();
    }
}
