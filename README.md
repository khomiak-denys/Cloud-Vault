# CloudVault (Flutter)

Мобільний Flutter-застосунок для керування хмарними сховищами з єдиним UI: дашборд, пошук, аналітика, налаштування, модальні вікна, локалізація, світла/темна тема та екрани входу/реєстрації.

## Що вже реалізовано

- Екрани:
1. `Login`
2. `Register`
3. `Dashboard`
4. `Search`
5. `Analytics`
6. `Settings`

- Навігація:
1. Нижній `BottomNavBar` між основними екранами.
2. Перехід `Login -> Dashboard` та `Register -> Dashboard`.
3. Кнопка виходу в `Settings` повертає на `Login`.

- Модалки:
1. Додавання сховища.
2. Дії з файлом.
3. Інформація про файл.
4. Вибір мови.

- Стан і налаштування:
1. Перемикання світлої/темної теми.
2. Збереження теми через `SharedPreferences`.
3. Перемикання локалі `uk/en`.
4. Збереження локалі через `SharedPreferences`.

- Архітектурні покращення:
1. Екрани розбиті на дрібні секції та перевикористовувані віджети.
2. Мок-дані винесені в `lib/data`.
3. Спільні стилі/кольори винесені в тематичні утиліти.
4. Прибрано значну частину дублювання коду.

## Технології

- `Flutter` (Dart SDK `^3.10.0`)
- `Material 3`
- `intl` + `flutter_localizations`
- `shared_preferences`
- `firebase_core` (підготовлено `firebase_options.dart`)

## Структура проєкту

```text
lib/
  app.dart
  main.dart
  firebase_options.dart

  data/
    add_vault_mock_data.dart
    mock_data.dart
    recent_file_mock_data.dart
    storage_formatters.dart
    storage_usage_mock_data.dart
    vault_mock_data.dart

  l10n/
    app_en.arb
    app_uk.arb
    app_localizations*.dart

  models/
    add_vault_option.dart
    file_action_option.dart
    recent_file_item.dart
    storage_usage_item.dart
    vault_item.dart

  modals/
    add_vault_modal.dart
    file_actions_modal.dart
    file_info_modal.dart
    language_modal.dart

  screens/
    analytics_screen.dart
    cloud_vault_screen.dart
    login_screen.dart
    register_screen.dart
    search_screen.dart
    settings_screen.dart

  state/
    locale_controller.dart
    theme_controller.dart

  theme/
    app_theme_colors.dart

  utils/
    interaction_styles.dart
    tab_navigation.dart

  widgets/
    analytics/
    dashboard/
    search/
    settings/
    ...shared widgets
```

## Запуск локально

### 1. Вимоги

1. Flutter SDK (стабільний канал).
2. Xcode (для iOS) / Android Studio + SDK (для Android).
3. Dart SDK, який постачається з Flutter.

### 2. Встановлення залежностей

```bash
flutter pub get
```

### 3. Запуск

```bash
flutter run
```

### 4. Аналіз і тести

```bash
flutter analyze
flutter test
```

## Локалізація

Підтримуються локалі:

- `uk` (за замовчуванням)
- `en`

Де правити тексти:

- `lib/l10n/app_uk.arb`
- `lib/l10n/app_en.arb`

Після змін у ARB Flutter згенерує локалізації (у проєкті увімкнено `flutter: generate: true`).

## Тема (Light/Dark)

- Контролер: `lib/state/theme_controller.dart`.
- Джерело правди: `appThemeController`.
- Значення зберігається в `SharedPreferences` за ключем `theme_mode`.
- Поточна тема підхоплюється у `MaterialApp.themeMode` (`lib/app.dart`).

## Збереження локалі

- Контролер: `lib/state/locale_controller.dart`.
- Значення зберігається в `SharedPreferences` за ключем `app_locale`.
- Поточна локаль підхоплюється в `MaterialApp.locale` (`lib/app.dart`).

## Firebase: поточний статус

У проєкті вже є згенерований `lib/firebase_options.dart` і залежність `firebase_core`, але ініціалізація Firebase в `main.dart` зараз не викликається.

Щоб підключити Firebase повністю, додайте ініціалізацію в `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.wait([appThemeController.init(), appLocaleController.init()]);
  runApp(const CloudVaultApp());
}
```

Далі можна підключати `firebase_auth`, `cloud_firestore`, `firebase_storage` за потреби.

## Важливо про поточну бізнес-логіку

- `Login/Register` зараз працюють як UI-flow без реальної серверної авторизації.
- Дані сховищ/файлів зараз мокані (`lib/data/*mock*`).
- Частина дій (наприклад, деякі кнопки в модалках) є UI-заглушками.

## Рекомендований наступний крок

1. Ввімкнути реальну Firebase-авторизацію (`firebase_auth`).
2. Перенести мок-дані в репозиторії та джерело даних (`Firestore/REST`).
3. Додати віджет/юнiт тести для ключових сценаріїв: auth, theme, locale, file actions.
4. Додати CI (`flutter analyze`, `flutter test`) для кожного PR.

## Корисні команди

```bash
# Оновити залежності
flutter pub get

# Подивитись застарілі пакети
flutter pub outdated

# Статичний аналіз
flutter analyze

# Тести
flutter test

# Запуск на конкретному девайсі
flutter devices
flutter run -d <device_id>
```

## Ліцензія

Внутрішній проєкт. `publish_to: none`.

## Environment config (dart-define-from-file)

Use one of these files:
- `env/dev.json`
- `env/local.json` (local, gitignored)
- `env/prod.json`

JSON keys:
- `API_BASE_URL`
- `API_BEARER_TOKEN`
- `API_APP_CHECK_TOKEN`

Run examples:

```bash
flutter run --dart-define-from-file=env/dev.json
flutter run --dart-define-from-file=env/local.json
flutter run --release --dart-define-from-file=env/prod.json
```

In VS Code, use launch profile:
- `Flutter Dev (env/dev.json)`
- `Flutter Local (env/local.json)`
- `Flutter Prod (env/prod.json)`
