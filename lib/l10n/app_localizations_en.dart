// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CloudVault';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navSettings => 'Settings';

  @override
  String get manageClouds => 'Manage all clouds';

  @override
  String get totalUsed => 'Total used';

  @override
  String get myStorages => 'My storages';

  @override
  String get add => 'Add';

  @override
  String get used => 'Used';

  @override
  String get recentFiles => 'Recent files';

  @override
  String get addStorage => 'Add storage';

  @override
  String get chooseCloudStorage => 'Choose cloud storage you want to connect';

  @override
  String get connect => 'Connect';

  @override
  String get cancel => 'Cancel';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search files';

  @override
  String get all => 'All';

  @override
  String get documents => 'Documents';

  @override
  String get images => 'Images';

  @override
  String get videos => 'Videos';

  @override
  String get sortByType => 'Type (A-Z)';

  @override
  String foundFiles(Object count) {
    return 'Found $count files';
  }

  @override
  String get analytics => 'Analytics';

  @override
  String get analyticsSubtitle => 'Storage usage statistics';

  @override
  String get totalSpace => 'Total space';

  @override
  String get usedSpace => 'Used';

  @override
  String get freeSpace => 'Free';

  @override
  String get warning => 'Warning!';

  @override
  String warningBody(Object storages) {
    return '$storages are almost full. Consider cleanup or upgrade.';
  }

  @override
  String get distributionByStorage => 'Distribution by storages';

  @override
  String get usageVsFree => 'Usage vs free space';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get pdfReportTitle => 'Storage Usage Report';

  @override
  String get generatedAt => 'Generated at';

  @override
  String get pdfExportFailed => 'Failed to export PDF';

  @override
  String get tipOptimizeDropboxTitle => 'Optimize Dropbox';

  @override
  String get tipOptimizeDropboxBody =>
      'Your Dropbox is 90% full. Delete old files or upgrade plan.';

  @override
  String get tipUseIcloudTitle => 'Use iCloud';

  @override
  String get tipUseIcloudBody =>
      'You have 4.2 GB free in iCloud. Move large files there.';

  @override
  String get settings => 'Settings';

  @override
  String get connectedStorages => 'Connected storages';

  @override
  String get connected => 'Connected';

  @override
  String get account => 'ACCOUNT';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get other => 'OTHER';

  @override
  String get profile => 'Profile';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileSave => 'Save';

  @override
  String get profileSaved => 'Profile updated';

  @override
  String get profilePersonalInfo => 'Personal information';

  @override
  String get profileFilesStat => 'Files';

  @override
  String get profileStoragesStat => 'Storages';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose app language';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get languageEnglish => 'English';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get privacy => 'Privacy';

  @override
  String get helpSupport => 'Help & support';

  @override
  String get logout => 'Log out';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get premiumPlan => 'Premium plan';

  @override
  String get premiumValidUntil => 'Valid until 23 Feb 2027';

  @override
  String get pro => 'PRO';

  @override
  String get profileName => 'Ivan Petrenko';

  @override
  String get profileEmail => 'ivan.petrenko@email.com';

  @override
  String get appVersion => 'CloudVault v1.0.0';

  @override
  String get themeEnabledToast => 'Dark theme enabled';

  @override
  String get themeDisabledToast => 'Light theme enabled';

  @override
  String get notificationsEnabledToast => 'Notifications enabled';

  @override
  String get notificationsDisabledToast => 'Notifications disabled';

  @override
  String disconnectedToast(Object storage) {
    return '$storage disconnected';
  }

  @override
  String get fileActionsRemoveStar => 'Remove star';

  @override
  String get fileActionsAddStar => 'Add star';

  @override
  String get fileActionsDownload => 'Download';

  @override
  String get fileActionsShare => 'Share';

  @override
  String get fileActionsCopyTo => 'Copy to...';

  @override
  String get fileActionsRename => 'Rename';

  @override
  String get fileActionsInfo => 'Information';

  @override
  String get fileActionsDelete => 'Delete';

  @override
  String get fileInfo => 'File information';

  @override
  String get size => 'Size';

  @override
  String get modified => 'Modified';

  @override
  String get path => 'Path';

  @override
  String get close => 'Close';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authLoginSubtitle => 'Access your CloudVault account';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authRegisterSubtitle => 'Start managing all your clouds';

  @override
  String get authName => 'Name';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authGoRegister => 'Don\'t have an account? Sign up';

  @override
  String get authGoLogin => 'Already have an account? Sign in';

  @override
  String get authAllCloudsOnePlace => 'All clouds in one place';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authAgreeWith => 'I agree with';

  @override
  String get authTerms => 'terms of use';

  @override
  String get authAnd => 'and';

  @override
  String get authPrivacyPolicy => 'privacy policy';

  @override
  String get storageBrowserRoot => 'Root';

  @override
  String get storageBrowserUp => 'Up';

  @override
  String get storageBrowserNewFolder => 'New folder';

  @override
  String get storageBrowserUpload => 'Upload';

  @override
  String get storageBrowserEmptyFolder => 'Folder is empty';

  @override
  String get storageBrowserCreateFolderTitle => 'Create folder';

  @override
  String get storageBrowserCreateFolderHint => 'Folder name';

  @override
  String get storageBrowserCreateFolderAction => 'Create';

  @override
  String get storageBrowserFolderCreated => 'Folder created';

  @override
  String get storageBrowserUploadNotConfigured =>
      'Upload is not configured yet';

  @override
  String get storageBrowserLoadFailed => 'Failed to load folder';

  @override
  String get storageBrowserCreateFolderFailed => 'Failed to create folder';

  @override
  String storageBrowserApiError(Object message, Object status) {
    return 'API error: $status $message';
  }

  @override
  String get filePreviewLoading => 'Loading preview...';

  @override
  String get filePreviewFolderUnsupported => 'Folder preview is not available';

  @override
  String get filePreviewUnavailable => 'Preview unavailable';

  @override
  String get filePreviewOpenExternal => 'Open externally';

  @override
  String get filePreviewLoadFailed => 'Failed to load preview';

  @override
  String get filePreviewUnsupportedType =>
      'This file type is not supported for in-app preview';

  @override
  String get filePreviewPdfLoadFailed => 'Failed to load PDF preview';

  @override
  String get filePreviewPdfTooLarge =>
      'PDF is too large for in-app preview. Open externally.';

  @override
  String get filePreviewDownloadTimeout =>
      'Preview download timed out. Try opening externally.';

  @override
  String get filePreviewBlockedUrlScheme => 'Blocked URL scheme for security.';

  @override
  String get filePreviewVideoInitFailed => 'Failed to initialize video preview';

  @override
  String get filePreviewPlay => 'Play';

  @override
  String get filePreviewPause => 'Pause';

  @override
  String filePreviewApiError(Object message, Object status) {
    return 'API error: $status $message';
  }
}
