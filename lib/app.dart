import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:roadsense_unang_hirit/screens/help_info_screen.dart';
import 'package:roadsense_unang_hirit/screens/history_logs_screen.dart';
import 'package:roadsense_unang_hirit/screens/settings_screen.dart';
import 'package:roadsense_unang_hirit/screens/vehicle_profile_screen.dart';
import 'app_theme.dart';
import 'backend/repository/realtime_database.dart';
import 'backend/service/notification_service.dart';
import 'models/models.dart';
import 'screens/home_screen.dart';
import 'widgets/bottom_nav.dart';
import 'screens/alerts_screen.dart';
import 'screens/iot_status_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/my_account_screen.dart';
import 'screens/launch_screen.dart';
import 'screens/onboarding_screen.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:provider/provider.dart';
import 'backend/controller/user.dart';
import 'backend/controller/iot.dart';
import 'backend/service/iot.dart';
import 'backend/repository/iot.dart';

enum AppScreen {
  launch, onboarding, login, signup, home, alerts,
  vehicle, history, settings, iotStatus, help, myAccount,
}

enum TemperatureUnit { celsius, fahrenheit }
enum DistanceUnit { centimeters, inches }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppScreen _currentScreen = AppScreen.launch;
  AppScreen _myAccountReturnTo = AppScreen.settings;

  late final IoTService _iotService;
  late final RealtimeDbService _realtimeDbService;
  late final IoTRepository _iotRepository;
  IoTController? _iotController;

  // Singleton — same instance as in main.dart
  final NotificationService _notificationService = NotificationService();

  VehicleType _vehicleType = VehicleType.sedan;
  String _vehicleNickname = 'My Vehicle';
  VehicleThresholds? _customThresholds;
  late UserInfo _userInfo;

  late SensorData _sensorData;
  late List<AlertModel> _alerts;
  late bool _iotConnected;
  late bool _iotPaired;

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  TemperatureUnit _tempUnit = TemperatureUnit.celsius;
  DistanceUnit _distanceUnit = DistanceUnit.centimeters;

  StreamSubscription? _iotSub;
  StreamSubscription? _alertHistorySub;
  String? _connectedDeviceId;

  // FIX: only call this AFTER auth (login/signup), not in initState
  Future<void> _saveFcmTokenToDb() async {
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await _notificationService.getToken();
      if (token != null) {
        await _realtimeDbService.updateUserData(uid, {'fcm_token': token});
        debugPrint('✅ FCM token saved');
      }
    } catch (e) {
      debugPrint('❌ Failed to save FCM token: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _iotService = IoTService();
    _realtimeDbService = RealtimeDbService();
    _iotRepository = IoTRepository(_iotService, _realtimeDbService);
    _iotController = IoTController(_iotRepository);

    // NOTE: _saveFcmTokenToDb() is NOT called here — no user yet
    // It's called after login and signup below

    _userInfo = const UserInfo();
    _sensorData = SensorData(floodLevel: 0, temperature: 0, timestamp: DateTime.now());
    _iotConnected = false;
    _iotPaired = false;
    _alerts = [];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userController = context.read<UserController>();
      if (userController.isAuthenticated) {
        debugPrint("🔄 AUTO-LOADING USER ON APP START...");
        final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await _loadInitialIoTData("RSD1");
          await _loadVehicleProfileFromDb("RSD1");
          await _loadUserSettingsFromDb(uid);
          _connectedDeviceId = "RSD1";
          _attachDeviceStream("RSD1");
          _attachAlertHistoryStream("RSD1");
          // User already authenticated (app restart), save token now
          await _saveFcmTokenToDb();
        }
      }
    });
  }

  @override
  void dispose() {
    _iotSub?.cancel();
    _alertHistorySub?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialIoTData(String deviceId) async {
    try {
      final data = await _iotController!.getDevice(deviceId);
      if (data == null) { debugPrint("⚠️ No device data found"); return; }

      final sensors = (data['sensors'] as Map?)?.cast<String, dynamic>() ?? {};
      final status = (data['status'] as Map?)?.cast<String, dynamic>() ?? {};

      setState(() {
        _sensorData = SensorData(
          floodLevel: (sensors['distance'] ?? 0).toDouble(),
          temperature: (sensors['temperature'] ?? 0).toDouble(),
          timestamp: DateTime.now(),
        );
        _iotConnected = status['connected'] ?? false;
        _iotPaired = status['online'] ?? false;
      });
      debugPrint("✅ Initial IoT data loaded");
    } catch (e) {
      debugPrint("❌ Failed to load IoT initial data: $e");
    }
  }

  Future<void> _loadVehicleProfileFromDb(String deviceId) async {
    try {
      final profile = await _iotController!.loadVehicleProfile(deviceId);
      if (profile == null) { debugPrint("⚠️ No vehicle profile in DB"); return; }

      final settings = (profile['settings'] as Map?)?.cast<String, dynamic>() ?? profile;
      final thresholdsRaw = settings['thresholds'];

      setState(() {
        final typeStr = settings['vehicle_type'] as String?;
        if (typeStr != null) {
          _vehicleType = VehicleType.values.firstWhere(
                  (t) => t.name == typeStr, orElse: () => VehicleType.sedan);
        }
        final nickname = settings['nickname'] as String?;
        if (nickname != null && nickname.isNotEmpty) _vehicleNickname = nickname;

        if (thresholdsRaw != null) {
          final t = (thresholdsRaw as Map).cast<String, dynamic>();
          _customThresholds = VehicleThresholds(
            floodCaution: (t['flood_caution'] ?? 20).toDouble(),
            floodDanger: (t['flood_danger'] ?? 35).toDouble(),
            tempCaution: (t['temp_caution'] ?? 45).toDouble(),
            tempDanger: (t['temp_danger'] ?? 55).toDouble(),
          );
        }
      });
      debugPrint("✅ Vehicle profile loaded: $_vehicleType / $_vehicleNickname");
    } catch (e) {
      debugPrint("❌ Failed to load vehicle profile: $e");
    }
  }

  Future<void> _loadUserSettingsFromDb(String uid) async {
    try {
      final settings = await _iotController!.loadUserSettings(uid);
      if (settings == null) { debugPrint("⚠️ No user settings in DB"); return; }

      setState(() {
        _notificationsEnabled = settings['notifications_enabled'] as bool? ?? true;
        _soundEnabled = settings['sound_enabled'] as bool? ?? true;
        _tempUnit = (settings['temp_unit'] as String?) == 'fahrenheit'
            ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius;
        _distanceUnit = (settings['distance_unit'] as String?) == 'inches'
            ? DistanceUnit.inches : DistanceUnit.centimeters;
      });
      debugPrint("✅ User settings loaded");
    } catch (e) {
      debugPrint("❌ Failed to load user settings: $e");
    }
  }

  Future<void> _saveUserSettingsToDb() async {
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final deviceId = _connectedDeviceId ?? "RSD1";
    try {
      await _iotController!.saveUserSettings(
        uid: uid,
        deviceId: deviceId,
        notificationsEnabled: _notificationsEnabled,
        soundEnabled: _soundEnabled,
        tempUnit: _tempUnit == TemperatureUnit.fahrenheit ? 'fahrenheit' : 'celsius',
        distanceUnit: _distanceUnit == DistanceUnit.inches ? 'inches' : 'centimeters',
      );
      debugPrint("✅ User settings saved to DB");
    } catch (e) {
      debugPrint("❌ Failed to save user settings: $e");
    }
  }

  void _goTo(AppScreen screen) => setState(() => _currentScreen = screen);

  void _goToMyAccount({required AppScreen returnTo}) {
    context.read<UserController>().refreshUser();
    setState(() {
      _myAccountReturnTo = returnTo;
      _currentScreen = AppScreen.myAccount;
    });
  }

  bool get _iotLive => _iotPaired && _iotConnected;

  void _attachDeviceStream(String deviceId) {
    _iotSub?.cancel();
    _iotSub = null;
    debugPrint("📡 [STREAM] Listening to device: $deviceId");

    _iotSub = _iotService.listenToDevice(deviceId).listen(
          (event) {
        final raw = event.snapshot.value;
        if (!mounted || raw == null) return;
        try {
          final data = Map<String, dynamic>.from(raw as Map);
          final sensors = (data['sensors'] as Map?)?.cast<String, dynamic>() ?? {};
          final status = (data['status'] as Map?)?.cast<String, dynamic>() ?? {};

          setState(() {
            _sensorData = SensorData(
              floodLevel: (sensors['distance'] ?? sensors['floodLevel'] ?? 0).toDouble(),
              temperature: (sensors['temperature'] ?? 0).toDouble(),
              timestamp: DateTime.now(),
            );
            _iotConnected = status['connected'] ?? false;
            _iotPaired = status['online'] ?? false;
          });

          _checkAlerts(); // notifications are fired inside here
        } catch (e) {
          debugPrint("❌ [STREAM PARSE ERROR]: $e");
        }
      },
      onError: (error) => debugPrint("❌ [STREAM ERROR]: $error"),
      onDone: () => debugPrint("ℹ️ [STREAM] Closed"),
    );
  }

  void _attachAlertHistoryStream(String deviceId) {
    _alertHistorySub?.cancel();
    _alertHistorySub = null;

    _alertHistorySub = _iotController!.listenToAlertHistory(deviceId).listen(
          (alertMaps) {
        if (!mounted) return;
        final parsed = alertMaps.map((m) => AlertModel(
          id: m['_key'] as String? ?? m['id'] as String? ?? '',
          type: AlertType.values.firstWhere(
                  (t) => t.name == (m['type'] as String? ?? ''),
              orElse: () => AlertType.flood),
          severity: AlertSeverity.values.firstWhere(
                  (s) => s.name == (m['severity'] as String? ?? ''),
              orElse: () => AlertSeverity.caution),
          message: m['message'] as String? ?? '',
          timestamp: m['timestamp'] != null
              ? DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int)
              : DateTime.now(),
          value: (m['value'] ?? 0).toDouble(),
          acknowledged: m['acknowledged'] as bool? ?? false,
        )).toList();

        setState(() => _alerts = parsed);
      },
      onError: (e) => debugPrint("❌ [ALERT STREAM ERROR]: $e"),
    );
  }

  void _checkAlerts() {
    if (!_iotLive) return;
    final thresholds = _thresholds;
    final newAlerts = <AlertModel>[];

    if (_sensorData.floodLevel >= thresholds.floodDanger) {
      newAlerts.add(AlertModel(
        id: 'flood-danger-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.flood, severity: AlertSeverity.danger,
        message: 'DANGER: High flood level detected! Avoid this area.',
        timestamp: DateTime.now(), value: _sensorData.floodLevel, acknowledged: false,
      ));
    } else if (_sensorData.floodLevel >= thresholds.floodCaution) {
      newAlerts.add(AlertModel(
        id: 'flood-caution-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.flood, severity: AlertSeverity.caution,
        message: 'CAUTION: Moderate flood level detected. Drive carefully.',
        timestamp: DateTime.now(), value: _sensorData.floodLevel, acknowledged: false,
      ));
    }

    if (_sensorData.temperature >= thresholds.tempDanger) {
      newAlerts.add(AlertModel(
        id: 'temp-danger-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.temperature, severity: AlertSeverity.danger,
        message: 'DANGER: Engine temperature critically high!',
        timestamp: DateTime.now(), value: _sensorData.temperature, acknowledged: false,
      ));
    } else if (_sensorData.temperature >= thresholds.tempCaution) {
      newAlerts.add(AlertModel(
        id: 'temp-caution-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.temperature, severity: AlertSeverity.caution,
        message: 'CAUTION: Engine temperature elevated. Monitor closely.',
        timestamp: DateTime.now(), value: _sensorData.temperature, acknowledged: false,
      ));
    }

    if (newAlerts.isEmpty) return;

    final existingKeys = _alerts
        .where((a) => !a.acknowledged).take(3)
        .map((a) => '${a.type}-${a.severity}').toSet();

    final toAdd = newAlerts
        .where((a) => !existingKeys.contains('${a.type}-${a.severity}'))
        .toList();

    if (toAdd.isEmpty) return;

    // Save to Firebase
    if (_connectedDeviceId != null) {
      for (final alert in toAdd) {
        _iotController!.saveAlert(
          deviceId: _connectedDeviceId!,
          alertData: {
            'id': alert.id, 'type': alert.type.name,
            'severity': alert.severity.name, 'message': alert.message,
            'timestamp': alert.timestamp.millisecondsSinceEpoch,
            'value': alert.value, 'acknowledged': alert.acknowledged,
          },
        ).catchError((e) => debugPrint("❌ Failed to save alert: $e"));
      }
    }

    // FIX: notifications fired HERE, inside _checkAlerts, where toAdd exists
    if (_notificationsEnabled) {
      for (final alert in toAdd) {
        final isCritical = alert.severity == AlertSeverity.danger;
        _notificationService.showAlert(
          title: isCritical ? '🚨 DANGER Alert' : '⚠️ Caution Alert',
          body: alert.message,
          isCritical: isCritical,
        );
      }
    }
  }

  void _onConnectIotDevice({required String deviceId, required String password}) async {
    try {
      debugPrint("🔌 [CONNECT] START → $deviceId");
      if (_iotController == null) { debugPrint("❌ IoTController NOT initialized"); return; }

      await _iotController!.connectDevice(deviceId: deviceId, password: password);
      if (!mounted) return;

      _connectedDeviceId = deviceId;
      setState(() { _iotPaired = true; _iotConnected = true; });

      await _loadVehicleProfileFromDb(deviceId);
      _attachDeviceStream(deviceId);
      _attachAlertHistoryStream(deviceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Device connected (live data)")));
      }
    } catch (e) {
      debugPrint("❌ [CONNECT ERROR]: $e");
      if (!mounted) return;
      setState(() { _iotPaired = false; _iotConnected = false; });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connect failed: $e")));
    }
  }

  void _onDisconnectIotDevice() async {
    try {
      await _iotSub?.cancel(); _iotSub = null;
      await _alertHistorySub?.cancel(); _alertHistorySub = null;

      final deviceId = _connectedDeviceId;
      if (deviceId != null) {
        await _iotService.updateStatus(deviceId, {'connected': false});
      }
      if (!mounted) return;

      setState(() {
        _iotPaired = false; _iotConnected = false; _alerts = [];
        _sensorData = SensorData(floodLevel: 0, temperature: 0, timestamp: DateTime.now());
      });
      _connectedDeviceId = null;
    } catch (e) {
      debugPrint("❌ [DISCONNECT ERROR]: $e");
    }
  }

  void _acknowledgeAlert(String id) {
    setState(() {
      _alerts = _alerts.map((a) => a.id == id ? a.copyWith(acknowledged: true) : a).toList();
    });
    if (_connectedDeviceId != null) {
      _iotController!.acknowledgeAlert(deviceId: _connectedDeviceId!, alertKey: id)
          .catchError((e) => debugPrint("❌ Failed to acknowledge alert: $e"));
    }
  }

  void _clearAllAlerts() {
    setState(() {
      _alerts = _alerts.map((a) => a.copyWith(acknowledged: true)).toList();
    });
    if (_connectedDeviceId != null) {
      _iotController!.acknowledgeAllAlerts(_connectedDeviceId!)
          .catchError((e) => debugPrint("❌ Failed to clear all alerts: $e"));
    }
  }

  VehicleThresholds get _thresholds =>
      _customThresholds ?? VehicleThresholds.forType(_vehicleType);

  List<AlertModel> get _activeAlerts =>
      _iotLive ? _alerts.where((a) => !a.acknowledged).toList() : [];

  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('roadsense_hasSeenOnboarding') ?? false;
  }

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('roadsense_hasSeenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.backgroundStart, AppColors.backgroundMid, AppColors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                        children: [
                          if (_currentScreen == AppScreen.launch)
                            LaunchScreen(
                              hasSeenOnboarding: _hasSeenOnboarding,
                              goToLogin: () => _goTo(AppScreen.login),
                              goToOnboarding: () => _goTo(AppScreen.onboarding),
                            ),

                          if (_currentScreen == AppScreen.onboarding)
                            OnboardingScreen(
                              goToLoginAndMarkSeen: () async {
                                await _markOnboardingSeen();
                                if (!mounted) return;
                                _goTo(AppScreen.login);
                              },
                            ),

                          if (_currentScreen == AppScreen.login)
                            LoginScreen(
                              onGoToSignUp: () => _goTo(AppScreen.signup),
                              onLogin: (email, password) async {
                                await userController.login(email, password);
                                if (userController.isAuthenticated) {
                                  if (!mounted) return;
                                  final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
                                  if (uid != null) {
                                    await _loadInitialIoTData("RSD1");
                                    await _loadVehicleProfileFromDb("RSD1");
                                    await _loadUserSettingsFromDb(uid);
                                    _connectedDeviceId = "RSD1";
                                    _attachDeviceStream("RSD1");
                                    _attachAlertHistoryStream("RSD1");
                                    // FIX: save FCM token after uid is available
                                    await _saveFcmTokenToDb();
                                  }
                                  setState(() => _currentScreen = AppScreen.home);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Login failed")));
                                }
                              },
                            ),

                          if (_currentScreen == AppScreen.signup)
                            SignUpScreen(
                              onGoToLogin: () => _goTo(AppScreen.login),
                              onSignUp: ({
                                required String firstName, required String middleName,
                                required String lastName, required String email,
                                required String phoneNumber, required String password,
                              }) async {
                                try {
                                  await userController.signup(
                                    firstName: firstName, middleName: middleName,
                                    lastName: lastName, email: email,
                                    phoneNumber: phoneNumber, password: password,
                                    vehicleType: "sedan", vehicleNickname: "My Vehicle",
                                  );
                                  if (!context.mounted) return;
                                  final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
                                  if (uid != null) {
                                    await _loadInitialIoTData("RSD1");
                                    await _loadVehicleProfileFromDb("RSD1");
                                    await _loadUserSettingsFromDb(uid);
                                    _connectedDeviceId = "RSD1";
                                    _attachDeviceStream("RSD1");
                                    _attachAlertHistoryStream("RSD1");
                                    // FIX: save FCM token after uid is available
                                    await _saveFcmTokenToDb();
                                  }
                                  setState(() => _currentScreen = AppScreen.home);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())));
                                }
                              },
                            ),

                          if (_currentScreen == AppScreen.myAccount) ...[
                            Builder(builder: (context) {
                              final user = userController.userModel;
                              if (user == null) return const Center(child: CircularProgressIndicator());
                              return MyAccountScreen(
                                userInfo: UserInfo(
                                  firstName: user.firstName, middleName: user.middleName,
                                  lastName: user.lastName, email: user.email,
                                  phoneNumber: user.phoneNumber, createdAt: user.createdAt,
                                ),
                                onBack: () => _goTo(_myAccountReturnTo),
                                onUserInfoChanged: (info) async {
                                  await userController.updateProfile({
                                    'firstName': info.firstName, 'middleName': info.middleName,
                                    'lastName': info.lastName, 'email': info.email,
                                    'phoneNumber': info.phoneNumber,
                                  });
                                  await userController.refreshUser();
                                },
                                onLogout: () async {
                                  await _iotSub?.cancel(); await _alertHistorySub?.cancel();
                                  _iotSub = null; _alertHistorySub = null; _connectedDeviceId = null;
                                  await userController.logout();
                                  if (!mounted) return;
                                  _goTo(AppScreen.login);
                                },
                                onDeleteAccount: () async {
                                  await _iotSub?.cancel(); await _alertHistorySub?.cancel();
                                  _iotSub = null; _alertHistorySub = null; _connectedDeviceId = null;
                                  await userController.deleteAccount();
                                  if (!mounted) return;
                                  _goTo(AppScreen.login);
                                },
                              );
                            }),
                          ],

                          if (_currentScreen == AppScreen.home)
                            HomeScreen(
                              sensorData: _sensorData, thresholds: _thresholds,
                              vehicleNickname: _vehicleNickname, activeAlerts: _activeAlerts,
                              iotConnected: _iotConnected, iotLive: _iotLive,
                              tempUnit: _tempUnit, distanceUnit: _distanceUnit,
                              onNavigate: _goTo,
                            ),

                          if (_currentScreen == AppScreen.alerts)
                            AlertsScreen(
                              alerts: _alerts, iotLive: _iotLive,
                              tempUnit: _tempUnit, distanceUnit: _distanceUnit,
                              onBack: () => _goTo(AppScreen.home),
                              onAcknowledge: _acknowledgeAlert,
                              onClearAll: _clearAllAlerts,
                            ),

                          if (_currentScreen == AppScreen.vehicle)
                            Positioned.fill(
                              child: VehicleProfileScreen(
                                vehicleType: _vehicleType, vehicleNickname: _vehicleNickname,
                                thresholds: _thresholds,
                                onBack: () => _goTo(AppScreen.home),
                                onSave: (type, nickname, thresholds) async {
                                  setState(() {
                                    _vehicleType = type; _vehicleNickname = nickname;
                                    _customThresholds = thresholds;
                                  });
                                  await _iotController!.saveVehicleProfile(
                                    deviceId: _connectedDeviceId ?? "RSD1",
                                    type: type, nickname: nickname, thresholds: thresholds,
                                  );
                                },
                              ),
                            ),

                          if (_currentScreen == AppScreen.history)
                            HistoryLogsScreen(
                              alerts: _alerts, tempUnit: _tempUnit,
                              distanceUnit: _distanceUnit,
                              onBack: () => _goTo(AppScreen.home),
                            ),

                          if (_currentScreen == AppScreen.settings)
                            Positioned.fill(
                              child: SettingsScreen(
                                userInfo: _userInfo,
                                notificationsEnabled: _notificationsEnabled,
                                soundEnabled: _soundEnabled,
                                tempUnit: _tempUnit, distanceUnit: _distanceUnit,
                                onBack: () => _goTo(AppScreen.home),
                                onNotificationsChanged: (v) {
                                  setState(() => _notificationsEnabled = v);
                                  _saveUserSettingsToDb();
                                },
                                onSoundChanged: (v) {
                                  setState(() => _soundEnabled = v);
                                  _saveUserSettingsToDb();
                                },
                                onTempUnitChanged: (u) {
                                  setState(() => _tempUnit = u);
                                  _saveUserSettingsToDb();
                                },
                                onDistanceUnitChanged: (u) {
                                  setState(() => _distanceUnit = u);
                                  _saveUserSettingsToDb();
                                },
                                onUserInfoChanged: (info) => setState(() => _userInfo = info),
                                onGoToMyAccount: () => _goTo(AppScreen.myAccount),
                              ),
                            ),

                          if (_currentScreen == AppScreen.iotStatus)
                            IoTStatusScreen(
                              iotConnected: _iotConnected, iotPaired: _iotPaired,
                              sensorData: _sensorData, tempUnit: _tempUnit,
                              distanceUnit: _distanceUnit,
                              onConnectDevice: _onConnectIotDevice,
                              onDisconnect: _onDisconnectIotDevice,
                              onBack: () => _goTo(AppScreen.home),
                            ),

                          if (_currentScreen == AppScreen.help)
                            HelpInfoScreen(onBack: () => _goTo(AppScreen.home)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              if (_currentScreen != AppScreen.login &&
                  _currentScreen != AppScreen.signup &&
                  _currentScreen != AppScreen.launch &&
                  _currentScreen != AppScreen.onboarding)
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: BottomNav(
                    currentScreen: _currentScreen,
                    alertCount: _activeAlerts.length,
                    onNavigate: _goTo,
                    onGoToMyAccount: () => _goToMyAccount(returnTo: _currentScreen),
                    onLogout: () async {
                      await _iotSub?.cancel(); await _alertHistorySub?.cancel();
                      _iotSub = null; _alertHistorySub = null; _connectedDeviceId = null;
                      await userController.logout();
                      if (!mounted) return;
                      setState(() {
                        _iotPaired = false; _iotConnected = false; _alerts = [];
                        _sensorData = SensorData(floodLevel: 0, temperature: 0, timestamp: DateTime.now());
                        _currentScreen = AppScreen.login;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}