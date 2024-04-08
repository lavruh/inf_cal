class ScaleLevel {
  ScaleLevel.minutes({
    double zoomInSize = 35,
    double zoomOutSize = 18,
    bool isZoomIn = true,
  })  : level = 0,
        zoomInSp = zoomInSize,
        zoomOutSp = zoomOutSize,
        maxSize = 31,
        minSize = null,
        entrySize = isZoomIn ? zoomInSize - 0.5 : zoomOutSize + 0.5,
        iterator = const Duration(minutes: 1);

  ScaleLevel.hours({
    double zoomInSize = 100,
    double zoomOutSize = 3,
    bool isZoomIn = true,
  })  : level = 1,
        zoomInSp = zoomInSize,
        zoomOutSp = zoomOutSize,
        maxSize = null,
        minSize = null,
        entrySize = isZoomIn ? zoomInSize - 0.5 : zoomOutSize + 0.5,
        iterator = const Duration(minutes: 10);

  ScaleLevel.days({
    double zoomInSize = 10,
    double zoomOutSize = 0.8,
    bool isZoomIn = true,
  })  : level = 2,
        zoomInSp = zoomInSize,
        zoomOutSp = zoomOutSize,
        maxSize = null,
        minSize = null,
        entrySize = isZoomIn ? zoomInSize - 0.5 : zoomOutSize + 0.5,
        iterator = const Duration(hours: 1);

  ScaleLevel.months({
    double zoomInSize = 30,
    double zoomOutSize = 20,
    bool isZoomIn = true,
  })  : level = 3,
        zoomInSp = zoomInSize,
        zoomOutSp = zoomOutSize,
        maxSize = null,
        minSize = 20,
        entrySize = isZoomIn ? zoomInSize - 0.5 : zoomOutSize + 0.5,
        iterator = const Duration(days: 1);

  final int level;
  final double zoomInSp;
  final double zoomOutSp;
  final double? maxSize;
  final double? minSize;
  final Duration iterator;
  final double entrySize;

  ScaleLevel changeLevel(int i) {
    final l = level + i;
    final isZoomIn = i > 0;
    if (l == 0) return ScaleLevel.minutes(isZoomIn: isZoomIn);
    if (l == 1) return ScaleLevel.hours(isZoomIn: isZoomIn);
    if (l == 2) return ScaleLevel.days(isZoomIn: isZoomIn);
    if (l == 3) return ScaleLevel.months(isZoomIn: isZoomIn);
    return this;
  }

  ScaleLevel changeScaleLevel({required double entrySize}) {
    if (entrySize < zoomOutSp) return changeLevel(1);
    if (entrySize > zoomInSp) return changeLevel(-1);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScaleLevel &&
          runtimeType == other.runtimeType &&
          level == other.level;

  @override
  int get hashCode => level.hashCode;

  @override
  String toString() {
    return 'ScaleLevel{level: $level, iterator: $iterator, entrySize: $entrySize}';
  }
}
