import '../service/iot.dart';
import '../repository/realtime_database.dart';
import '../../models/vehicle.dart';

class IoTRepository {
  final IoTService _iot;
  final RealtimeDbService _db;

  IoTRepository(this._iot, this._db);

  // ==============================
  // 🚗 VEHICLE PROFILE
  // Stored under devices/{deviceId}/settings
  // ==============================

  Future<void> saveVehicleProfile({
    required String deviceId,
    required VehicleType type,
    required String nickname,
    required VehicleThresholds thresholds,
  }) async {
    await _iot.updateSettings(deviceId, {
      'nickname': nickname,
      'vehicle_type': type.name,
    });

    await _iot.updateThresholds(deviceId, {
      'flood_caution': thresholds.floodCaution,
      'flood_danger': thresholds.floodDanger,
      'temp_caution': thresholds.tempCaution,
      'temp_danger': thresholds.tempDanger,
    });
  }

  /// Load vehicle profile from devices/{deviceId}/settings
  Future<Map<String, dynamic>?> loadVehicleProfile(String deviceId) async {
    try {
      final snapshot =
      await _iot.deviceRef(deviceId).child('settings').get();
      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      print('⚠️ [IoTRepository] loadVehicleProfile error: $e');
    }
    return null;
  }

  // ==============================
  // 🔗 DEVICE ↔ ACCOUNT BINDING
  // devices/{deviceId}/binding/uid = uid
  // users/{uid}/linked_device = deviceId
  // ==============================

  /// Bind a device to a user account. Returns false if already bound to another account.
  Future<bool> bindDeviceToAccount({
    required String deviceId,
    required String uid,
  }) async {
    try {
      final snapshot =
      await _iot.deviceRef(deviceId).child('binding/uid').get();
      if (snapshot.exists && snapshot.value != null) {
        final boundUid = snapshot.value.toString();
        if (boundUid != uid) {
          // Device already bound to a different account
          return false;
        }
      }
      // Bind device → user
      await _iot.deviceRef(deviceId).child('binding').update({'uid': uid});
      // Bind user → device
      await _db.updateUserData(uid, {'linked_device': deviceId});
      return true;
    } catch (e) {
      print('❌ [IoTRepository] bindDeviceToAccount error: $e');
      return false;
    }
  }

  /// Get the device ID linked to a user account
  Future<String?> getLinkedDevice(String uid) async {
    try {
      final data = await _db.getUserData(uid);
      if (data != null && data['linked_device'] != null) {
        return data['linked_device'] as String;
      }
    } catch (e) {
      print('⚠️ [IoTRepository] getLinkedDevice error: $e');
    }
    return null;
  }

  /// Check who owns a device
  Future<String?> getDeviceOwner(String deviceId) async {
    try {
      final snapshot =
      await _iot.deviceRef(deviceId).child('binding/uid').get();
      if (snapshot.exists && snapshot.value != null) {
        return snapshot.value.toString();
      }
    } catch (e) {
      print('⚠️ [IoTRepository] getDeviceOwner error: $e');
    }
    return null;
  }

  /// Unbind device from an account (on logout/disconnect)
  Future<void> unbindDeviceFromAccount({
    required String deviceId,
    required String uid,
  }) async {
    try {
      await _iot.deviceRef(deviceId).child('binding').update({'uid': null});
      await _db.updateUserData(uid, {'linked_device': null});
    } catch (e) {
      print('⚠️ [IoTRepository] unbindDeviceFromAccount error: $e');
    }
  }

  // ==============================
  // ⚙️ USER APP SETTINGS
  // Stored under users/{uid}/app_settings
  // ==============================

  Future<void> saveUserSettings({
    required String uid,
    required String deviceId,
    required bool notificationsEnabled,
    required bool soundEnabled,
    required String tempUnit,
    required String distanceUnit,
  }) async {
    await _db.updateData({
      // USER SETTINGS
      'users/$uid/app_settings/notifications_enabled': notificationsEnabled,
      'users/$uid/app_settings/sound_enabled': soundEnabled,

      // DEVICE SETTINGS
      'devices/$deviceId/settings/temp_unit': tempUnit,
      'devices/$deviceId/settings/dist_unit': distanceUnit,
    });
  }

