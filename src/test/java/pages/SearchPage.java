package pages;

import components.SearchInput;
import components.SearchTabs;

public class SearchPage {
    private final SearchInput searchInput = new SearchInput();
    private final SearchTabs searchTabs = new SearchTabs();

    public SearchResultsPage searchFor(String query) {
        searchInput.searchFor(query);
        return new SearchResultsPage();
    }

    public SearchPage typeSearchQuery(String query) {
        searchInput.typeSearchQuery(query);
        return this;
    }

    public SearchPage openSearchTab(String labelName) {
        searchTabs.openTab(labelName);
        if("Пользователи".equals(labelName)) {
            verifyPlaceHolderValue("Никнейм");
        } else if ("Комментарии".equals(labelName)) {
            verifyPlaceHolderValue("Текст комментария");
        } else {
            throw new IllegalArgumentException("Неизвестный labelName: " + labelName);
        }
        return this;
    }

    public SearchPage verifyPlaceHolderValue(String expectedText) {
        searchInput.shouldHavePlaceholder(expectedText);
        return this;
    }

    public String getSearchInputValue() {
        return searchInput.getValue();
    }
}