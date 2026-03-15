import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_exception.dart';
import 'app_services.dart';
import '../models/recent_file_item.dart';

Future<bool> handleFileAction(
  BuildContext context,
  String actionId,
  RecentFileItem file,
) async {
  try {
    switch (actionId) {
      case 'star':
        if (file.isFavorite) {
          await appApiRepository.unsetFavorite(
            connectionId: file.connectionId,
            fileId: file.id,
          );
        } else {
          await appApiRepository.setFavorite(
            connectionId: file.connectionId,
            fileId: file.id,
          );
        }
        if (!context.mounted) return false;
        _showSnack(context, file.isFavorite ? 'Removed from favorites' : 'Added to favorites');
        return true;

      case 'download':
        final url = await appApiRepository.downloadUrl(
          connectionId: file.connectionId,
          fileId: file.id,
        );
        if (!context.mounted) return false;
        await _launchIfPresent(context, url, 'Download URL is unavailable');
        return false;

      case 'share':
        final url = await appApiRepository.shareLink(
          connectionId: file.connectionId,
          fileId: file.id,
        );
        if (!context.mounted) return false;
        await _launchIfPresent(context, url, 'Share link is unavailable');
        return false;

      case 'rename':
        final newName = await _askForNewName(context, file.title);
        if (newName == null || newName.trim().isEmpty) return false;
        await appApiRepository.renameFile(
          connectionId: file.connectionId,
          fileId: file.id,
          newName: newName.trim(),
        );
        if (!context.mounted) return false;
        _showSnack(context, 'File renamed');
        return true;

      case 'delete':
        final confirmed = await _confirmDelete(context, file.title);
        if (!confirmed) return false;
        await appApiRepository.deleteFile(
          connectionId: file.connectionId,
          fileId: file.id,
        );
        if (!context.mounted) return false;
        _showSnack(context, 'File deleted');
        return true;

      case 'copy':
        _showSnack(context, 'Copy is not configured yet');
        return false;

      default:
        return false;
    }
  } on ApiException catch (e) {
    if (!context.mounted) return false;
    _showSnack(context, 'API error: ${e.statusCode ?? ''} ${e.message}'.trim());
    return false;
  } catch (_) {
    if (!context.mounted) return false;
    _showSnack(context, 'Action failed');
    return false;
  }
}

Future<void> _launchIfPresent(BuildContext context, String? url, String emptyMessage) async {
  if (url == null || url.isEmpty) {
    _showSnack(context, emptyMessage);
    return;
  }

  final uri = Uri.tryParse(url);
  if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    _showSnack(context, 'Failed to open URL');
  }
}

void _showSnack(BuildContext context, String message) {
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

Future<String?> _askForNewName(BuildContext context, String currentName) async {
  final controller = TextEditingController(text: currentName);

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Rename file'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'New file name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<bool> _confirmDelete(BuildContext context, String fileName) async {
  final value = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete file'),
        content: Text('Delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return value ?? false;
}
