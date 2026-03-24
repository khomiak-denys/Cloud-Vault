String normalizeProviderId(String? providerId) {
  final raw = providerId?.trim() ?? '';
  if (raw.isEmpty) return '';
  final normalized = raw.toLowerCase();
  if (normalized == 'google') {
    return 'google-drive';
  }
  return normalized;
}

bool isIdBasedProviderId(String? providerId) {
  final normalized = normalizeProviderId(providerId);
  return normalized == 'mega' ||
      normalized == 'onedrive' ||
      normalized == 'google-drive' ||
      normalized == 'dropbox';
}
