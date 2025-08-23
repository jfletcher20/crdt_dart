import 'hlc_timestamp.dart';

part 'record.dart';

class AWORSetCRDT<T> {
  final Map<String, _Record<T>> _adds = {};
  final Map<String, HlcTimestamp> _removes = {};

  void add(String key, T data, [HlcTimestamp? timestamp]) {
    final ts = timestamp ?? HlcTimestamp.now();
    final existing = _adds[key];
    if (existing == null || existing.timestamp.compareTo(ts) < 0) {
      _adds[key] = _Record(data, ts);
    }
  }

  void remove(String key, [HlcTimestamp? timestamp]) {
    final ts = timestamp ?? HlcTimestamp.now();
    final existing = _removes[key];
    if (existing == null || existing.compareTo(ts) < 0) {
      _removes[key] = ts;
    }
  }

  T? find(String key) {
    if (!_adds.containsKey(key)) return null;

    final addTs = _adds[key]!.timestamp;
    final removeTs = _removes[key];

    if (removeTs == null || removeTs.compareTo(addTs) < 0) {
      return _adds[key]!.data;
    }
    return null;
  }

  /// Merges [other] into [this]
  AWORSetCRDT<T> merge(AWORSetCRDT<T> other) {
    for (var key in other._adds.keys) {
      final otherRecord = other._adds[key]!;
      if (!_adds.containsKey(key) || _adds[key]!.timestamp.compareTo(otherRecord.timestamp) < 0) {
        _adds[key] = otherRecord;
      }
    }

    for (var key in other._removes.keys) {
      final otherRemoveTs = other._removes[key]!;
      if (!_removes.containsKey(key) || _removes[key]!.compareTo(otherRemoveTs) < 0) {
        _removes[key] = otherRemoveTs;
      }
    }
    return this;
  }

  /// Synchronizes [other] with [this]
  AWORSetCRDT<T> sync(AWORSetCRDT<T> other) {
    return merge(other.merge(this));
  }

  /// Synchronizes [other] with [this]
  Future<AWORSetCRDT<T>> async(AWORSetCRDT<T> other) async {
    return Future.delayed(Duration(seconds: 1), () => sync(other));
  }

  Map<String, T> get currentState {
    final result = <String, T>{};
    for (var key in _adds.keys) {
      final value = find(key);
      if (value != null) {
        result[key] = value;
      }
    }
    return result;
  }
}
