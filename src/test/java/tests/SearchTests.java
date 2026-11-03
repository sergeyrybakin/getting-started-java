package tests;

import org.junit.jupiter.api.Test;
import static com.codeborne.selenide.Selenide.open;
import static com.codeborne.selenide.Selenide.refresh;
import static org.junit.jupiter.api.Assertions.*;
import com.codeborne.selenide.Selenide;
import com.codeborne.selenide.Configuration;

import pages.SearchPage;
import pages.SearchResultsPage;

public class SearchTests extends TestBase {
    private SearchPage searchPage = new SearchPage();
    private SearchResultsPage searchResultsPage = new SearchResultsPage();
    private static final String OPEN_URL_LOCATOR = Configuration.baseUrl+"/search";
    private static final String SEARCH_CRITERION = "qa.guru";

    @Test
    void successfulSearchTest() {
        open(OPEN_URL_LOCATOR);
        searchPage.searchFor(SEARCH_CRITERION).verifyResultsContain(SEARCH_CRITERION);
    }

    @Test
    void checkSearchInputClearIconTest() {
        open(OPEN_URL_LOCATOR);
        searchPage.verifyClearIconHidden()
                .typeSearchQuery(SEARCH_CRITERION)
                .verifyClearIconVisible()
                .clickClearIcon()
                .verifySearchInputEmpty()
                .verifyClearIconHidden();
    }

    @Test
    void noResultWithSearchingNonExistentRepoTest() {
        open(OPEN_URL_LOCATOR);
        searchPage.searchFor("*=*=*=*");
        searchResultsPage.verifyResultsCount("0 results ");
    }
}
