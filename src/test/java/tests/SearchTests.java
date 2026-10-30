package tests;

import org.junit.jupiter.api.Test;
import static com.codeborne.selenide.Selenide.open;
import static com.codeborne.selenide.Selenide.refresh;
import static org.junit.jupiter.api.Assertions.*;

import pages.SearchPage;
import pages.SearchResultsPage;

public class SearchTests extends TestBase {
    private SearchPage searchPage = new SearchPage();
    private SearchResultsPage searchResultsPage = new SearchResultsPage();

    @Test
    void successfulSearchTest() {
        open("/search");
        refresh();
        searchPage.searchFor("qa.guru").verifyResultsContain("qa.guru");
    }

    @Test
    void checkSearchInputClearIconTest() {
        open("/search");
        refresh();
        assert !searchPage.isClearIconVisible();
        searchPage.typeSearchQuery("qa.guru");
        assert searchPage.isClearIconVisible();
        searchPage.clickClearIconRight();
        assert searchPage.getSearchInputValue().isEmpty();
        assert !searchPage.isClearIconVisible();
    }

    @Test
    void noResultWithSearchingNonExistentRepoTest() {
        open("/search");
        refresh();
        searchPage.searchFor("*=*=*=*");
        searchResultsPage.verifyResultsContain("0 results");
    }
}
