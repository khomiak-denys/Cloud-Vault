import 'dart:ui';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_exception.dart';
import '../data/app_services.dart';
import '../data/provider_options_data.dart';
import '../theme/app_theme_colors.dart';
import '../utils/interaction_styles.dart';
import '../widgets/add_vault_option_tile.dart';

Future<bool> showAddVaultModal(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final colors = AppThemeColors.of(context);
  const primaryBtnBg = Color(0xFF2662E7);
  const primaryBtnFg = Color(0xFFEAF2FF);

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierLabel: 'Add vault',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    pageBuilder: (context, animation, secondaryAnimation) {
      int? selectedIndex;

      return StatefulBuilder(
        builder: (context, setModalState) {
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
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
                        maxHeight: MediaQuery.sizeOf(context).height * 0.70,
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        decoration: BoxDecoration(
                          color: colors.modalBackground,
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(color: colors.modalBorder),
                        ),
                        child: SingleChildScrollView(
                          child: ScrollConfiguration(
                            behavior: const MaterialScrollBehavior().copyWith(
                              scrollbars: false,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
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
                                const SizedBox(height: 14),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: addVaultOptions.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        mainAxisExtent: 116,
                                      ),
                                  itemBuilder: (context, index) {
                                    final option = addVaultOptions[index];
                                    final isSelected = selectedIndex == index;
                                    return AddVaultOptionTile(
                                      option: option,
                                      isSelected: isSelected,
                                      onTap: () => setModalState(
                                        () => selectedIndex = index,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: selectedIndex == null
                                        ? null
                                        : () async {
                                            final option =
                                                addVaultOptions[selectedIndex!];
                                            final providerId =
                                                _providerIdForTitle(option.title);

                                            if (providerId == null) {
                                              _showSnack(
                                                context,
                                                'Provider is not supported by backend yet',
                                              );
                                              return;
                                            }

                                            try {
                                              final authorizeUrl =
                                                  await appApiRepository
                                                      .startProviderConnect(
                                                        providerId,
                                                        redirectUri:
                                                            'cloudvault://oauth-callback',
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

                                              final uri = Uri.tryParse(
                                                authorizeUrl,
                                              );

                                              if (uri == null ||
                                                  !await launchUrl(
                                                    uri,
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  )) {
                                                if (!context.mounted) return;
                                                _showSnack(
                                                  context,
                                                  'Cannot open connect URL',
                                                );
                                                return;
                                              }

                                              if (context.mounted) {
                                                Navigator.of(context).pop(true);
                                              }
                                            } on ApiException catch (e) {
                                              if (!context.mounted) return;
                                              _showSnack(
                                                context,
                                                'API error: ${e.statusCode ?? ''} ${e.message}'.trim(),
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
                                      backgroundColor: const WidgetStatePropertyAll(
                                        primaryBtnBg,
                                      ),
                                      foregroundColor: const WidgetStatePropertyAll(
                                        primaryBtnFg,
                                      ),
                                      overlayColor: pressOnlyOverlay(
                                        const Color(0x33FFFFFF),
                                      ),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  return result ?? false;
}

String? _providerIdForTitle(String title) {
  switch (title.toLowerCase()) {
    case 'google drive':
      return 'google-drive';
    case 'dropbox':
      return 'dropbox';
    case 'onedrive':
      return 'onedrive';
    case 'mega':
      return 'mega';
    default:
      return null;
  }
}

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
