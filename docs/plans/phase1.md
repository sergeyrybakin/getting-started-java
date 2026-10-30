## Фаза 1 — TestBase

**Статус: завершена 23 октября 2026г.** коммит 0e249ad11a539410d9b0aa4899b35f0819c5b8b0

- [x] Добавить штатный Gradle Wrapper 9.6.0 с официальным checksum и executable bit для gradlew.
- [x] Зафиксировать Java 21 toolchain.
- [x] Добавить TestBase: настройка Selenide в @BeforeEach, closeWebDriver в @AfterEach.
- [-] Передавать только четыре согласованных свойства в JVM тестов.
- [x] Подключить TestBase к SearchTests и заменить абсолютный URL на /search.
- [x] Проверить defaults, переопределение свойств и использование baseUrl внутри JVM тестов.
- [x] Проверить отсутствие запуска браузера при настройке, изоляцию сессий и cleanup после успеха и контролируемого падения.
- [x] Удалить временную диагностику, восстановить исходный assertion, повторить успешные запуски и создать отдельный коммит без push.

# Критерий: По отчёту оба финальных запуска завершились BUILD SUCCESSFUL:

```bash
./gradlew test --tests SearchTests.successfulSearchTest --rerun-tasks --console=plain
./gradlew test --tests SearchTests.successfulSearchTest -DbaseUrl=https://www.github.com -Dbrowser=chrome -DbrowserSize=1366x768 -Dheadless=true --rerun-tasks --console=plain
```

# Локальный прогон (2026-10-23)

```bash
./gradlew clean test --rerun-tasks -Dselenide.browserSize=1366x768 -Dselenide.headless=false -i
```

- Итог: `BUILD SUCCESSFUL in 7s`, 4 actionable tasks: 4 executed.
- `SystemPropsTest.printSelenideProps` — passed: в JVM тестов проброшены `selenide.browserSize=1366x768` и `selenide.headless=false`.
- `pages.SearchTests.successfulSearchTest` — passed (5.8 s): Chrome, headful, 1366x768, поиск «qa.guru» найден.
- Примечание: `src/test/resources/selenide.properties` содержит `selenide.headless=true`, но `TestBase.setUp()` задаёт `Configuration.*` из системных свойств, поэтому фактическое поведение соответствует `-D`-параметрам.
- Единственное предупреждение — SLF4J без провайдера (NOP-логгер); на результат не влияет.

# Локальный прогон после перестановки TestBase и SearchResultsPage (2026-10-23)

Перестановка перед прогоном:
- `TestBase` перенесён из `src/test/java/pages` в `src/test/java` (default-пакет); `package pages;` удалён.
- `SearchTests` теперь в default-пакете (совпадает с расположением файла), наследует `TestBase` без импорта; `package pages;` в нём удалён — импорт из default-пакета невозможен, поэтому это следствие переноса.
- Создан `pages/SearchResultsPage`: проверка результата поиска (`resultsList`, `verifyResultsContain`) перенесена из `SearchPage`.
- `SearchPage` оставлен только с действием поиска (`searchInput`, `searchFor`).

```bash
./gradlew clean test --rerun-tasks -Dselenide.headless=false -i
```

- Итог: `BUILD SUCCESSFUL in 13s`, 4 actionable tasks: 4 executed.
- `SearchTests.successfulSearchTest` — passed (12.9 s, Chrome headful).
- `SystemPropsTest.printSelenideProps` — passed; проброшен только `selenide.headless=false` (параметр размера не передавался).
- Разрешение браузера: `1920x1200` — в этой команде `-Dselenide.browserSize` не задан, поэтому применяется дефолт `TestBase.setUp()` (`System.getProperty("selenide.browserSize", "1920x1200")`); совпадает с дефолтом в `selenide.properties`.
- Снова SLF4J NOP-логгер — предупреждение, на результат не влияет.

# Контролируемый прогон с неверным baseUrl (2026-10-23)

Цель: подтвердить, что `selenide.baseUrl` пробрасывается в JVM тестов, и что при неверном URL тест падает.

```bash
./gradlew clean test --rerun-tasks -Dselenide.baseUrl=https://d3.ru -i
```

- Итог: `BUILD FAILED in 16s` (ожидаемое падение), 2 tests completed, 1 failed.
- `SearchTests.successfulSearchTest` — FAILED: `Element not found {input[aria-label='Search GitHub']}` (timeout 10s, `NoSuchElementException`) — браузер открыл `https://d3.ru` вместо github.com, элемента поиска GitHub там нет.
- `SystemPropsTest.printSelenideProps` — passed; в stdout напечатано `selenide.baseUrl=https://d3.ru` — прямое доказательство проброса свойства из Gradle в JVM тестов.
- Вывод: переопределение `selenide.baseUrl` через `-D` работает как согласовано (через `TestBase.setUp()`); падение — управляемое, кода не изменялось.

# Ограничения: ????

# Комментарии:

1. Gradle-wrapper был добавлен в **Фазе 0**
2. Из-за несовпадения в homework.md и ui-test-project.md задачу согласования параметров, стиля PageObject выполнил в **Фазе 1**
3. Добавил каталог для Page объектов. Он пока пустой.
4. Добавил TestBase с @BeforeEach, в котором передаются настройки web driver, и @AfterEach, в котором драйвер закрывается после каждого прогона.
5. **Обнаружил, что модели qwen2.5-coder:7b qwen2.5-coder:14b не желают работать в агентском режиме на моём компьютере!** Попробовал qwen3-coder:30b. С ним происходили падения.
