import 'dart:ui';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_config.dart';
import '../api/api_exception.dart';
import '../data/provider_identity.dart';
import '../data/app_services.dart';
import '../data/provider_options_data.dart';
import '../models/add_vault_option.dart';
import '../theme/app_theme_colors.dart';
import '../utils/interaction_styles.dart';
import '../widgets/add_vault_option_tile.dart';

class AddVaultFlowResult {
  const AddVaultFlowResult({
    required this.didStartConnect,
    required this.expectsAppCallback,
  });

  final bool didStartConnect;
  final bool expectsAppCallback;
}

const AddVaultFlowResult _noConnectResult = AddVaultFlowResult(
  didStartConnect: false,
  expectsAppCallback: false,
);

Future<AddVaultFlowResult> showAddVaultModal(BuildContext context) async {
  const primaryBtnBg = Color(0xFF2662E7);
  const primaryBtnFg = Color(0xFFEAF2FF);
  final l10n = AppLocalizations.of(context)!;
  final colors = AppThemeColors.of(context);

  final result = await showGeneralDialog<AddVaultFlowResult>(
    context: context,
    barrierLabel: l10n.addStorage,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    pageBuilder: (_, _, _) => _AddVaultModalSheet(
      l10n: l10n,
      colors: colors,
      primaryBtnBg: primaryBtnBg,
      primaryBtnFg: primaryBtnFg,
    ),
  );

  return result ?? _noConnectResult;
}

class _AddVaultModalSheet extends StatefulWidget {
  const _AddVaultModalSheet({
    required this.l10n,
    required this.colors,
    required this.primaryBtnBg,
    required this.primaryBtnFg,
  });

  final AppLocalizations l10n;
  final AppThemeColors colors;
  final Color primaryBtnBg;
  final Color primaryBtnFg;

  @override
  State<_AddVaultModalSheet> createState() => _AddVaultModalSheetState();
}

class _AddVaultModalSheetState extends State<_AddVaultModalSheet> {
  int? _selectedIndex;
  bool _isLoadingProviders = true;
  List<AddVaultOption> _availableOptions = addVaultOptions;

  @override
  void initState() {
    super.initState();
    _loadAvailableOptions();
  }

