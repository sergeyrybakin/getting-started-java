package components;

import com.codeborne.selenide.ElementsCollection;
import static com.codeborne.selenide.Selenide.$$;
import static com.codeborne.selenide.Condition.text;

public class SearchTabs {
    private static final String TAB_LABEL_LOCATOR = "span.v2-tabs__label";

    private final ElementsCollection tabLabel = $$(TAB_LABEL_LOCATOR);

    public SearchTabs openTab(String labelName) {
        tabLabel.findBy(text(labelName)).click();
        return this;
    }
}
