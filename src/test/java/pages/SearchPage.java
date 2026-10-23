package pages;

import com.codeborne.selenide.SelenideElement;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Condition.visible;

public class SearchPage {
    private SelenideElement searchInput = $("input[aria-label='Search GitHub']");

    public void searchFor(String query) {
        searchInput.shouldBe(visible).setValue(query).pressEnter();
    }
}