package tests;

import org.junit.jupiter.api.Test;
import io.qameta.allure.Allure;
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
    private static final String SEARCH_CRITERION = "фотF";

    @Test
    void successfulSearchTest() {
        Allure.step("Открыть страницу поиска: " + OPEN_URL_LOCATOR, () -> open(OPEN_URL_LOCATOR));
        Allure.step("Выполнить поиск: " + SEARCH_CRITERION, () -> searchPage.searchFor(SEARCH_CRITERION));
        Allure.step("Проверить результаты поиска: " + SEARCH_CRITERION,
                () -> searchResultsPage.verifyResultsContain(SEARCH_CRITERION));
    }

    @Test
    void verifyTabsPlaceHoldersTest() {
        Allure.step("Открыть страницу поиска: " + OPEN_URL_LOCATOR, () -> open(OPEN_URL_LOCATOR));
        Allure.step("Открыть вкладку поиска: Комментарии", () -> searchPage.openSearchTab("Комментарии"));
    }

    @Test
    void noResultWithSearchingNonExistentArticleTest() {
        Allure.step("Открыть страницу поиска: " + OPEN_URL_LOCATOR, () -> open(OPEN_URL_LOCATOR));
        Allure.step("Выполнить поиск: *=*=*=*", () -> searchPage.searchFor("*=*=*=*"));
        Allure.step("Проверить результат: Посты не найдены",
                () -> searchResultsPage.verifyResultsContain("Посты не найдены"));
    }
}
