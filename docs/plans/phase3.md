### Фаза 3 — Page Object

Цель: читаемые сценарии, изолированные локаторы.

- Согласуйте стиль до реализации (не молча): fluent API,
  проверки в `should…`-методах страниц,
  `private final SelenideElement`-поля, имена методов —
  действия пользователя, компоненты — только при реальном
  повторении блоков.
- Минимум: `pages.SearchPage` (open/searchFor) и
  `pages.SearchResultsPage` (shouldHaveResult/shouldBeEmpty);
  тесты в package `tests`.
- Локаторы, assertions и порядок проверок — без изменений.

Проверка: все три теста зелёные, семантика идентична
коммиту до рефакторинга.

# Комментарии:

1. Задал вопрос нескольким ИИ на сайтах https://chat.qwen.ai, https://chat.deepseek.com, и google в режиме ИИ: какая локальная модель подойдёт лучше всего под моё "железо" для работы с ollama+zed и без нагрузки на swap?

google выдал только варианты chatGpt.

qwen выдал свои модели

deepseek выдал пару моделей qwen (что совпало с выдачей qwen!) + неизвестные мне модели. И выдал рекомендации по настройке ollama.

В итоге, скачал `qwen3:8b`. Мало того, что модель и не пыталась прочитать проект, она пыталась запустить автотесты с использованием mvn! нарушала требование не изменять значение timeout. В общем, работала быстро и бестолково, напоминая тупого инициативного студента-практиканта, который не слушает прямые приказы. (см getting-started-java/docs/plans/phase3-qwen3_8b-chat-history.md)

Скачал `qwen3-coder:30b-a3b-q4_K_M` (это вторая модель, которая совпала в списках qwen и deepseek). Работает не торопясь, но терпимо. Очень понравилась (getting-started-java/docs/plans/phase3-qwen3-coder_30b-a3b-q4_k_m.md). Но! У неё периодически выпадает ошибка:
`Failed to connect to Ollama API: 500 Internal Server Error {"error":"XML syntax error on line 62: element \u003cparameter\u003e closed by \u003c/function\u003e"}`

Оказалось, что это известная проблема. Пришлось обновлять ollama, и пробовать различные значения max_tocken в настройках zed.
