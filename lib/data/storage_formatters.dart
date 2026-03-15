import 'dart:math' as math;

String formatBytes(double bytes) {
  if (bytes <= 0) return '0 B';

  const k = 1024.0;
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  final unitIndex = (math.log(bytes) / math.log(k)).floor().clamp(0, units.length - 1);
  final converted = bytes / math.pow(k, unitIndex);

  return '${(converted as num).toStringAsFixed(1)} ${units[unitIndex]}';
}
