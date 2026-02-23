import 'package:flutter/material.dart';

import '../models/recent_file_item.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (item.badgeIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(item.badgeIcon, size: 20, color: item.badgeColor),
                    ],
                  ],
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
          IconButton(
            onPressed: onMoreTap,
            icon: const Icon(Icons.more_vert, color: Color(0xFF95A4BE)),
            style: IconButton.styleFrom(
              overlayColor: Colors.transparent,
              minimumSize: const Size(28, 28),
            ),
          ),
        ],
      ),
    );
  }
}
