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
    print("addState: $_adds :: $_removes");
  }

  void remove(String key, [HlcTimestamp? timestamp]) {
    final ts = timestamp ?? HlcTimestamp.now();
    final existing = _removes[key];
    if (existing == null || existing.compareTo(ts) < 0) {
      _removes[key] = ts;
    }
    print("removeState: $_adds :: $_removes");
  }

  T? find(String key) {
    print("findState: $_adds :: $_removes");
    if (!_adds.containsKey(key)) return null;

    final addTs = _adds[key]!.timestamp;
    final removeTs = _removes[key];

    if (removeTs == null || removeTs.compareTo(addTs) < 0) {
      return _adds[key]!.data;
    }
    return null;
  }

  void merge(AWORSetCRDT<T> other) {
    print("mergeState[1]: $_adds :: $_removes");
    for (var key in other._adds.keys) {
      final otherRecord = other._adds[key]!;
      if (!_adds.containsKey(key) || _adds[key]!.timestamp.compareTo(otherRecord.timestamp) < 0) {
        _adds[key] = otherRecord;
      }
    }

    print("mergeState[2]: $_adds :: $_removes");
    for (var key in other._removes.keys) {
      final otherRemoveTs = other._removes[key]!;
      if (!_removes.containsKey(key) || _removes[key]!.compareTo(otherRemoveTs) < 0) {
        _removes[key] = otherRemoveTs;
      }
    }
    print("mergeState[3]: $_adds :: $_removes");
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
