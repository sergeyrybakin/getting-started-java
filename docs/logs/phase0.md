### Фаза 0 — Baseline

Цель: понять, что у вас есть, и зафиксировать точку отсчёта.

[x] Прочитайте `build.gradle`, тесты, `.gitignore`, git-историю.
[x] Определите фактические версии Java/Gradle/зависимостей —
  не из предположений, а из файлов и `dependencies`-отчёта.
[x] Запустите исходный тест без изменений. Если упал — найдите
  причину до дальнейшей работы.
[x] Зафиксируйте результат в плане: команда, вывод, ограничения
  (внешний github.com нестабилен, возможен HTTP 429).

Критерий: есть задокументированный baseline с реальным
результатом запуска.

**Статус: завершена 22 октября 2026.** коммит 8f23ce81c751b017385c158206432613a973bdf5

### Исходное состояние репозитория

- Ветка `master`, HEAD `20511883a7b505aca582df5f9181f54474032f17` fork от `09be4d9` `qa-guru/getting-started-java`.
- Tracked-код: `build.gradle`, `src/test/java/SearchTests.java` (default package), `.gitignore` (`.gradle/`, `build/`).

### Изменения:
- Добавлены `AGENTS.md`, `docs/homework.md`, [план курса](docs/plans/ui-test-project.md), [логи из окна агента](docs/plans/phase0-report.md).
- В build.gradle версия Selenide изменена на 7.19.0, добавлен  toolchain для Java 21.

### Фактические версии

Источник — вывод команд, а не предположения.
- java --version
openjdk 21.0.12.1 2026-08-18
```
echo $JAVA_HOME
/usr/lib/jvm/java-21-openjdk-amd64
```

- gradle -v
Gradle 9.6.0
```
echo $GRADLE_HOME
/opt/gradle/gradle-9.6.0
```

- Браузер Chrome
```
google-chrome-stable --version
Google Chrome 155.0.8059.79
```

### Запустите исходный тест без изменений. Если упал — найдите причину до дальнейшей работы.

Тест упал. На локальном компьютере не было ChromeDriver. Установил в /usr/local/bin

- Chrome driver
```
chromedriver -v
ChromeDriver 155.0.8059.79 (a49e2e3d4addfd84e765b52afe230bedb81096db-refs/branch-heads/8059@{#1239})
```

Установил gradle wrapper
```
./gradlew -v
Gradle 9.6.0
```

Запустил тест ещё раз. Тест упал.

```
$ ./gradlew test -q
...
SearchTests > successfulSearchTest() FAILED
    com.codeborne.selenide.ex.ElementNotFound at SearchTests.java:12
        Caused by: org.openqa.selenium.NoSuchElementException at SearchTests.java:12

1 test completed, 1 failed
BUILD FAILED
```
Проверил что:
* локаторы, прописанные в SearchTests.java, верные.
* chromedriver находится из CLI.
* сеть работает.

Для остальных действий надо менять код. А это уже другая фаза.
