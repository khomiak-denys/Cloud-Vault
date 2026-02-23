import 'package:flutter/material.dart';
import 'package:cloud_vault/l10n/app_localizations.dart';

import '../data/recent_file_mock_data.dart';
import '../data/vault_mock_data.dart';
import '../modals/add_vault_modal.dart';
import '../modals/file_actions_modal.dart';
import '../utils/tab_navigation.dart';
import '../widgets/mobile_screen_shell.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/recent_file_card.dart';
import '../widgets/top_summary_card.dart';
import '../widgets/vault_card.dart';

class CloudVaultScreen extends StatelessWidget {
  const CloudVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionTitle = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const TopSummaryCard(),
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
                                color: sectionTitle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton.icon(
                            onPressed: () => showAddVaultModal(context),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF4BA2FF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
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
                        children: vaultItems
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: VaultCard(item: item),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.recentFiles,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: sectionTitle,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: recentFileItems
                            .map(
                              (file) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: RecentFileCard(
                                  item: file,
                                  onMoreTap: () =>
                                      showFileActionsModal(context, file),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            BottomNavBar(
              activeIndex: 0,
              onTap: (index) => handleBottomNavTap(context, 0, index),
            ),
          ],
        ),
      ),
    );
  }
}
