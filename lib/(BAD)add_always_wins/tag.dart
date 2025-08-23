/// A unique operation identifier (nodeId + counter)
class Tag {
  final String nodeId;
  final int counter;
  const Tag(this.nodeId, this.counter);

  @override
  bool operator ==(Object other) => other is Tag && nodeId == other.nodeId;

  @override
  int get hashCode => Object.hash(nodeId, counter);

  @override
  String toString() => "($nodeId,$counter)";

  Tag copyWith({String? nodeId, int? counter}) {
    return Tag(nodeId ?? this.nodeId, counter ?? this.counter);
  }
}
