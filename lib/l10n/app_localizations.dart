import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CloudVault'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @manageClouds.
  ///
  /// In en, this message translates to:
  /// **'Manage all clouds'**
  String get manageClouds;

  /// No description provided for @totalUsed.
  ///
  /// In en, this message translates to:
  /// **'Total used'**
  String get totalUsed;

  /// No description provided for @myStorages.
  ///
  /// In en, this message translates to:
  /// **'My storages'**
  String get myStorages;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @recentFiles.
  ///
  /// In en, this message translates to:
  /// **'Recent files'**
  String get recentFiles;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @addStorage.
  ///
  /// In en, this message translates to:
  /// **'Add storage'**
  String get addStorage;

  /// No description provided for @chooseCloudStorage.
  ///
  /// In en, this message translates to:
  /// **'Choose cloud storage you want to connect'**
  String get chooseCloudStorage;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search files'**
  String get searchHint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @sortByType.
  ///
  /// In en, this message translates to:
  /// **'Type (A-Z)'**
  String get sortByType;

  /// No description provided for @foundFiles.
  ///
  /// In en, this message translates to:
  /// **'Found {count} files'**
  String foundFiles(Object count);

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Storage usage statistics'**
  String get analyticsSubtitle;

  /// No description provided for @totalSpace.
  ///
  /// In en, this message translates to:
  /// **'Total space'**
  String get totalSpace;

  /// No description provided for @usedSpace.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get usedSpace;

  /// No description provided for @freeSpace.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeSpace;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning!'**
  String get warning;

  /// No description provided for @warningBody.
  ///
  /// In en, this message translates to:
  /// **'{storages} are almost full. Consider cleanup or upgrade.'**
  String warningBody(Object storages);

  /// No description provided for @distributionByStorage.
  ///
  /// In en, this message translates to:
  /// **'Distribution by storages'**
  String get distributionByStorage;

  /// No description provided for @usageVsFree.
  ///
  /// In en, this message translates to:
  /// **'Usage vs free space'**
  String get usageVsFree;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @pdfReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage Usage Report'**
  String get pdfReportTitle;

  /// No description provided for @generatedAt.
  ///
  /// In en, this message translates to:
  /// **'Generated at'**
  String get generatedAt;

  /// No description provided for @pdfExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export PDF'**
  String get pdfExportFailed;

  /// No description provided for @tipOptimizeDropboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Optimize Dropbox'**
  String get tipOptimizeDropboxTitle;

  /// No description provided for @tipOptimizeDropboxBody.
  ///
  /// In en, this message translates to:
  /// **'Your Dropbox is 90% full. Delete old files or upgrade plan.'**
  String get tipOptimizeDropboxBody;

  /// No description provided for @tipUseIcloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Use iCloud'**
  String get tipUseIcloudTitle;

  /// No description provided for @tipUseIcloudBody.
  ///
  /// In en, this message translates to:
  /// **'You have 4.2 GB free in iCloud. Move large files there.'**
  String get tipUseIcloudBody;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @connectedStorages.
  ///
  /// In en, this message translates to:
  /// **'Connected storages'**
  String get connectedStorages;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'OTHER'**
  String get other;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileSaved;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get profilePersonalInfo;

  /// No description provided for @profileFilesStat.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get profileFilesStat;

  /// No description provided for @profileStoragesStat.
  ///
  /// In en, this message translates to:
  /// **'Storages'**
  String get profileStoragesStat;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get chooseLanguage;

  /// No description provided for @languageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get languageUkrainian;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupport;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium plan'**
  String get premiumPlan;

  /// No description provided for @premiumValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until 23 Feb 2027'**
  String get premiumValidUntil;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Ivan Petrenko'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'ivan.petrenko@email.com'**
  String get profileEmail;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'CloudVault v1.0.0'**
  String get appVersion;

  /// No description provided for @themeEnabledToast.
  ///
  /// In en, this message translates to:
  /// **'Dark theme enabled'**
  String get themeEnabledToast;

  /// No description provided for @themeDisabledToast.
  ///
  /// In en, this message translates to:
  /// **'Light theme enabled'**
  String get themeDisabledToast;

  /// No description provided for @notificationsEnabledToast.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabledToast;

  /// No description provided for @notificationsDisabledToast.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabledToast;

  /// No description provided for @disconnectedToast.
  ///
  /// In en, this message translates to:
  /// **'{storage} disconnected'**
  String disconnectedToast(Object storage);

  /// No description provided for @fileActionsRemoveStar.
  ///
  /// In en, this message translates to:
  /// **'Remove star'**
  String get fileActionsRemoveStar;

  /// No description provided for @fileActionsAddStar.
  ///
  /// In en, this message translates to:
  /// **'Add star'**
  String get fileActionsAddStar;

  /// No description provided for @fileActionsDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get fileActionsDownload;

  /// No description provided for @fileActionsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get fileActionsShare;

  /// No description provided for @fileActionsCopyTo.
  ///
  /// In en, this message translates to:
  /// **'Copy to...'**
  String get fileActionsCopyTo;

  /// No description provided for @fileActionsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get fileActionsRename;

  /// No description provided for @fileActionsInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get fileActionsInfo;

  /// No description provided for @fileActionsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get fileActionsDelete;

  /// No description provided for @fileInfo.
  ///
  /// In en, this message translates to:
  /// **'File information'**
  String get fileInfo;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @path.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get path;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your CloudVault account'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start managing all your clouds'**
  String get authRegisterSubtitle;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authGoRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get authGoRegister;

  /// No description provided for @authGoLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authGoLogin;

  /// No description provided for @authAllCloudsOnePlace.
  ///
  /// In en, this message translates to:
  /// **'All clouds in one place'**
  String get authAllCloudsOnePlace;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authAgreeWith.
  ///
  /// In en, this message translates to:
  /// **'I agree with'**
  String get authAgreeWith;

  /// No description provided for @authTerms.
  ///
  /// In en, this message translates to:
  /// **'terms of use'**
  String get authTerms;

  /// No description provided for @authAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get authAnd;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get authPrivacyPolicy;

  /// No description provided for @storageBrowserRoot.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get storageBrowserRoot;

  /// No description provided for @storageBrowserUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get storageBrowserUp;

  /// No description provided for @storageBrowserNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get storageBrowserNewFolder;

  /// No description provided for @storageBrowserUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get storageBrowserUpload;

  /// No description provided for @storageBrowserEmptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder is empty'**
  String get storageBrowserEmptyFolder;

  /// No description provided for @storageBrowserCreateFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get storageBrowserCreateFolderTitle;

  /// No description provided for @storageBrowserCreateFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get storageBrowserCreateFolderHint;

  /// No description provided for @storageBrowserCreateFolderAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get storageBrowserCreateFolderAction;

  /// No description provided for @storageBrowserFolderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created'**
  String get storageBrowserFolderCreated;

  /// No description provided for @storageBrowserUploadNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Upload is not configured yet'**
  String get storageBrowserUploadNotConfigured;

  /// No description provided for @storageBrowserUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'File uploaded'**
  String get storageBrowserUploadSuccess;

  /// No description provided for @storageBrowserUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload file'**
  String get storageBrowserUploadFailed;

  /// No description provided for @storageBrowserLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load folder'**
  String get storageBrowserLoadFailed;

  /// No description provided for @storageBrowserCreateFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create folder'**
  String get storageBrowserCreateFolderFailed;

  /// No description provided for @storageBrowserApiError.
  ///
  /// In en, this message translates to:
  /// **'API error: {status} {message}'**
  String storageBrowserApiError(Object message, Object status);

  /// No description provided for @filePreviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading preview...'**
  String get filePreviewLoading;

  /// No description provided for @filePreviewFolderUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Folder preview is not available'**
  String get filePreviewFolderUnsupported;

  /// No description provided for @filePreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview unavailable'**
  String get filePreviewUnavailable;

  /// No description provided for @filePreviewOpenExternal.
  ///
  /// In en, this message translates to:
  /// **'Open externally'**
  String get filePreviewOpenExternal;

  /// No description provided for @filePreviewOpenExternalFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open externally'**
  String get filePreviewOpenExternalFailed;

  /// No description provided for @filePreviewLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load preview'**
  String get filePreviewLoadFailed;

  /// No description provided for @filePreviewUnsupportedType.
  ///
  /// In en, this message translates to:
  /// **'This file type is not supported for in-app preview'**
  String get filePreviewUnsupportedType;

  /// No description provided for @filePreviewPdfLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load PDF preview'**
  String get filePreviewPdfLoadFailed;

  /// No description provided for @filePreviewPdfTooLarge.
  ///
  /// In en, this message translates to:
  /// **'PDF is too large for in-app preview. Open externally.'**
  String get filePreviewPdfTooLarge;

  /// No description provided for @filePreviewDownloadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Preview download timed out. Try opening externally.'**
  String get filePreviewDownloadTimeout;

  /// No description provided for @filePreviewBlockedUrlScheme.
  ///
  /// In en, this message translates to:
  /// **'Blocked URL scheme for security.'**
  String get filePreviewBlockedUrlScheme;

  /// No description provided for @filePreviewVideoInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize video preview'**
  String get filePreviewVideoInitFailed;

  /// No description provided for @filePreviewPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get filePreviewPlay;

  /// No description provided for @filePreviewPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get filePreviewPause;

  /// No description provided for @megaConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect MEGA'**
  String get megaConnectTitle;

  /// No description provided for @megaSecondFactorCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'2FA code (optional)'**
  String get megaSecondFactorCodeOptional;

  /// No description provided for @megaCredentialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and password are required'**
  String get megaCredentialsRequired;

  /// No description provided for @megaConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect MEGA'**
  String get megaConnectFailed;

  /// No description provided for @filePreviewApiError.
  ///
  /// In en, this message translates to:
  /// **'API error: {status} {message}'**
  String filePreviewApiError(Object message, Object status);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
