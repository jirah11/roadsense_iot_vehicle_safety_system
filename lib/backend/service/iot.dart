import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class IoTService {
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(), // ✅ REQUIRED FIX
    databaseURL:
    "https://roadsense-3b3ea-default-rtdb.asia-southeast1.firebasedatabase.app",
  ).ref();

  void _log(String msg) {
    print("📡 [IoTService] $msg");
  }

  /// 🔹 Base reference for a device
  DatabaseReference deviceRef(String deviceId) {
    _log("Getting deviceRef: devices/$deviceId");
    return _db.child('devices/$deviceId');
  }

  /// 🔹 Get full device data
  Future<Map<String, dynamic>?> getDevice(String deviceId) async {
    _log("getDevice() called for $deviceId");

    try {
      final snapshot = await deviceRef(deviceId).get();

      _log("getDevice snapshot exists: ${snapshot.exists}");
      _log("getDevice raw value: ${snapshot.value}");

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _log("getDevice parsed: $data");
        return data;
      }

      _log("getDevice returned null (no data)");
      return null;
    } catch (e) {
      _log("getDevice ERROR: $e");
      rethrow;
    }
  }

  /// 🔹 Listen to entire device (real-time)
  Stream<DatabaseEvent> listenToDevice(String deviceId) {
    _log("listenToDevice() -> devices/$deviceId");

    return deviceRef(deviceId).onValue.map((event) {
      _log("listenToDevice event received");
      _log("listenToDevice data: ${event.snapshot.value}");
      return event;
    });
  }

  // =========================
  // 📡 SENSORS
  // =========================

  Future<Map<String, dynamic>?> getSensors(String deviceId) async {
    _log("getSensors() called for $deviceId");

    final snapshot = await deviceRef(deviceId).child('sensors').get();

    _log("sensors exists: ${snapshot.exists}");
    _log("sensors raw: ${snapshot.value}");

    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _log("sensors parsed: $data");
      return data;
    }

    return null;
  }

  Stream<DatabaseEvent> listenToSensors(String deviceId) {
    _log("listenToSensors() -> $deviceId");

    return deviceRef(deviceId).child('sensors').onValue.map((event) {
      _log("sensor update: ${event.snapshot.value}");
      return event;
    });
  }

  Future<void> updateSensors(String deviceId, Map<String, dynamic> data) async {
    _log("updateSensors() -> $deviceId");
    _log("sensor payload: $data");

    await deviceRef(deviceId).child('sensors').update(data);

    _log("updateSensors DONE");
  }

  // =========================
  // ⚙️ SETTINGS
  // =========================

  Future<void> updateSettings(String deviceId, Map<String, dynamic> data) async {
    _log("updateSettings() -> $deviceId");
    _log("settings payload: $data");

    await deviceRef(deviceId).child('settings').update(data);

    _log("updateSettings DONE");
  }

  Future<void> updateThresholds(String deviceId, Map<String, dynamic> thresholds) async {
    _log("updateThresholds() -> $deviceId");
    _log("thresholds: $thresholds");

    await deviceRef(deviceId)
        .child('settings/thresholds')
        .update(thresholds);

    _log("updateThresholds DONE");
  }

  // =========================
  // 📊 STATUS
  // =========================

  Future<Map<String, dynamic>?> getStatus(String deviceId) async {
    _log("getStatus() -> $deviceId");

    final snapshot = await deviceRef(deviceId).child('status').get();

    _log("status exists: ${snapshot.exists}");
    _log("status raw: ${snapshot.value}");

    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _log("status parsed: $data");
      return data;
    }

    return null;
  }

  Stream<DatabaseEvent> listenToStatus(String deviceId) {
    _log("listenToStatus() -> $deviceId");

    return deviceRef(deviceId).child('status').onValue.map((event) {
      _log("status update: ${event.snapshot.value}");
      return event;
    });
  }

  Future<void> updateStatus(String deviceId, Map<String, dynamic> data) async {
    _log("updateStatus() -> $deviceId");
    _log("status payload: $data");

    await deviceRef(deviceId).child('status').update(data);

    _log("updateStatus DONE");
  }

  // =========================
  // 📶 WIFI CONFIG
  // =========================

  Future<void> updateWifiConfig(String deviceId, Map<String, dynamic> data) async {
    _log("updateWifiConfig() -> $deviceId");
    _log("wifi payload: $data");

    await deviceRef(deviceId).child('wifi_config').update(data);

    _log("updateWifiConfig DONE");
  }

  // =========================
  // ℹ️ DEVICE INFO
  // =========================

  Future<Map<String, dynamic>?> getDeviceInfo(String deviceId) async {
    _log("getDeviceInfo() -> $deviceId");

    final snapshot = await deviceRef(deviceId).child('info').get();

    _log("info exists: ${snapshot.exists}");
    _log("info raw: ${snapshot.value}");

    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _log("info parsed: $data");
      return data;
    }

    return null;
  }

  // =========================
  // ❌ DELETE DEVICE
  // =========================

  Future<void> deleteDevice(String deviceId) async {
    _log("deleteDevice() -> $deviceId");

    await deviceRef(deviceId).remove();

    _log("deleteDevice DONE");
  }

  // =========================
  // 🔐 CONNECT DEVICE
  // =========================

  Future<void> connectDevice({
    required String deviceId,
    required String password,
  }) async {
    _log("connectDevice() START -> $deviceId");
    try {
      final ref = deviceRef(deviceId);

      final snapshot = await ref.child('auth/password').get();
      if (!snapshot.exists) throw Exception('Device not found');

      final storedPassword = snapshot.value.toString();
      if (storedPassword != password) throw Exception('Invalid device password');

      // Check if device is bound to a different account
      final bindingSnapshot = await ref.child('binding/uid').get();
      if (bindingSnapshot.exists && bindingSnapshot.value != null) {
        final boundUid = bindingSnapshot.value.toString();
        final currentUid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
        if (currentUid != null && boundUid != currentUid) {
          throw Exception('Device is already linked to another account');
        }
      }

      await ref.child('status').update({
        'connected': true,
        'online': true,
        'last_connected': ServerValue.timestamp,
      });

      // Bind device to current user
      final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await ref.child('binding').update({'uid': uid});
      }

      _log("DEVICE CONNECTED SUCCESSFULLY ✅");
    } catch (e) {
      _log("connectDevice ERROR: $e");
      rethrow;
    }
  }
}