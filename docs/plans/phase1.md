## Фаза 1 — TestBase

**Статус: **

**Коммит: **

- [x] Добавить штатный Gradle Wrapper 9.6.0 с официальным checksum и executable bit для gradlew.
- [x] Зафиксировать Java 21 toolchain.
- [x] Добавить TestBase: настройка Selenide в @BeforeEach, closeWebDriver в @AfterEach.
- [] Передавать только четыре согласованных свойства в JVM тестов.
- [x] Подключить TestBase к SearchTests и заменить абсолютный URL на /search.
- [] Проверить defaults, переопределение свойств и использование baseUrl внутри JVM тестов.
- [] Проверить отсутствие запуска браузера при настройке, изоляцию сессий и cleanup после успеха и контролируемого падения.
- [] Удалить временную диагностику, восстановить исходный assertion, повторить успешные запуски и создать отдельный коммит без push.

# Критерий: По отчёту оба финальных запуска завершились BUILD SUCCESSFUL:

```bash
./gradlew test --tests SearchTests.successfulSearchTest --rerun-tasks --console=plain
./gradlew test --tests SearchTests.successfulSearchTest -DbaseUrl=https://www.github.com -Dbrowser=chrome -DbrowserSize=1366x768 -Dheadless=true --rerun-tasks --console=plain
```

# Ограничения: ????

# Комментарии:

1. Gradle-wrapper был добавлен в **Фазе 0**
2. Из-за несовпадения в homework.md и ui-test-project.md задачу согласования параметров, стиля PageObject выполнил в **Фазе 1**
3. Добавил каталог для Page объектов. Он пока пустой.
4. Добавил TestBase с @BeforeEach, в котором передаются настройки web driver, и @AfterEach, в котором драйвер закрывается после каждого прогона.
