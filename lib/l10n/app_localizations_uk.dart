// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'CloudVault';

  @override
  String get navHome => 'Головна';

  @override
  String get navSearch => 'Пошук';

  @override
  String get navAnalytics => 'Аналітика';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get manageClouds => 'Керуйте всіма хмарами';

  @override
  String get totalUsed => 'Всього використано';

  @override
  String get myStorages => 'Мої сховища';

  @override
  String get add => 'Додати';

  @override
  String get used => 'Використано';

  @override
  String get recentFiles => 'Нещодавні файли';

  @override
  String get addStorage => 'Додати сховище';

  @override
  String get chooseCloudStorage =>
      'Виберіть хмарне сховище, яке ви хочете підключити';

  @override
  String get connect => 'Підключити';

  @override
  String get cancel => 'Скасувати';

  @override
  String get search => 'Пошук';

  @override
  String get searchHint => 'Пошук файлів';

  @override
  String get all => 'Всі';

  @override
  String get documents => 'Документи';

  @override
  String get images => 'Зображення';

  @override
  String get videos => 'Відео';

  @override
  String get sortByType => 'Тип (A-Z)';

  @override
  String foundFiles(Object count) {
    return 'Знайдено $count файлів';
  }

  @override
  String get analytics => 'Аналітика';

  @override
  String get analyticsSubtitle => 'Статистика використання сховищ';

  @override
  String get totalSpace => 'Всього простору';

  @override
  String get usedSpace => 'Використано';

  @override
  String get freeSpace => 'Вільно';

  @override
  String get warning => 'Увага!';

  @override
  String warningBody(Object storages) {
    return '$storages майже заповнені. Розгляньте можливість очистки або розширення.';
  }

  @override
  String get distributionByStorage => 'Розподіл по сховищах';

  @override
  String get usageVsFree => 'Використання vs Вільний простір';

  @override
  String get recommendations => 'Рекомендації';

  @override
  String get exportPdf => 'Експорт PDF';

  @override
  String get pdfReportTitle => 'Звіт про використання сховищ';

  @override
  String get generatedAt => 'Згенеровано';

  @override
  String get pdfExportFailed => 'Не вдалося експортувати PDF';

  @override
  String get tipOptimizeDropboxTitle => 'Оптимізуйте Dropbox';

  @override
  String get tipOptimizeDropboxBody =>
      'Ваш Dropbox заповнений на 90%. Видаліть старі файли або оновіть тариф.';

  @override
  String get tipUseIcloudTitle => 'Використовуйте iCloud';

  @override
  String get tipUseIcloudBody =>
      'У вас є 4.2 ГБ вільного місця в iCloud. Перемістіть туди великі файли.';

  @override
  String get settings => 'Налаштування';

  @override
  String get connectedStorages => 'Підключені сховища';

  @override
  String get connected => 'Підключено';

  @override
  String get account => 'АКАУНТ';

  @override
  String get preferences => 'НАЛАШТУВАННЯ';

  @override
  String get other => 'ІНШЕ';

  @override
  String get profile => 'Профіль';

  @override
  String get profileEdit => 'Редагувати';

  @override
  String get profileSave => 'Зберегти';

  @override
  String get profileSaved => 'Профіль оновлено';

  @override
  String get profilePersonalInfo => 'Особиста інформація';

  @override
  String get profileFilesStat => 'Файлів';

  @override
  String get profileStoragesStat => 'Сховищ';

  @override
  String get language => 'Мова';

  @override
  String get chooseLanguage => 'Оберіть мову застосунку';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get languageEnglish => 'Англійська';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get darkTheme => 'Темна тема';

  @override
  String get privacy => 'Конфіденційність';

  @override
  String get helpSupport => 'Довідка та підтримка';

  @override
  String get logout => 'Вийти';

  @override
  String get enabled => 'Увімкнено';

  @override
  String get disabled => 'Вимкнено';

  @override
  String get premiumPlan => 'Преміум план';

  @override
  String get premiumValidUntil => 'Дійсний до 23 лютого 2027';

  @override
  String get pro => 'PRO';

  @override
  String get profileName => 'Іван Петренко';

  @override
  String get profileEmail => 'ivan.petrenko@email.com';

  @override
  String get appVersion => 'CloudVault v1.0.0';

  @override
  String get themeEnabledToast => 'Темну тему увімкнено';

  @override
  String get themeDisabledToast => 'Світлу тему увімкнено';

  @override
  String get notificationsEnabledToast => 'Сповіщення увімкнено';

  @override
  String get notificationsDisabledToast => 'Сповіщення вимкнено';

  @override
  String disconnectedToast(Object storage) {
    return '$storage відключено';
  }

  @override
  String get fileActionsRemoveStar => 'Прибрати зірочку';

  @override
  String get fileActionsAddStar => 'Додати зірочку';

  @override
  String get fileActionsDownload => 'Завантажити';

  @override
  String get fileActionsShare => 'Поділитися';

  @override
  String get fileActionsCopyTo => 'Копіювати в...';

  @override
  String get fileActionsRename => 'Перейменувати';

  @override
  String get fileActionsInfo => 'Інформація';

  @override
  String get fileActionsDelete => 'Видалити';

  @override
  String get fileInfo => 'Інформація про файл';

  @override
  String get size => 'Розмір';

  @override
  String get modified => 'Змінено';

  @override
  String get path => 'Шлях';

  @override
  String get close => 'Закрити';

  @override
  String get authLoginTitle => 'Вхід';

  @override
  String get authLoginSubtitle => 'Увійдіть у ваш CloudVault акаунт';

  @override
  String get authRegisterTitle => 'Реєстрація';

  @override
  String get authRegisterSubtitle => 'Почніть керувати всіма своїми хмарами';

  @override
  String get authName => 'Ім\'я';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authConfirmPassword => 'Підтвердіть пароль';

  @override
  String get authSignIn => 'Увійти';

  @override
  String get authSignUp => 'Зареєструватися';

  @override
  String get authGoRegister => 'Ще немає акаунта? Зареєструватися';

  @override
  String get authGoLogin => 'Вже маєте акаунт? Увійти';

  @override
  String get authAllCloudsOnePlace => 'Всі хмари в одному місці';

  @override
  String get authRememberMe => 'Запам\'ятати мене';

  @override
  String get authForgotPassword => 'Забули пароль?';

  @override
  String get authAgreeWith => 'Я погоджуюсь з';

  @override
  String get authTerms => 'умовами використання';

  @override
  String get authAnd => 'та';

  @override
  String get authPrivacyPolicy => 'політикою конфіденційності';

  @override
  String get storageBrowserRoot => 'Корінь';

  @override
  String get storageBrowserUp => 'Вгору';

  @override
  String get storageBrowserNewFolder => 'Нова папка';

  @override
  String get storageBrowserUpload => 'Завантажити';

  @override
  String get storageBrowserEmptyFolder => 'Папка порожня';

  @override
  String get storageBrowserCreateFolderTitle => 'Створити папку';

  @override
  String get storageBrowserCreateFolderHint => 'Назва папки';

  @override
  String get storageBrowserCreateFolderAction => 'Створити';

  @override
  String get storageBrowserFolderCreated => 'Папку створено';

  @override
  String get storageBrowserUploadNotConfigured =>
      'Завантаження ще не налаштовано';

  @override
  String get storageBrowserLoadFailed => 'Не вдалося завантажити папку';

  @override
  String get storageBrowserCreateFolderFailed => 'Не вдалося створити папку';

  @override
  String storageBrowserApiError(Object message, Object status) {
    return 'Помилка API: $status $message';
  }

  @override
  String get filePreviewLoading => 'Завантаження перегляду...';

  @override
  String get filePreviewFolderUnsupported =>
      'Попередній перегляд папки недоступний';

  @override
  String get filePreviewUnavailable => 'Попередній перегляд недоступний';

  @override
  String get filePreviewOpenExternal => 'Відкрити зовні';

  @override
  String get filePreviewLoadFailed =>
      'Не вдалося завантажити попередній перегляд';

  @override
  String get filePreviewUnsupportedType =>
      'Цей тип файлу не підтримується для вбудованого перегляду';

  @override
  String get filePreviewPdfLoadFailed =>
      'Не вдалося завантажити PDF для перегляду';

  @override
  String get filePreviewPdfTooLarge =>
      'PDF завеликий для вбудованого перегляду. Відкрийте зовні.';

  @override
  String get filePreviewDownloadTimeout =>
      'Тайм-аут завантаження попереднього перегляду. Спробуйте відкрити зовні.';

  @override
  String get filePreviewBlockedUrlScheme =>
      'Схему URL заблоковано з міркувань безпеки.';

  @override
  String get filePreviewVideoInitFailed =>
      'Не вдалося ініціалізувати перегляд відео';

  @override
  String get filePreviewPlay => 'Відтворити';

  @override
  String get filePreviewPause => 'Пауза';

  @override
  String filePreviewApiError(Object message, Object status) {
    return 'Помилка API: $status $message';
  }
}
