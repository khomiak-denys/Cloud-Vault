import 'dart:async';

import 'package:cloud_vault/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_exception.dart';
import '../data/api_mappers.dart';
import '../data/file_actions_handler.dart';
import '../data/oauth_callback_handler.dart';
import '../data/oauth_deep_link_service.dart';
import '../modals/add_vault_modal.dart';
import '../modals/file_actions_modal.dart';
import '../models/recent_file_item.dart';
import '../screens/storage_browser_screen.dart';
import '../state/providers/connections_provider.dart';
import '../state/providers/favorites_provider.dart';
import '../utils/tab_navigation.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/dashboard/dashboard_files_section.dart';
import '../widgets/dashboard/dashboard_storages_section.dart';
import '../widgets/loading_skeletons.dart';
import '../widgets/mobile_screen_shell.dart';
import '../widgets/top_summary_card.dart';

class CloudVaultScreen extends StatefulWidget {
  const CloudVaultScreen({super.key});

  @override
  State<CloudVaultScreen> createState() => _CloudVaultScreenState();
}

class _CloudVaultScreenState extends State<CloudVaultScreen> {
  bool _lastLoadSucceeded = true;
  StreamSubscription<OAuthCallbackEvent>? _oauthCallbackSubscription;

  @override
  void initState() {
    super.initState();
    _load();
    _oauthCallbackSubscription = appOAuthDeepLinkService.events.listen(
      _handleOAuthCallback,
    );
  }

  @override
  void dispose() {
    _oauthCallbackSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final connectionsProvider = context.read<ConnectionsProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    try {
      await Future.wait<void>(<Future<void>>[
        connectionsProvider.ensureLoaded(forceRefresh: forceRefresh),
        favoritesProvider.ensureLoaded(forceRefresh: forceRefresh),
      ]);
      _lastLoadSucceeded = true;
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack('API error: ${e.statusCode ?? ''} ${e.message}'.trim());
      _lastLoadSucceeded = false;
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to load dashboard data');
      _lastLoadSucceeded = false;
    }
  }

  Future<void> _onFileAction(String actionId, RecentFileItem file) async {
    final shouldReload = await handleFileAction(context, actionId, file);
    if (shouldReload) {
      await _load(forceRefresh: true);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _handleOAuthCallback(OAuthCallbackEvent event) async {
    if (!mounted) return;
    await handleOAuthCallbackEvent(
      event: event,
      refreshOnSuccess: () async {
        await _load(forceRefresh: true);
        return mounted && _lastLoadSucceeded;
      },
      hasConnection: (connectionId) => context
          .read<ConnectionsProvider>()
          .connections
          .any((item) => item.id == connectionId),
      showMessage: _showSnack,
      showErrorWithRetry: _showOAuthErrorWithRetry,
      onRetry: _startAddProviderFlow,
    );
  }

  void _showOAuthErrorWithRetry(
    String message,
    Future<void> Function() onRetry,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () async {
              if (!mounted) return;
              await onRetry();
            },
          ),
        ),
      );
  }

  Future<void> _startAddProviderFlow() async {
    final result = await showAddVaultModal(context);
    if (!result.didStartConnect) return;

    if (!result.expectsAppCallback) {
      await _load(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connectionsProvider = context.watch<ConnectionsProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final vaultItems = connectionsProvider.connections
        .map(mapConnectionToVaultItem)
        .toList();
    final favoriteFiles = favoritesProvider.favoriteFiles;
    final totalBytes = connectionsProvider.totalBytes;
    final totalUsedBytes = connectionsProvider.totalUsedBytes;
    final isLoading =
        connectionsProvider.isLoading || favoritesProvider.isLoading;
    final percentUsed = totalBytes > 0
        ? (totalUsedBytes / totalBytes).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      body: MobileScreenShell(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(forceRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      TopSummaryCard(percentUsed: percentUsed),
                      DashboardStoragesSection(
                        items: vaultItems,
                        onAddTap: () async {
                          await _startAddProviderFlow();
                        },
                        onStorageTap: (storage) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  StorageBrowserScreen(storage: storage),
                            ),
                          );
                        },
                      ),
                      if (isLoading)
                        const DashboardLoadingSkeleton()
                      else
                        DashboardFilesSection(
                          items: favoriteFiles,
                          title: l10n.favorites,
                          onMoreTap: (file) => showFileActionsModal(
                            context,
                            file,
                            onActionTap: _onFileAction,
                          ),
                        ),
                    ],
                  ),
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
