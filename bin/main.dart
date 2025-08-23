import 'package:crdt_dart/(BAD)add_always_wins/add_always_wins_crdt.dart';

void main() {
  final a = AddAlwaysWinsSet<String>("A");
  final b = AddAlwaysWinsSet<String>("B");

  // Node A adds "apple"
  a.add("apple");

  // Node B adds "apple"
  b.add("apple");

  // Node B updates (adds again with new tag)
  b.add("apple");
  b.add("apple");

  // Node A removes "apple"
  a.remove("apple");

  // Merge states
  a.merge(b);
  b.merge(a);

  print("A: ${a.values}");
  print("B: ${b.values}");
}
