import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../modals/add_vault_modal.dart';
import '../modals/file_actions_modal.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/recent_file_card.dart';
import '../widgets/top_summary_card.dart';
import '../widgets/vault_card.dart';

class CloudVaultScreen extends StatelessWidget {
  const CloudVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF2D2D2D),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00081C),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
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
                                    const Expanded(
                                      child: Text(
                                        'Мої сховища',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton.icon(
                                      onPressed: () => showAddVaultModal(context),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF4BA2FF),
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        overlayColor: Colors.transparent,
                                      ),
                                      icon: const Icon(Icons.add, size: 22),
                                      label: const Text(
                                        'Додати',
                                        style: TextStyle(
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
                              const Padding(
                                padding: EdgeInsets.fromLTRB(24, 28, 24, 14),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Нещодавні файли',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
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
                      const BottomNavBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
