String providerDisplayName(String providerId) {
  switch (providerId.toLowerCase()) {
    case 'google-drive':
      return 'Google Drive';
    case 'dropbox':
      return 'Dropbox';
    case 'onedrive':
      return 'OneDrive';
    case 'mega':
      return 'MEGA';
    default:
      return 'Storage';
  }
}
