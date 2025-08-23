import 'package:crdt_dart/(BAD)add_always_wins/add_always_wins_crdt.dart';
import 'package:crdt_dart/add_wins/add_wins_observed_remove.dart';
import 'package:test/test.dart';

void main() {
  test('addWins', () {
    final a = AddAlwaysWinsSet<String>("A");
    final b = AddAlwaysWinsSet<String>("B");

    // Node A adds "apple"
    a.add("apple");

    // Node B adds "apple"
    b.add("apple");

    // Node B updates (adds again with new tag)
    b.add("apple");

    // Node A removes "apple"
    a.remove("apple");

    // Merge states
    a.merge(b);
    b.merge(a);

    print("A: ${a.adds}::${a.removes}\nB: ${b.adds}::${b.removes}");
    expect(a.values, {"apple"});
    expect(b.values, {"apple"});
  });
  test('removeNeverWins', () {
    final a = AddAlwaysWinsSet<String>("A");
    final b = AddAlwaysWinsSet<String>("B");

    // Node A adds "apple"
    a.add("apple");

    // Node B adds "apple"
    b.add("apple");

    // Node B updates (adds again with new tag)
    b.add("apple");

    // Node A removes "apple"
    a.remove("apple");
    b.remove("apple");

    // Merge states
    a.merge(b);
    b.merge(a);

    print("A: ${a.adds}::${a.removes}\nB: ${b.adds}::${b.removes}");
    expect(a.values, {"apple"});
    expect(b.values, {"apple"});
  });

  test('aworAddWins', () {
    final aworA = AWORSetCRDT<String>();
    final aworB = AWORSetCRDT<String>();

    aworA.add("apple", "A");
    aworB.add("apple", "B");

    aworA.remove("apple");
    aworB.add("apple", "C");

    aworA.merge(aworB);
    aworB.merge(aworA);

    print("AWOR A: ${aworA.currentState}");
    print("AWOR B: ${aworB.currentState}");
    expect(aworA.currentState, {"apple": "C"});
    expect(aworB.currentState, {"apple": "C"});
  });

  test('aworRemoveWins', () {
    final aworA = AWORSetCRDT<String>();
    final aworB = AWORSetCRDT<String>();

    aworA.add("apple", "A");
    aworB.add("apple", "B");

    aworA.remove("apple");

    aworA.merge(aworB);
    aworB.merge(aworA);

    print("AWOR A: ${aworA.currentState}");
    print("AWOR B: ${aworB.currentState}");

    expect(aworA.currentState, {});
    expect(aworB.currentState, {});
  });
}
