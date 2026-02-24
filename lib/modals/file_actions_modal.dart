import 'dart:ui';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../models/file_action_option.dart';
import '../models/recent_file_item.dart';
import '../theme/app_theme_colors.dart';
import '../utils/interaction_styles.dart';
import '../widgets/file_action_row.dart';
import 'file_info_modal.dart';

Future<void> showFileActionsModal(
  BuildContext context,
  RecentFileItem file,
) async {
  final hostContext = context;
  final l10n = AppLocalizations.of(context)!;
  final colors = AppThemeColors.of(context);
  final isStarred = file.badgeIcon == Icons.star;
  final actions = <FileActionOption>[
    FileActionOption(
      icon: isStarred ? Icons.star_border : Icons.star_outline,
      label: isStarred ? l10n.fileActionsRemoveStar : l10n.fileActionsAddStar,
      actionId: 'star',
    ),
    FileActionOption(
      icon: Icons.download_outlined,
      label: l10n.fileActionsDownload,
      actionId: 'download',
    ),
    FileActionOption(
      icon: Icons.share_outlined,
      label: l10n.fileActionsShare,
      actionId: 'share',
    ),
    FileActionOption(
      icon: Icons.copy_outlined,
      label: l10n.fileActionsCopyTo,
      actionId: 'copy',
    ),
    FileActionOption(
      icon: Icons.edit_outlined,
      label: l10n.fileActionsRename,
      actionId: 'rename',
    ),
    FileActionOption(
      icon: Icons.info_outline,
      label: l10n.fileActionsInfo,
      actionId: 'info',
    ),
    FileActionOption(
      icon: Icons.delete_outline,
      label: l10n.fileActionsDelete,
      actionId: 'delete',
      color: Color(0xFFFF626D),
    ),
  ];

  await showGeneralDialog<void>(
    context: context,
    barrierLabel: 'File actions',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.40),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(color: Colors.black.withValues(alpha: 0.2)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 430,
                  maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.62,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
                  decoration: BoxDecoration(
                    color: colors.modalBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                file.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primaryText,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
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
                        const SizedBox(height: 4),
                        ...actions.map(
                          (action) => FileActionRow(
                            action: action,
                            onTap: () async {
                              Navigator.of(dialogContext).pop();
                              if (action.actionId == 'info') {
                                await showFileInfoModal(hostContext, file);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: TextButton.styleFrom(
                              backgroundColor: colors.secondaryButtonBackground,
                              foregroundColor: colors.secondaryButtonForeground,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              overlayColor: Colors.transparent,
                            ),
                            child: Text(
                              l10n.cancel,
                              style: TextStyle(
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
    },
  );
}
