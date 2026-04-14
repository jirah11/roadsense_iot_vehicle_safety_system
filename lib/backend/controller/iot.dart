import '../repository/iot.dart';
import '../../models/vehicle.dart';

class IoTController {
  final IoTRepository _repo;

  IoTController(this._repo);

  // ==============================
  // 🚗 VEHICLE PROFILE
  // ==============================

  Future<void> saveVehicleProfile({
    required String deviceId,
    required VehicleType type,
    required String nickname,
    required VehicleThresholds thresholds,
  }) {
    return _repo.saveVehicleProfile(
      deviceId: deviceId,
      type: type,
      nickname: nickname,
      thresholds: thresholds,
    );
  }

  Future<Map<String, dynamic>?> loadVehicleProfile(String deviceId) {
    return _repo.loadVehicleProfile(deviceId);
  }

  // ==============================
  // 🔗 DEVICE BINDING
  // ==============================

  /// Returns false if device is already bound to a different account
  Future<bool> bindDeviceToAccount({
    required String deviceId,
    required String uid,
  }) {
    return _repo.bindDeviceToAccount(deviceId: deviceId, uid: uid);
  }

  Future<String?> getLinkedDevice(String uid) {
    return _repo.getLinkedDevice(uid);
  }

  Future<String?> getDeviceOwner(String deviceId) {
    return _repo.getDeviceOwner(deviceId);
  }

  Future<void> unbindDeviceFromAccount({
    required String deviceId,
    required String uid,
  }) {
    return _repo.unbindDeviceFromAccount(deviceId: deviceId, uid: uid);
  }

  // ==============================
  // ⚙️ APP SETTINGS (per user)
  // ==============================

  Future<void> saveUserSettings({
    required String uid,
    required String deviceId, // 🔥 ADD THIS
    required bool notificationsEnabled,
    required bool soundEnabled,
    required String tempUnit,
    required String distanceUnit,
  }) {
    return _repo.saveUserSettings(
      uid: uid,
      deviceId: deviceId, // 🔥 PASS IT
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      tempUnit: tempUnit,
      distanceUnit: distanceUnit,
    );
  }

  Future<Map<String, dynamic>?> loadUserSettings(String uid) {
    return _repo.loadUserSettings(uid);
  }

  // ==============================
  // 🚨 ALERTS / HISTORY
  // ==============================

  Future<void> saveAlert({
    required String deviceId,
    required Map<String, dynamic> alertData,
  }) {
    return _repo.saveAlert(deviceId: deviceId, alertData: alertData);
  }

  /// Acknowledge a single alert in Firebase by its push key
  Future<void> acknowledgeAlert({
    required String deviceId,
    required String alertKey,
  }) {
    return _repo.acknowledgeAlert(deviceId: deviceId, alertKey: alertKey);
  }

  /// Acknowledge all alerts for a device in Firebase
  Future<void> acknowledgeAllAlerts(String deviceId) {
    return _repo.acknowledgeAllAlerts(deviceId);
  }

  Future<List<Map<String, dynamic>>> loadAlertHistory(String deviceId) {
    return _repo.loadAlertHistory(deviceId);
  }

  Stream<List<Map<String, dynamic>>> listenToAlertHistory(String deviceId) {
    return _repo.listenToAlertHistory(deviceId);
  }

  // ==============================
  // 📡 IOT DEVICE
  // ==============================

  Stream<Map<String, dynamic>> getSettings(String deviceId) {
    return _repo.listenToSettings(deviceId);
  }

  Future<void> connectDevice({
    required String deviceId,
    required String password,
  }) {
    return _repo.connectDevice(deviceId: deviceId, password: password);
  }

  Future<Map<String, dynamic>?> getDevice(String deviceId) {
    return _repo.getDevice(deviceId);
  }
}