import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RealtimeDbService {
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(), // ✅ REQUIRED
    databaseURL:
    "https://roadsense-3b3ea-default-rtdb.asia-southeast1.firebasedatabase.app",
  ).ref();

  Future<void> setUserData(String uid, Map<String, dynamic> data) {
    return _db.child('users/$uid').set(data);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final snapshot = await _db.child('users/$uid').get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  Stream<DatabaseEvent> listenToUser(String uid) {
    return _db.child('users/$uid').onValue;
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) {
    return _db.child('users/$uid').update(data);
  }

  Future<void> deleteUser(String uid) {
    return _db.child('users/$uid').remove();
  }

  Future<void> updateData(Map<String, dynamic> data) {
    return _db.update(data);
  }
}

