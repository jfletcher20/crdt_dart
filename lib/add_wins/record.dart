part of 'add_wins_observed_remove.dart';

class _Record<T> {
  final T data;
  final HlcTimestamp timestamp;
  const _Record(this.data, this.timestamp);
  @override
  String toString() => 'Record(data: $data, timestamp: $timestamp)';
}
