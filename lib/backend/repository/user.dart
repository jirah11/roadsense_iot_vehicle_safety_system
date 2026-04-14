import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users => _firestore.collection('users');

  /// CREATE
  Future<void> createUser(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).set(data);
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    print("📡 FETCHING USER DOC FOR UID: $uid");

    final doc = await _users.doc(uid).get();

    print("📄 DOC EXISTS: ${doc.exists}");
    print("📄 DOC DATA: ${doc.data()}");

    if (!doc.exists) return null;

    return doc.data() as Map<String, dynamic>;
  }

  /// UPDATE
  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).update(data);
  }

  /// DELETE
  Future<void> deleteUser(String uid) {
    return _users.doc(uid).delete();
  }

  /// GET ALL USERS (admin use)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _users.get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
