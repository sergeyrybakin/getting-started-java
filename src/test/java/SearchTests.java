import org.junit.jupiter.api.Test;
import static com.codeborne.selenide.Selenide.open;
import static com.codeborne.selenide.Selenide.refresh;

import pages.SearchPage;
import pages.SearchResultsPage;

public class SearchTests extends TestBase {
    private SearchPage searchPage = new SearchPage();
    private SearchResultsPage searchResultsPage = new SearchResultsPage();

    @Test
    void successfulSearchTest() {
        open("/search");
        refresh();
        searchPage.searchFor("qa.guru");
        searchResultsPage.verifyResultsContain("QA.GURU");
    }
}