  Future<Map<String, dynamic>?> loadUserSettings(String uid) async {
    try {
      final data = await _db.getUserData(uid);
      if (data != null && data['app_settings'] != null) {
        return Map<String, dynamic>.from(data['app_settings'] as Map);
      }
    } catch (e) {
      print('⚠️ [IoTRepository] loadUserSettings error: $e');
    }
    return null;
  }

  // ==============================
  // 🚨 ALERT HISTORY
  // Stored under devices/{deviceId}/alerts
  // ==============================

  Future<void> saveAlert({
    required String deviceId,
    required Map<String, dynamic> alertData,
  }) async {
    try {
      final alertsRef = _iot.deviceRef(deviceId).child('alerts');
      await alertsRef.push().set(alertData);
    } catch (e) {
      print('❌ [IoTRepository] saveAlert error: $e');
      rethrow;
    }
  }

  /// Acknowledge an alert in the database
  Future<void> acknowledgeAlert({
    required String deviceId,
    required String alertKey,
  }) async {
    try {
      await _iot
          .deviceRef(deviceId)
          .child('alerts/$alertKey')
          .update({'acknowledged': true});
    } catch (e) {
      print('❌ [IoTRepository] acknowledgeAlert error: $e');
    }
  }

  /// Acknowledge all alerts for a device in DB
  Future<void> acknowledgeAllAlerts(String deviceId) async {
    try {
      final snapshot = await _iot
          .deviceRef(deviceId)
          .child('alerts')
          .get();
      if (!snapshot.exists || snapshot.value == null) return;

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final updates = <String, dynamic>{};
      for (final key in raw.keys) {
        updates['alerts/$key/acknowledged'] = true;
      }
      if (updates.isNotEmpty) {
        await _iot.deviceRef(deviceId).update(updates);
      }
    } catch (e) {
      print('❌ [IoTRepository] acknowledgeAllAlerts error: $e');
    }
  }

  /// Stream alert history in real-time
  Stream<List<Map<String, dynamic>>> listenToAlertHistory(String deviceId) {
    return _iot
        .deviceRef(deviceId)
        .child('alerts')
        .orderByChild('timestamp')
        .limitToLast(100)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <Map<String, dynamic>>[];
      }

      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      final alerts = raw.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        map['_key'] = e.key;
        return map;
      }).toList();

      alerts.sort((a, b) {
        final ta = (a['timestamp'] ?? 0) as int;
        final tb = (b['timestamp'] ?? 0) as int;
        return tb.compareTo(ta);
      });

      return alerts;
    });
  }

  Future<List<Map<String, dynamic>>> loadAlertHistory(
      String deviceId) async {
    try {
      final snapshot = await _iot
          .deviceRef(deviceId)
          .child('alerts')
          .orderByChild('timestamp')
          .limitToLast(100)
          .get();

      if (!snapshot.exists || snapshot.value == null) return [];

      final raw = Map<String, dynamic>.from(snapshot.value as Map);
      final alerts = raw.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        map['_key'] = e.key;
        return map;
      }).toList();

      alerts.sort((a, b) {
        final ta = (a['timestamp'] ?? 0) as int;
        final tb = (b['timestamp'] ?? 0) as int;
        return tb.compareTo(ta);
      });

      return alerts;
    } catch (e) {
      print('❌ [IoTRepository] loadAlertHistory error: $e');
      return [];
    }
  }

  // ==============================
  // 📡 DEVICE CORE
  // ==============================

  Stream<Map<String, dynamic>> listenToSettings(String deviceId) {
    return _iot.deviceRef(deviceId).child('settings').onValue.map((event) {
      final data = event.snapshot.value;
      if (data != null) return Map<String, dynamic>.from(data as Map);
      return <String, dynamic>{};
    });
  }

  Future<void> connectDevice({
    required String deviceId,
    required String password,
  }) async {
    await _iot.connectDevice(deviceId: deviceId, password: password);
  }

  Future<Map<String, dynamic>?> getDevice(String deviceId) {
    return _iot.getDevice(deviceId);
  }
}