import 'package:flutter/material.dart';

import '../data/recent_file_mock_data.dart';
import '../data/vault_mock_data.dart';
import '../modals/add_vault_modal.dart';
import '../modals/file_actions_modal.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/dashboard/dashboard_recent_files_section.dart';
import '../widgets/dashboard/dashboard_storages_section.dart';
import '../widgets/mobile_screen_shell.dart';
import '../widgets/top_summary_card.dart';

class CloudVaultScreen extends StatelessWidget {
  const CloudVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const TopSummaryCard(),
                    DashboardStoragesSection(
                      items: vaultItems,
                      onAddTap: () => showAddVaultModal(context),
                    ),
                    DashboardRecentFilesSection(
                      items: recentFileItems,
                      onMoreTap: (file) => showFileActionsModal(context, file),
                    ),
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
