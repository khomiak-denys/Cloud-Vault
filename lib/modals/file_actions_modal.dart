import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/file_action_option.dart';
import '../models/recent_file_item.dart';
import 'file_info_modal.dart';
import '../utils/interaction_styles.dart';
import '../widgets/file_action_row.dart';

Future<void> showFileActionsModal(BuildContext context, RecentFileItem file) async {
  final hostContext = context;
  final isStarred = file.badgeIcon == Icons.star;
  final actions = <FileActionOption>[
    FileActionOption(
      icon: isStarred ? Icons.star_border : Icons.star_outline,
      label: isStarred ? 'Прибрати зірочку' : 'Додати зірочку',
      actionId: 'star',
    ),
    const FileActionOption(
      icon: Icons.download_outlined,
      label: 'Завантажити',
      actionId: 'download',
    ),
    const FileActionOption(
      icon: Icons.share_outlined,
      label: 'Поділитися',
      actionId: 'share',
    ),
    const FileActionOption(
      icon: Icons.copy_outlined,
      label: 'Копіювати в...',
      actionId: 'copy',
    ),
    const FileActionOption(
      icon: Icons.edit_outlined,
      label: 'Перейменувати',
      actionId: 'rename',
    ),
    const FileActionOption(
      icon: Icons.info_outline,
      label: 'Інформація',
      actionId: 'info',
    ),
    const FileActionOption(
      icon: Icons.delete_outline,
      label: 'Видалити',
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1B35),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              style: ButtonStyle(
                                overlayColor: pressOnlyOverlay(
                                  const Color(0x3397A5BD),
                                ),
                              ),
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF97A5BD),
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
                              backgroundColor: const Color(0xFF22314A),
                              foregroundColor: const Color(0xFFCDD6E5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              overlayColor: Colors.transparent,
                            ),
                            child: const Text(
                              'Скасувати',
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
