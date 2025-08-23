class HlcTimestamp implements Comparable<HlcTimestamp> {
  final DateTime physicalTime;
  final int logicalCounter;

  HlcTimestamp._(this.physicalTime, this.logicalCounter);

  factory HlcTimestamp.now() {
    final now = DateTime.now().toUtc();
    if (_currentLogicalCounter == null || _currentLogicalCounter!.physicalTime.isBefore(now)) {
      _currentLogicalCounter = (physicalTime: now, logicalCounter: 0);
    }
    final logical = _currentLogicalCounter!.logicalCounter;
    _currentLogicalCounter = (physicalTime: now, logicalCounter: logical + 1);
    return HlcTimestamp._(now, logical);
  }

  factory HlcTimestamp.fromString(String hlc) {
    final parts = hlc.split(':');
    return HlcTimestamp._(
      DateTime.fromMillisecondsSinceEpoch(int.parse(parts[0]), isUtc: true),
      int.parse(parts[1]),
    );
  }

  @override
  int compareTo(HlcTimestamp other) {
    final timeCompare = physicalTime.compareTo(other.physicalTime);
    if (timeCompare != 0) return timeCompare;
    return logicalCounter.compareTo(other.logicalCounter);
  }

  static ({DateTime physicalTime, int logicalCounter})? _currentLogicalCounter;

  @override
  String toString() => '${physicalTime.millisecondsSinceEpoch}:$logicalCounter';
}
