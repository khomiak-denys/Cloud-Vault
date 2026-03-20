import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../models/vault_item.dart';
import '../../theme/app_theme_colors.dart';
import '../vault_card.dart';

class DashboardStoragesSection extends StatelessWidget {
  const DashboardStoragesSection({
    super.key,
    required this.items,
    required this.onAddTap,
    required this.onStorageTap,
  });

  final List<VaultItem> items;
  final VoidCallback onAddTap;
  final ValueChanged<VaultItem> onStorageTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = AppThemeColors.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.myStorages,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: colors.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: onAddTap,
                style: TextButton.styleFrom(
                  foregroundColor: colors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  overlayColor: Colors.transparent,
                ),
                icon: const Icon(Icons.add, size: 22),
                label: Text(
                  l10n.add,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: VaultCard(
                      item: item,
                      onTap: () => onStorageTap(item),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
