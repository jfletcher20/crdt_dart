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
  test('aworABSyncXDesync', () {
    final aworA = AWORSetCRDT<String>();
    final aworB = AWORSetCRDT<String>();

    // X represents an especially laggy node
    final aworX = AWORSetCRDT<String>();

    aworA.add("apple", "A");
    aworA.add("orange", "A");

    aworA.sync(aworB);

    aworB.add("apple", "B");

    aworA.remove("apple");
    aworB.add("apple", "C");
    aworB.add("banana", "B");
    aworB.remove("orange");

    aworX.sync(aworA);
    aworA.sync(aworB);

    print("AWOR A: ${aworA.currentState}");
    print("AWOR B: ${aworB.currentState}");
    print("AWOR X: ${aworX.currentState}");
    expect(aworA.currentState, {"apple": "C", "banana": "B"});
    expect(aworB.currentState, {"apple": "C", "banana": "B"});
    expect(aworX.currentState, {"orange": "A"});
  });
  test('aworCyclicFullSync', () {
    final aworA = AWORSetCRDT<String>();
    final aworB = AWORSetCRDT<String>();

    // X represents an especially laggy node
    final aworX = AWORSetCRDT<String>();

    aworA.add("apple", "A");
    aworA.add("orange", "A");

    aworA.sync(aworB);

    aworB.add("apple", "B");

    aworA.remove("apple");
    aworB.add("apple", "C");
    aworB.add("banana", "B");
    aworB.remove("orange");

    // replica list; this test represents cyclic sync without a central server
    final List<AWORSetCRDT<String>> replicas = [aworA, aworB, aworX];
    for (var r in replicas) {
      for (var o in replicas) {
        if (r != o) {
          r.sync(o);
        }
      }
    }

    print("AWOR A: ${aworA.currentState}");
    print("AWOR B: ${aworB.currentState}");
    print("AWOR X: ${aworX.currentState}");
    expect(aworA.currentState, {"apple": "C", "banana": "B"});
    expect(aworB.currentState, {"apple": "C", "banana": "B"});
    expect(aworX.currentState, {"apple": "C", "banana": "B"});
  });
  test('aworCentralizedSync', () {
    final aworA = AWORSetCRDT<String>();
    final aworB = AWORSetCRDT<String>();

    // represents the server
    final aworServer = AWORSetCRDT<String>();

    aworA.add("apple", "A");
    aworA.add("orange", "A");

    aworA.sync(aworB);

    aworB.add("apple", "B");

    aworA.remove("apple");
    aworB.add("apple", "C");
    aworB.add("banana", "B");
    aworB.remove("orange");

    // replica list; this test represents a server managing sync between replicas
    final List<AWORSetCRDT<String>> replicas = [aworA, aworB];
    // server fetches changes from replicas
    for (var r in replicas) {
      aworServer.merge(r);
    }
    // server pushes consolidated state to replicas
    for (var r in replicas) {
      r.merge(aworServer);
    }

    print("AWOR A: ${aworA.currentState}");
    print("AWOR B: ${aworB.currentState}");
    print("AWOR X: ${aworServer.currentState}");
    expect(aworA.currentState, {"apple": "C", "banana": "B"});
    expect(aworB.currentState, {"apple": "C", "banana": "B"});
    expect(aworServer.currentState, {"apple": "C", "banana": "B"});
  });
  test('aworCentralizedAsyncSync', () async {
    final aworA = AWORSetCRDT<String>();
    final aworB = AWORSetCRDT<String>();

    // represents the server
    final aworServer = AWORSetCRDT<String>();
    aworServer.add("mango", "S");

    aworA.add("apple", "A");
    aworA.add("orange", "A");
    aworB.add("apple", "B");

    aworA.remove("apple");
    aworB.add("apple", "C");
    aworB.add("banana", "B");
    aworB.remove("orange");

    print("current A state: ${aworA.currentState}");
    print("current B state: ${aworB.currentState}");

    print("syncing nodes");
    // replica list; this test represents a server managing sync between replicas
    final List<AWORSetCRDT<String>> replicas = [aworA, aworB];
    // server fetches changes from replicas
    for (var r in replicas) {
      aworServer.merge(r);
    }
    print("server synced with nodes: ${aworServer.currentState}");
    print("now async syncing nodes");
    var asyncSynchronization = Future.wait([for (var r in replicas) r.async(aworServer)]);
    print("nodes have all received sync requests");

    for (var r in replicas) {
      print("replica ${r.currentState}");
    }

    await asyncSynchronization.then((value) => print("all nodes have been synced"));

    print("AWOR A: ${aworA.currentState}");
    print("AWOR B: ${aworB.currentState}");
    print("AWOR Server: ${aworServer.currentState}");
    Map<String, String> result = {"apple": "C", "banana": "B", "mango": "S"};
    expect(aworA.currentState, result);
    expect(aworB.currentState, result);
    expect(aworServer.currentState, result);
  });
}
