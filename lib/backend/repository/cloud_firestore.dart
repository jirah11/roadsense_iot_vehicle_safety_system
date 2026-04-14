import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRepository<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath;

  FirebaseRepository(this.collectionPath);

  CollectionReference get _collection => _firestore.collection(collectionPath);

  /// CREATE
  Future<void> create(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).set(data);
  }

  /// READ (single)
  Future<Map<String, dynamic>?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  /// READ (all)
  Future<List<Map<String, dynamic>>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  /// UPDATE
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).update(data);
  }

  /// DELETE
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
