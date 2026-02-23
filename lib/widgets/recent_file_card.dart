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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2D44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF31435C)),
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF97A5BB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (item.badgeIcon != null) ...[
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
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.more_vert, color: Color(0xFF95A4BE)),
            ),
          ),
        ],
      ),
    );
  }
}
