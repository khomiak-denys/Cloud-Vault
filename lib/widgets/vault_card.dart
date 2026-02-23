import 'package:flutter/material.dart';

import '../models/vault_item.dart';
import 'progress_track.dart';

class VaultCard extends StatelessWidget {
  const VaultCard({super.key, required this.item});

  final VaultItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2D44),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF32435C)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFF22406A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(item.icon, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.usageText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA8B0C0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.hasWarning)
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF7B1B),
                  size: 30,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Використано',
                style: TextStyle(
                  color: Color(0xFF94A1B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                item.percentLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressTrack(value: item.progress, color: item.progressColor),
        ],
      ),
    );
  }
}
