import 'dart:math' as math;

String formatBytes(double bytes) {
  if (bytes == 0) return '0 Б';

  const k = 1024.0;
  const sizes = ['Б', 'КБ', 'МБ', 'ГБ', 'ТБ'];
  final index = (math.log(bytes) / math.log(k)).floor().clamp(0, 4);
  final converted = bytes / (math.pow(k, index) as double);

  return '${double.parse(converted.toStringAsFixed(2))} ${sizes[index]}';
}