  Future<void> _loadAvailableOptions() async {
    try {
      final connections = await appApiRepository.connections();
      final connectedProviderIds = connections
          .map((connection) => normalizeProviderId(connection.providerId))
          .where((providerId) => providerId.isNotEmpty)
          .toSet();
      if (!mounted) return;
      setState(() {
        _availableOptions = addVaultOptions.where((option) {
          return !connectedProviderIds.contains(option.providerId);
        }).toList();
        if (_selectedIndex != null &&
            _selectedIndex! >= _availableOptions.length) {
          _selectedIndex = null;
        }
        _isLoadingProviders = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _availableOptions = addVaultOptions;
        _isLoadingProviders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colors = widget.colors;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withValues(alpha: 0.2)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 390,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.68,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  decoration: BoxDecoration(
                    color: colors.modalBackground,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: colors.modalBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.addStorage,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: colors.primaryText,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ButtonStyle(
                              overlayColor: pressOnlyOverlay(
                                const Color(0x3397A5BD),
                              ),
                            ),
                            icon: Icon(
                              Icons.close,
                              color: colors.modalCloseIcon,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: colors.modalDivider, height: 24),
                      Text(
                        l10n.chooseCloudStorage,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.modalMutedText,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: const MaterialScrollBehavior().copyWith(
                            scrollbars: false,
                          ),
                          child: _isLoadingProviders
                              ? const Center(child: CircularProgressIndicator())
                              : _availableOptions.isEmpty
                              ? Center(
                                  child: Text(
                                    l10n.allProvidersConnected,
                                    style: TextStyle(
                                      color: colors.modalMutedText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _availableOptions.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          mainAxisExtent: 106,
                                        ),
                                    itemBuilder: (context, index) {
                                      final option = _availableOptions[index];
                                      final isSelected =
                                          _selectedIndex == index;
                                      return AddVaultOptionTile(
                                        option: option,
                                        isSelected: isSelected,
                                        onTap: () => setState(
                                          () => _selectedIndex = index,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isLoadingProviders ||
                                  _selectedIndex == null ||
                                  _availableOptions.isEmpty
                              ? null
                              : () async {
                                  final option =
                                      _availableOptions[_selectedIndex!];
                                  final providerId = option.providerId;

                                  try {
                                    if (providerId == 'mega') {
                                      final connected =
                                          await _showMegaConnectModal(
                                            context,
                                            l10n,
                                          );
                                      if (!connected) {
                                        return;
                                      }

                                      if (context.mounted) {
                                        Navigator.of(context).pop(
                                          const AddVaultFlowResult(
                                            didStartConnect: true,
                                            expectsAppCallback: false,
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    final redirectUri =
                                        _connectRedirectUriForProvider(
                                          providerId,
                                        );
                                    final authorizeUrl = await appApiRepository
                                        .startProviderConnect(
                                          providerId,
                                          redirectUri: redirectUri,
                                        );

                                    if (authorizeUrl == null ||
                                        authorizeUrl.isEmpty) {
                                      if (!context.mounted) return;
                                      _showSnack(
                                        context,
                                        'Connect URL not returned',
                                      );
                                      return;
                                    }

                                    final uri = Uri.tryParse(authorizeUrl);

                                    if (uri == null ||
                                        !await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        )) {
                                      if (!context.mounted) return;
                                      _showSnack(
                                        context,
                                        'Cannot open connect URL',
                                      );
                                      return;
                                    }

                                    if (context.mounted) {
                                      Navigator.of(context).pop(
                                        AddVaultFlowResult(
                                          didStartConnect: true,
                                          expectsAppCallback:
                                              _expectsAppCallback(redirectUri),
                                        ),
                                      );
                                    }
                                  } on ApiException catch (e) {
                                    if (!context.mounted) return;
                                    _showSnack(
                                      context,
                                      'API error: ${e.statusCode ?? ''} ${e.message}'
                                          .trim(),
                                    );
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    _showSnack(
                                      context,
                                      'Failed to start provider connect',
                                    );
                                  }
                                },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              widget.primaryBtnBg,
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              widget.primaryBtnFg,
                            ),
                            overlayColor: pressOnlyOverlay(
                              const Color(0x33FFFFFF),
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                          child: Text(
                            l10n.connect,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _connectRedirectUriForProvider(String providerId) {
  const oauthProviders = {'google-drive', 'dropbox', 'onedrive'};
  if (!oauthProviders.contains(providerId)) {
    return null;
  }

  if (_supportsAppSchemeRedirect) {
    return _appOauthCallbackUri;
  }

  final base = ApiConfig.baseUrl.endsWith('/')
      ? ApiConfig.baseUrl
      : '${ApiConfig.baseUrl}/';
  return Uri.parse(
    base,
  ).resolve('providers/$providerId/connect/callback').toString();
}

bool _expectsAppCallback(String? redirectUri) =>
    redirectUri?.toLowerCase().startsWith(_appOauthCallbackUri) == true;

bool get _supportsAppSchemeRedirect {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

const _appOauthCallbackUri = 'cloudvault://oauth-callback';

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

Future<bool> _showMegaConnectModal(
  BuildContext context,
  AppLocalizations l10n,
) {
  final colors = AppThemeColors.of(context);
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final secondFactorController = TextEditingController();

  return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          bool obscurePassword = true;
          bool isSubmitting = false;

          return StatefulBuilder(
            builder: (context, setState) {
              Future<void> submit() async {
                final email = emailController.text.trim();
                final password = passwordController.text;
                final secondFactor = secondFactorController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  _showSnack(context, l10n.megaCredentialsRequired);
                  return;
                }

                setState(() => isSubmitting = true);
                try {
                  await appApiRepository.startMegaConnect(
                    email: email,
                    password: password,
                    secondFactorCode: secondFactor.isEmpty
                        ? null
                        : secondFactor,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                } on ApiException catch (e) {
                  if (!context.mounted) return;
                  final status = e.statusCode?.toString() ?? '';
                  final message = e.message.trim();
                  if (message.isEmpty ||
                      message.toLowerCase() == 'request failed') {
                    _showSnack(context, l10n.megaConnectFailed);
                  } else {
                    _showSnack(
                      context,
                      l10n.storageBrowserApiError(message, status),
                    );
                  }
                  setState(() => isSubmitting = false);
                } catch (_) {
                  if (!context.mounted) return;
                  _showSnack(context, l10n.megaConnectFailed);
                  setState(() => isSubmitting = false);
                }
              }

              return AlertDialog(
                backgroundColor: colors.modalBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: colors.modalBorder),
                ),
                title: Text(
                  l10n.megaConnectTitle,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: l10n.authEmail,
                          hintText: l10n.authEmail,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        enabled: !isSubmitting,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: const [AutofillHints.password],
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: l10n.authPassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => obscurePassword = !obscurePassword,
                            ),
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: secondFactorController,
                        keyboardType: TextInputType.number,
                        autocorrect: false,
                        enableSuggestions: false,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: l10n.megaSecondFactorCodeOptional,
                          hintText: l10n.megaSecondFactorCodeOptional,
                        ),
                      ),
                      if (isSubmitting) ...[
                        const SizedBox(height: 14),
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: isSubmitting ? null : submit,
                    child: Text(l10n.connect),
                  ),
                ],
              );
            },
          );
        },
      )
      .whenComplete(() {
        emailController.dispose();
        passwordController.dispose();
        secondFactorController.dispose();
      })
      .then((value) => value == true);
}
