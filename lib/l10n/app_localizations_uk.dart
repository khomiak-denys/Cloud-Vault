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
  String get navHome => 'Р“РѕР»РѕРІРЅР°';

  @override
  String get navSearch => 'РџРѕС€СѓРє';

  @override
  String get navAnalytics => 'РђРЅР°Р»С–С‚РёРєР°';

  @override
  String get navSettings => 'РќР°Р»Р°С€С‚СѓРІР°РЅРЅСЏ';

  @override
  String get manageClouds => 'РљРµСЂСѓР№С‚Рµ РІСЃС–РјР° С…РјР°СЂР°РјРё';

  @override
  String get totalUsed => 'Р’СЃСЊРѕРіРѕ РІРёРєРѕСЂРёСЃС‚Р°РЅРѕ';

  @override
  String get myStorages => 'РњРѕС— СЃС…РѕРІРёС‰Р°';

  @override
  String get add => 'Р”РѕРґР°С‚Рё';

  @override
  String get used => 'Р’РёРєРѕСЂРёСЃС‚Р°РЅРѕ';

  @override
  String get recentFiles => 'РќРµС‰РѕРґР°РІРЅС– С„Р°Р№Р»Рё';

  @override
  String get addStorage => 'Р”РѕРґР°С‚Рё СЃС…РѕРІРёС‰Рµ';

  @override
  String get chooseCloudStorage =>
      'Р’РёР±РµСЂС–С‚СЊ С…РјР°СЂРЅРµ СЃС…РѕРІРёС‰Рµ, СЏРєРµ РІРё С…РѕС‡РµС‚Рµ РїС–РґРєР»СЋС‡РёС‚Рё';

  @override
  String get connect => 'РџС–РґРєР»СЋС‡РёС‚Рё';

  @override
  String get cancel => 'РЎРєР°СЃСѓРІР°С‚Рё';

  @override
  String get search => 'РџРѕС€СѓРє';

  @override
  String get searchHint => 'РџРѕС€СѓРє С„Р°Р№Р»С–РІ';

  @override
  String get all => 'Р’СЃС–';

  @override
  String get documents => 'Р”РѕРєСѓРјРµРЅС‚Рё';

  @override
  String get images => 'Р—РѕР±СЂР°Р¶РµРЅРЅСЏ';

  @override
  String get videos => 'Р’С–РґРµРѕ';

  @override
  String get sortByType => 'РўРёРї (A-Z)';

  @override
  String foundFiles(Object count) {
    return 'Р—РЅР°Р№РґРµРЅРѕ $count С„Р°Р№Р»С–РІ';
  }

  @override
  String get analytics => 'РђРЅР°Р»С–С‚РёРєР°';

  @override
  String get analyticsSubtitle =>
      'РЎС‚Р°С‚РёСЃС‚РёРєР° РІРёРєРѕСЂРёСЃС‚Р°РЅРЅСЏ СЃС…РѕРІРёС‰';

  @override
  String get totalSpace => 'Р’СЃСЊРѕРіРѕ РїСЂРѕСЃС‚РѕСЂСѓ';

  @override
  String get usedSpace => 'Р’РёРєРѕСЂРёСЃС‚Р°РЅРѕ';

  @override
  String get freeSpace => 'Р’С–Р»СЊРЅРѕ';

  @override
  String get warning => 'РЈРІР°РіР°!';

  @override
  String warningBody(Object storages) {
    return '$storages РјР°Р№Р¶Рµ Р·Р°РїРѕРІРЅРµРЅС–. Р РѕР·РіР»СЏРЅСЊС‚Рµ РјРѕР¶Р»РёРІС–СЃС‚СЊ РѕС‡РёСЃС‚РєРё Р°Р±Рѕ СЂРѕР·С€РёСЂРµРЅРЅСЏ.';
  }

  @override
  String get distributionByStorage => 'Р РѕР·РїРѕРґС–Р» РїРѕ СЃС…РѕРІРёС‰Р°С…';

  @override
  String get usageVsFree =>
      'Р’РёРєРѕСЂРёСЃС‚Р°РЅРЅСЏ vs Р’С–Р»СЊРЅРёР№ РїСЂРѕСЃС‚С–СЂ';

  @override
  String get recommendations => 'Р РµРєРѕРјРµРЅРґР°С†С–С—';

  @override
  String get exportPdf => 'Р•РєСЃРїРѕСЂС‚ PDF';

  @override
  String get pdfReportTitle =>
      'Р—РІС–С‚ РїСЂРѕ РІРёРєРѕСЂРёСЃС‚Р°РЅРЅСЏ СЃС…РѕРІРёС‰';

  @override
  String get generatedAt => 'Р—РіРµРЅРµСЂРѕРІР°РЅРѕ';

  @override
  String get pdfExportFailed =>
      'РќРµ РІРґР°Р»РѕСЃСЏ РµРєСЃРїРѕСЂС‚СѓРІР°С‚Рё PDF';

  @override
  String get tipOptimizeDropboxTitle => 'РћРїС‚РёРјС–Р·СѓР№С‚Рµ Dropbox';

  @override
  String get tipOptimizeDropboxBody =>
      'Р’Р°С€ Dropbox Р·Р°РїРѕРІРЅРµРЅРёР№ РЅР° 90%. Р’РёРґР°Р»С–С‚СЊ СЃС‚Р°СЂС– С„Р°Р№Р»Рё Р°Р±Рѕ РѕРЅРѕРІС–С‚СЊ С‚Р°СЂРёС„.';

  @override
  String get tipUseIcloudTitle => 'Р’РёРєРѕСЂРёСЃС‚РѕРІСѓР№С‚Рµ iCloud';

  @override
  String get tipUseIcloudBody =>
      'РЈ РІР°СЃ С” 4.2 Р“Р‘ РІС–Р»СЊРЅРѕРіРѕ РјС–СЃС†СЏ РІ iCloud. РџРµСЂРµРјС–СЃС‚С–С‚СЊ С‚СѓРґРё РІРµР»РёРєС– С„Р°Р№Р»Рё.';

  @override
  String get settings => 'РќР°Р»Р°С€С‚СѓРІР°РЅРЅСЏ';

  @override
  String get connectedStorages => 'РџС–РґРєР»СЋС‡РµРЅС– СЃС…РѕРІРёС‰Р°';

  @override
  String get connected => 'РџС–РґРєР»СЋС‡РµРЅРѕ';

  @override
  String get account => 'РђРљРђРЈРќРў';

  @override
  String get preferences => 'РќРђР›РђРЁРўРЈР’РђРќРќРЇ';

  @override
  String get other => 'Р†РќРЁР•';

  @override
  String get profile => 'РџСЂРѕС„С–Р»СЊ';

  @override
  String get profileEdit => 'Р РµРґР°РіСѓРІР°С‚Рё';

  @override
  String get profileSave => 'Р—Р±РµСЂРµРіС‚Рё';

  @override
  String get profileSaved => 'РџСЂРѕС„С–Р»СЊ РѕРЅРѕРІР»РµРЅРѕ';

  @override
  String get profilePersonalInfo => 'РћСЃРѕР±РёСЃС‚Р° С–РЅС„РѕСЂРјР°С†С–СЏ';

  @override
  String get profileFilesStat => 'Р¤Р°Р№Р»С–РІ';

  @override
  String get profileStoragesStat => 'РЎС…РѕРІРёС‰';

  @override
  String get language => 'РњРѕРІР°';

  @override
  String get chooseLanguage => 'РћР±РµСЂС–С‚СЊ РјРѕРІСѓ Р·Р°СЃС‚РѕСЃСѓРЅРєСѓ';

  @override
  String get languageUkrainian => 'РЈРєСЂР°С—РЅСЃСЊРєР°';

  @override
  String get languageEnglish => 'РђРЅРіР»С–Р№СЃСЊРєР°';

  @override
  String get notifications => 'РЎРїРѕРІС–С‰РµРЅРЅСЏ';

  @override
  String get darkTheme => 'РўРµРјРЅР° С‚РµРјР°';

  @override
  String get privacy => 'РљРѕРЅС„С–РґРµРЅС†С–Р№РЅС–СЃС‚СЊ';

  @override
  String get helpSupport => 'Р”РѕРІС–РґРєР° С‚Р° РїС–РґС‚СЂРёРјРєР°';

  @override
  String get logout => 'Р’РёР№С‚Рё';

  @override
  String get enabled => 'РЈРІС–РјРєРЅРµРЅРѕ';

  @override
  String get disabled => 'Р’РёРјРєРЅРµРЅРѕ';

  @override
  String get premiumPlan => 'РџСЂРµРјС–СѓРј РїР»Р°РЅ';

  @override
  String get premiumValidUntil => 'Р”С–Р№СЃРЅРёР№ РґРѕ 23 Р»СЋС‚РѕРіРѕ 2027';

  @override
  String get pro => 'PRO';

  @override
  String get profileName => 'Р†РІР°РЅ РџРµС‚СЂРµРЅРєРѕ';

  @override
  String get profileEmail => 'ivan.petrenko@email.com';

  @override
  String get appVersion => 'CloudVault v1.0.0';

  @override
  String get themeEnabledToast => 'РўРµРјРЅСѓ С‚РµРјСѓ СѓРІС–РјРєРЅРµРЅРѕ';

  @override
  String get themeDisabledToast => 'РЎРІС–С‚Р»Сѓ С‚РµРјСѓ СѓРІС–РјРєРЅРµРЅРѕ';

  @override
  String get notificationsEnabledToast =>
      'РЎРїРѕРІС–С‰РµРЅРЅСЏ СѓРІС–РјРєРЅРµРЅРѕ';

  @override
  String get notificationsDisabledToast =>
      'РЎРїРѕРІС–С‰РµРЅРЅСЏ РІРёРјРєРЅРµРЅРѕ';

  @override
  String disconnectedToast(Object storage) {
    return '$storage РІС–РґРєР»СЋС‡РµРЅРѕ';
  }

  @override
  String get fileActionsRemoveStar => 'РџСЂРёР±СЂР°С‚Рё Р·С–СЂРѕС‡РєСѓ';

  @override
  String get fileActionsAddStar => 'Р”РѕРґР°С‚Рё Р·С–СЂРѕС‡РєСѓ';

  @override
  String get fileActionsDownload => 'Р—Р°РІР°РЅС‚Р°Р¶РёС‚Рё';

  @override
  String get fileActionsShare => 'РџРѕРґС–Р»РёС‚РёСЃСЏ';

  @override
  String get fileActionsCopyTo => 'РљРѕРїС–СЋРІР°С‚Рё РІ...';

  @override
  String get fileActionsRename => 'РџРµСЂРµР№РјРµРЅСѓРІР°С‚Рё';

  @override
  String get fileActionsInfo => 'Р†РЅС„РѕСЂРјР°С†С–СЏ';

  @override
  String get fileActionsDelete => 'Р’РёРґР°Р»РёС‚Рё';

  @override
  String get fileInfo => 'Р†РЅС„РѕСЂРјР°С†С–СЏ РїСЂРѕ С„Р°Р№Р»';

  @override
  String get size => 'Р РѕР·РјС–СЂ';

  @override
  String get modified => 'Р—РјС–РЅРµРЅРѕ';

  @override
  String get path => 'РЁР»СЏС…';

  @override
  String get close => 'Р—Р°РєСЂРёС‚Рё';

  @override
  String get authLoginTitle => 'Р’С…С–Рґ';

  @override
  String get authLoginSubtitle =>
      'РЈРІС–Р№РґС–С‚СЊ Сѓ РІР°С€ CloudVault Р°РєР°СѓРЅС‚';

  @override
  String get authRegisterTitle => 'Р РµС”СЃС‚СЂР°С†С–СЏ';

  @override
  String get authRegisterSubtitle =>
      'РџРѕС‡РЅС–С‚СЊ РєРµСЂСѓРІР°С‚Рё РІСЃС–РјР° СЃРІРѕС—РјРё С…РјР°СЂР°РјРё';

  @override
  String get authName => 'Р†Рј\'СЏ';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'РџР°СЂРѕР»СЊ';

  @override
  String get authConfirmPassword => 'РџС–РґС‚РІРµСЂРґС–С‚СЊ РїР°СЂРѕР»СЊ';

  @override
  String get authSignIn => 'РЈРІС–Р№С‚Рё';

  @override
  String get authSignUp => 'Р—Р°СЂРµС”СЃС‚СЂСѓРІР°С‚РёСЃСЏ';

  @override
  String get authGoRegister =>
      'Р©Рµ РЅРµРјР°С” Р°РєР°СѓРЅС‚Р°? Р—Р°СЂРµС”СЃС‚СЂСѓРІР°С‚РёСЃСЏ';

  @override
  String get authGoLogin => 'Р’Р¶Рµ РјР°С”С‚Рµ Р°РєР°СѓРЅС‚? РЈРІС–Р№С‚Рё';

  @override
  String get authAllCloudsOnePlace =>
      'Р’СЃС– С…РјР°СЂРё РІ РѕРґРЅРѕРјСѓ РјС–СЃС†С–';

  @override
  String get authRememberMe => 'Р—Р°РїР°Рј\'СЏС‚Р°С‚Рё РјРµРЅРµ';

  @override
  String get authForgotPassword => 'Р—Р°Р±СѓР»Рё РїР°СЂРѕР»СЊ?';

  @override
  String get authAgreeWith => 'РЇ РїРѕРіРѕРґР¶СѓСЋСЃСЊ Р·';

  @override
  String get authTerms => 'СѓРјРѕРІР°РјРё РІРёРєРѕСЂРёСЃС‚Р°РЅРЅСЏ';

  @override
  String get authAnd => 'С‚Р°';

  @override
  String get authPrivacyPolicy =>
      'РїРѕР»С–С‚РёРєРѕСЋ РєРѕРЅС„С–РґРµРЅС†С–Р№РЅРѕСЃС‚С–';

  @override
  String get storageBrowserRoot => 'РљРѕСЂС–РЅСЊ';

  @override
  String get storageBrowserUp => 'Р’РіРѕСЂСѓ';

  @override
  String get storageBrowserNewFolder => 'РќРѕРІР° РїР°РїРєР°';

  @override
  String get storageBrowserUpload => 'Р—Р°РІР°РЅС‚Р°Р¶РёС‚Рё';

  @override
  String get storageBrowserEmptyFolder => 'РџР°РїРєР° РїРѕСЂРѕР¶РЅСЏ';

  @override
  String get storageBrowserCreateFolderTitle => 'РЎС‚РІРѕСЂРёС‚Рё РїР°РїРєСѓ';

  @override
  String get storageBrowserCreateFolderHint => 'РќР°Р·РІР° РїР°РїРєРё';

  @override
  String get storageBrowserCreateFolderAction => 'РЎС‚РІРѕСЂРёС‚Рё';

  @override
  String get storageBrowserFolderCreated => 'РџР°РїРєСѓ СЃС‚РІРѕСЂРµРЅРѕ';

  @override
  String get storageBrowserUploadNotConfigured =>
      'Р—Р°РІР°РЅС‚Р°Р¶РµРЅРЅСЏ С‰Рµ РЅРµ РЅР°Р»Р°С€С‚РѕРІР°РЅРѕ';

  @override
  String get storageBrowserLoadFailed =>
      'РќРµ РІРґР°Р»РѕСЃСЏ Р·Р°РІР°РЅС‚Р°Р¶РёС‚Рё РїР°РїРєСѓ';

  @override
  String get storageBrowserCreateFolderFailed =>
      'РќРµ РІРґР°Р»РѕСЃСЏ СЃС‚РІРѕСЂРёС‚Рё РїР°РїРєСѓ';

  @override
  String storageBrowserApiError(Object message, Object status) {
    return 'РџРѕРјРёР»РєР° API: $status $message';
  }

  @override
  String get filePreviewLoading =>
      'Р—Р°РІР°РЅС‚Р°Р¶РµРЅРЅСЏ РїРµСЂРµРіР»СЏРґСѓ...';

  @override
  String get filePreviewFolderUnsupported =>
      'РџРѕРїРµСЂРµРґРЅС–Р№ РїРµСЂРµРіР»СЏРґ РїР°РїРєРё РЅРµРґРѕСЃС‚СѓРїРЅРёР№';

  @override
  String get filePreviewUnavailable =>
      'РџРѕРїРµСЂРµРґРЅС–Р№ РїРµСЂРµРіР»СЏРґ РЅРµРґРѕСЃС‚СѓРїРЅРёР№';

  @override
  String get filePreviewOpenExternal => 'Р’С–РґРєСЂРёС‚Рё Р·РѕРІРЅС–';

  @override
  String get filePreviewOpenExternalFailed =>
      'РќРµ РІРґР°Р»РѕСЃСЏ РІС–РґРєСЂРёС‚Рё Р·РѕРІРЅС–';

  @override
  String get filePreviewLoadFailed =>
      'РќРµ РІРґР°Р»РѕСЃСЏ Р·Р°РІР°РЅС‚Р°Р¶РёС‚Рё РїРѕРїРµСЂРµРґРЅС–Р№ РїРµСЂРµРіР»СЏРґ';

  @override
  String get filePreviewUnsupportedType =>
      'Р¦РµР№ С‚РёРї С„Р°Р№Р»Сѓ РЅРµ РїС–РґС‚СЂРёРјСѓС”С‚СЊСЃСЏ РґР»СЏ РІР±СѓРґРѕРІР°РЅРѕРіРѕ РїРµСЂРµРіР»СЏРґСѓ';

  @override
  String get filePreviewPdfLoadFailed =>
      'РќРµ РІРґР°Р»РѕСЃСЏ Р·Р°РІР°РЅС‚Р°Р¶РёС‚Рё PDF РґР»СЏ РїРµСЂРµРіР»СЏРґСѓ';

  @override
  String get filePreviewPdfTooLarge =>
      'PDF Р·Р°РІРµР»РёРєРёР№ РґР»СЏ РІР±СѓРґРѕРІР°РЅРѕРіРѕ РїРµСЂРµРіР»СЏРґСѓ. Р’С–РґРєСЂРёР№С‚Рµ Р·РѕРІРЅС–.';

  @override
  String get filePreviewDownloadTimeout =>
      'РўР°Р№Рј-Р°СѓС‚ Р·Р°РІР°РЅС‚Р°Р¶РµРЅРЅСЏ РїРѕРїРµСЂРµРґРЅСЊРѕРіРѕ РїРµСЂРµРіР»СЏРґСѓ. РЎРїСЂРѕР±СѓР№С‚Рµ РІС–РґРєСЂРёС‚Рё Р·РѕРІРЅС–.';

  @override
  String get filePreviewBlockedUrlScheme =>
      'РЎС…РµРјСѓ URL Р·Р°Р±Р»РѕРєРѕРІР°РЅРѕ Р· РјС–СЂРєСѓРІР°РЅСЊ Р±РµР·РїРµРєРё.';

  @override
  String get filePreviewVideoInitFailed =>
      'РќРµ РІРґР°Р»РѕСЃСЏ С–РЅС–С†С–Р°Р»С–Р·СѓРІР°С‚Рё РїРµСЂРµРіР»СЏРґ РІС–РґРµРѕ';

  @override
  String get filePreviewPlay => 'Р’С–РґС‚РІРѕСЂРёС‚Рё';

  @override
  String get filePreviewPause => 'РџР°СѓР·Р°';

  @override
  String get megaConnectTitle => 'Підключити MEGA';

  @override
  String get megaSecondFactorCodeOptional => 'Код 2FA (необов\'язково)';

  @override
  String get megaCredentialsRequired => 'Email і пароль обов\'язкові';

  @override
  String filePreviewApiError(Object message, Object status) {
    return 'РџРѕРјРёР»РєР° API: $status $message';
  }
}
