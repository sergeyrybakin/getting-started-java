# Getting Started Java Project

This project demonstrates test automation with Selenide and includes Allure reporting capabilities.

It's forked project (see https://github.com/qa-guru/getting-started-java).

## Running Tests

To run tests:
```
./gradlew test
```

## Generating Allure Reports

To generate Allure reports, first run the tests to collect results, then:

1. Install Allure CLI globally (if not already installed):
   ```
   npm install -g allure-commandline
   ```

2. Run tests to collect results:
   ```
   ./gradlew test
   ```

3. Generate the report:
   ```
   allure serve
   ```

## Requirements

- Java 21
- Gradle 7+
- Node.js (for Allure CLI)

## Test Structure

The project contains:
- `TestBase.java` - Base test class with setup and teardown
- `SearchTests.java` - Main test cases
- `SearchPage.java` - Page object for search functionality
- `SearchResultsPage.java` - Page object for search results

## Allure Integration

Allure reports are configured through:
1. Added @Step annotations to all page methods for step logging
2. Added proper imports in TestBase.java for Allure integration
3. Updated .gitignore to exclude Allure report directories

Note: The tests may timeout on the GitHub website, which is expected behavior according to requirements.
