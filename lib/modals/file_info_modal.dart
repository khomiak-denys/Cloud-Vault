import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/recent_file_item.dart';
import '../utils/interaction_styles.dart';

Future<void> showFileInfoModal(BuildContext context, RecentFileItem file) async {
  await showGeneralDialog<void>(
    context: context,
    barrierLabel: 'File info',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    pageBuilder: (context, animation, secondaryAnimation) {
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 430,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.78,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D1B35),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Інформація про файл',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
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
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF97A5BD),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF263A59), height: 28),
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C3F84),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: Color(0xFF66A8FF),
                                size: 46,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    file.storageName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFA1AEC2),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        _InfoTile(
                          icon: Icons.sd_storage_outlined,
                          label: 'Розмір',
                          value: file.sizeLabel,
                        ),
                        const SizedBox(height: 12),
                        _InfoTile(
                          icon: Icons.calendar_today_outlined,
                          label: 'Змінено',
                          value: file.modifiedLabel,
                        ),
                        const SizedBox(height: 12),
                        _InfoTile(
                          icon: Icons.description_outlined,
                          label: 'Шлях',
                          value: file.pathLabel,
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2662E7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              overlayColor: Colors.transparent,
                            ),
                            child: const Text(
                              'Закрити',
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF22314A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF95A3B9), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF95A3B9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
