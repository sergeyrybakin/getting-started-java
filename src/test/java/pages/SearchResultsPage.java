package pages;

import components.SearchResults;

public class SearchResultsPage {
    private final SearchResults searchResults = new SearchResults();

    public SearchResultsPage verifyResultsContain(String expectedText) {
        searchResults.verifyResultsContain(expectedText);
        return this;
    }
}
