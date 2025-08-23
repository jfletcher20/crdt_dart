class HlcTimestamp implements Comparable<HlcTimestamp> {
  final DateTime physicalTime;
  final int logicalCounter;

  HlcTimestamp._(this.physicalTime, this.logicalCounter);

  factory HlcTimestamp.now() {
    final now = DateTime.now().toUtc();
    if (!_nodeLogicalCounters.containsKey(now)) {
      _nodeLogicalCounters[now] = 0;
    }
    final logical = _nodeLogicalCounters[now]!;
    _nodeLogicalCounters[now] = logical + 1;
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

  static final Map<DateTime, int> _nodeLogicalCounters = {};

  @override
  String toString() => '${physicalTime.millisecondsSinceEpoch}:$logicalCounter';
}
