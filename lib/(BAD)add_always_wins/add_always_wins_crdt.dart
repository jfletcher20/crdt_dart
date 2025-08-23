import 'package:crdt_dart/(BAD)add_always_wins/tag.dart';

/// Add-Wins Set CRDT
class AddAlwaysWinsSet<T> {
  final Map<T, Set<Tag>> adds = {};
  final Map<T, Set<Tag>> removes = {};

  int timestamp = 0;
  final String nodeID;
  AddAlwaysWinsSet(this.nodeID);

  /// Add an element with a unique tag
  void add(T element) {
    final tag = Tag(this.nodeID, timestamp++);
    adds.putIfAbsent(element, () => {}).add(tag);
  }

  /// Remove all known adds of an element
  void remove(T element) {
    if (adds.containsKey(element)) {
      // Remove all currently known tags of this element
      final knownTags = adds[element]!;
      for (var tag in knownTags) {
        removes.putIfAbsent(element, () => {}).add(tag.copyWith(counter: ++timestamp));
      }
    }
    // Note: we don’t remove the add immediately, we just mark tags as removed
  }

  /// Merge another AddWinsSet into this one
  void merge(AddAlwaysWinsSet<T> other) {
    for (var entry in other.adds.entries) {
      adds.putIfAbsent(entry.key, () => {}).addAll(entry.value);
    }
    for (var entry in other.removes.entries) {
      removes.putIfAbsent(entry.key, () => {}).addAll(entry.value);
    }
  }

  /// Return the surviving elements
  Set<T> get values {
    final result = <T>{};
    for (var entry in adds.entries) {
      final element = entry.key;
      final tags = entry.value;
      final removedTags = removes[element] ?? {};
      // Survive if there is at least one add not removed
      if (tags.any((t) => !removedTags.contains(t))) {
        result.add(element);
      }
    }
    return result;
  }

  @override
  String toString() => values.toString();
}
