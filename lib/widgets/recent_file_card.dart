import 'package:flutter/material.dart';

import '../models/recent_file_item.dart';

class RecentFileCard extends StatelessWidget {
  const RecentFileCard({
    super.key,
    required this.item,
    required this.onMoreTap,
  });

  final RecentFileItem item;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1F2D44) : Colors.white;
    final border = isDark ? const Color(0xFF31435C) : const Color(0xFFDCE5F2);
    final subtitle = isDark ? const Color(0xFF97A5BB) : const Color(0xFF64748B);
    final more = isDark ? const Color(0xFF95A4BE) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 30, color: item.iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (item.badgeIcon == Icons.star) ...[
            SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Icon(item.badgeIcon, size: 20, color: item.badgeColor),
              ),
            ),
            const SizedBox(width: 8),
          ],
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onMoreTap,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.more_vert, color: more),
            ),
          ),
        ],
      ),
    );
  }
}
