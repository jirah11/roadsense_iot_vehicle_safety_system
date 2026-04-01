import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:roadsense_unang_hirit/backend/firebase_service.dart';
import 'package:roadsense_unang_hirit/screens/help_info_screen.dart';
import 'package:roadsense_unang_hirit/screens/history_logs_screen.dart';
import 'package:roadsense_unang_hirit/screens/settings_screen.dart';
import 'package:roadsense_unang_hirit/screens/vehicle_profile_screen.dart';
import 'app_theme.dart';
import 'models/models.dart';
import 'screens/home_screen.dart';
import 'widgets/bottom_nav.dart';
import 'screens/alerts_screen.dart';
import 'screens/iot_status_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/my_account_screen.dart';


enum AppScreen {
  login,
  signup,
  home,
  alerts,
  vehicle,
  history,
  settings,
  iotStatus,
  help,
  myAccount,
}

enum TemperatureUnit { celsius, fahrenheit }

enum DistanceUnit { centimeters, inches }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppScreen _currentScreen = AppScreen.login;
  bool _isAuthenticated = false; //tinatrack if user ay logged in or nah

  late VehicleType _vehicleType;
  late String _vehicleNickname;
  late SensorData _sensorData;
  late List<AlertModel> _alerts;
  late bool _iotConnected;
  late UserInfo _userInfo; //holds profile data
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  TemperatureUnit _tempUnit = TemperatureUnit.celsius;
  DistanceUnit _distanceUnit = DistanceUnit.centimeters;

  Timer? _sensorTimer;

  @override
  void initState() {
    super.initState();
    _userInfo = const UserInfo();
    _vehicleType = VehicleType.sedan;
    _vehicleNickname = 'My Vehicle';
    _sensorData = SensorData(
      floodLevel: 12,
      temperature: 35,
      timestamp: DateTime.now(),
    );
    _alerts = _initialAlerts();
    _iotConnected = true;
    _notificationsEnabled = true;
    _soundEnabled = true;
    _startSensorSimulation();
  }

  // placeholder alerts muna ok? recent history siya
  List<AlertModel> _initialAlerts() {
    final now = DateTime.now();
    return [
      AlertModel(
        id: '1',
        type: AlertType.flood,
        severity: AlertSeverity.caution,
        message: 'Moderate flood level detected',
        timestamp: now.subtract(const Duration(hours: 1)),
        value: 22,
        acknowledged: false,
      ),
      AlertModel(
        id: '2',
        type: AlertType.temperature,
        severity: AlertSeverity.danger,
        message: 'DANGER: Engine temperature critically high!',
        timestamp: now.subtract(const Duration(hours: 2)),
        value: 52,
        acknowledged: true,
      ),
      AlertModel(
        id: '3',
        type: AlertType.flood,
        severity: AlertSeverity.danger,
        message: 'DANGER: High flood level detected! Avoid this area.',
        timestamp: now.subtract(const Duration(days: 2)),
        value: 38,
        acknowledged: true,
      ),
      AlertModel(
        id: '4',
        type: AlertType.temperature,
        severity: AlertSeverity.caution,
        message: 'CAUTION: Engine temperature elevated. Monitor closely.',
        timestamp: now.subtract(const Duration(days: 5)),
        value: 43,
        acknowledged: true,
      ),
    ];
  }
// generated number every 3 sec for the sensors, kada mag-uupdate, icacall _checkAlerts()
  void _startSensorSimulation() {
    _sensorTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        final prev = _sensorData;
        _sensorData = SensorData(
          floodLevel:
              (prev.floodLevel +
                      (0.5 - (DateTime.now().millisecond % 1000) / 1000) * 3)
                  .clamp(0.0, 60.0),
          temperature:
              (prev.temperature +
                      (0.5 - (DateTime.now().millisecond % 1000) / 1000) * 2)
                  .clamp(20.0, 60.0),
          timestamp: DateTime.now(),
        );
      });
      _checkAlerts();
    });
  }

  // auto-generated yung alerts pag nakalampas sa threshold safety keme

  void _checkAlerts() {
    final thresholds = VehicleThresholds.forType(_vehicleType);
    final newAlerts = <AlertModel>[];

    if (_sensorData.floodLevel >= thresholds.floodDanger) {
      newAlerts.add(
        AlertModel(
          id: 'flood-danger-${DateTime.now().millisecondsSinceEpoch}',
          type: AlertType.flood,
          severity: AlertSeverity.danger,
          message: 'DANGER: High flood level detected! Avoid this area.',
          timestamp: DateTime.now(),
          value: _sensorData.floodLevel,
          acknowledged: false,
        ),
      );
    } else if (_sensorData.floodLevel >= thresholds.floodCaution) {
      newAlerts.add(
        AlertModel(
          id: 'flood-caution-${DateTime.now().millisecondsSinceEpoch}',
          type: AlertType.flood,
          severity: AlertSeverity.caution,
          message: 'CAUTION: Moderate flood level detected. Drive carefully.',
          timestamp: DateTime.now(),
          value: _sensorData.floodLevel,
          acknowledged: false,
        ),
      );
    }

    if (_sensorData.temperature >= thresholds.tempDanger) {
      newAlerts.add(
        AlertModel(
          id: 'temp-danger-${DateTime.now().millisecondsSinceEpoch}',
          type: AlertType.temperature,
          severity: AlertSeverity.danger,
          message: 'DANGER: Engine temperature critically high!',
          timestamp: DateTime.now(),
          value: _sensorData.temperature,
          acknowledged: false,
        ),
      );
    } else if (_sensorData.temperature >= thresholds.tempCaution) {
      newAlerts.add(
        AlertModel(
          id: 'temp-caution-${DateTime.now().millisecondsSinceEpoch}',
          type: AlertType.temperature,
          severity: AlertSeverity.caution,
          message: 'CAUTION: Engine temperature elevated. Monitor closely.',
          timestamp: DateTime.now(),
          value: _sensorData.temperature,
          acknowledged: false,
        ),
      );
    }

    if (newAlerts.isEmpty) return;

    setState(() {
      final existingKeys = _alerts
          .take(3)
          .map((a) => '${a.type}-${a.severity}')
          .toSet();
      final toAdd = newAlerts.where(
        (a) => !existingKeys.contains('${a.type}-${a.severity}'),
      );
      _alerts = [...toAdd, ..._alerts];
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    super.dispose();
  }

  //  Convenience getters

  VehicleThresholds get _thresholds => VehicleThresholds.forType(_vehicleType);

  List<AlertModel> get _activeAlerts =>
      _alerts.where((a) => !a.acknowledged).toList();

  void _goTo(AppScreen screen) => setState(() => _currentScreen = screen);

  void _onLogin(String email, String password) async {
    try {
      final userCredential = await FirebaseService.signIn(email: email, password: password);
      final userModel = await FirebaseService.getUserDocument(userCredential.user!.uid);
      if (userModel != null) {
        setState(() {
          _userInfo = UserInfo(
            firstName: userModel.firstName,
            middleName: userModel.middleName,
            lastName: userModel.lastName,
            email: userModel.email,
            phoneNumber: userModel.phoneNumber,
            createdAt: userModel.createdAt,
            vehicleType: userModel.vehicleType,
            vehicleNickname: userModel.vehicleNickname,
          );
          _vehicleType = vehicleTypeFromString(userModel.vehicleType);
          _vehicleNickname = userModel.vehicleNickname;
          _isAuthenticated = true;
          _currentScreen = AppScreen.home;
        });
      } else {
        // Handle case where user document doesn't exist
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found. Please contact support.')),
          );
        }
      }
    } catch (e) {
      String errorMessage;
      if (e is firebase_auth.FirebaseAuthException && e.code == 'invalid-credential') {
        errorMessage = 'Login denied: Your email or password is incorrect.';
      } else {
        errorMessage = 'Login failed: ${e.toString()}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  void _onSignUp({
    required String firstName,
    required String middleName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await FirebaseService.signUp(email: email, password: password);

      // Create user data
      final created = DateTime.now();
      final createdStr = '${_monthName(created.month)} ${created.day}, ${created.year}';

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: createdStr,
        vehicleType: _vehicleType.name,
        vehicleNickname: _vehicleNickname,
      );

      // Save user data to Firestore
      await FirebaseService.createUserDocument(userModel);

      setState(() {
        _userInfo = UserInfo(
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          createdAt: createdStr,
          vehicleType: _vehicleType.name,
          vehicleNickname: _vehicleNickname,
        );
        _isAuthenticated = true;
        _currentScreen = AppScreen.home;
      });
    } catch (e) {
      // Handle signup errors, e.g., show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.toString()}')),
        );
      }
    }
  }

  String _monthName(int month) {
    const names = ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'];
    return names[month - 1];
  }

  void _onLogout() {
    setState(() {
      _isAuthenticated = false;
      _currentScreen = AppScreen.login;
      _userInfo = const UserInfo();
    });
  }

  void _acknowledgeAlert(String id) {
    setState(() {
      _alerts = _alerts
          .map((a) => a.id == id ? a.copyWith(acknowledged: true) : a)
          .toList();
    });
  }

  void _clearAllAlerts() {
    setState(() {
      _alerts = _alerts.map((a) => a.copyWith(acknowledged: true)).toList();
    });
  }

  void _onDeleteAccount() async {
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        await FirebaseService.deleteUserDocument(uid);
      } catch (_) {
        // ignore errors while deleting user document
      }
    }

    var authDeleted = false;
    try {
      await FirebaseService.deleteAuthUser();
      authDeleted = true;
    } catch (e) {
      // Deleting the auth user might fail if the user needs to reauthenticate.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deletion failed: ${e.toString()}')),
        );
      }
    }

    _onLogout();

    if (mounted && authDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account has been deleted.')),
      );
    }
  }

  // navigation nung mga cards sa home screen



  // build
  // going from home screen to other screens using the nav bar or nav cards sa home screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundStart,
              AppColors.backgroundMid,
              AppColors.backgroundEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Stack(
                children: [
                  if (_currentScreen == AppScreen.login)
                    LoginScreen(
                        onGoToSignUp: () => _goTo(AppScreen.signup),
                        onLogin: _onLogin,
                    ),

                  if (_currentScreen == AppScreen.signup)
                    SignUpScreen(
                      onGoToLogin: () => _goTo(AppScreen.login),
                      onSignUp: _onSignUp,
                    ),

                  if (_currentScreen == AppScreen.myAccount)
                    MyAccountScreen(
                      userInfo: _userInfo,
                      onBack: () => _goTo(AppScreen.settings),
                      onUserInfoChanged: (info) async {
                        final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          await FirebaseService.updateUserDocument(uid, {
                            'firstName': info.firstName,
                            'middleName': info.middleName,
                            'lastName': info.lastName,
                            'email': info.email,
                            'phoneNumber': info.phoneNumber,
                          });
                        }
                        setState(() => _userInfo = info);
                      },
                      onLogout: _onLogout,
                      onDeleteAccount: _onDeleteAccount,
                    ),

                  if (_currentScreen == AppScreen.home)
                    HomeScreen(
                      sensorData: _sensorData,
                      thresholds: _thresholds,
                      vehicleNickname: _vehicleNickname,
                      activeAlerts: _activeAlerts,
                      iotConnected: _iotConnected,
                      tempUnit: _tempUnit,
                      distanceUnit: _distanceUnit,
                      onNavigate: _goTo,
                    ),

                  if (_currentScreen == AppScreen.alerts)
                    AlertsScreen(
                      alerts: _alerts,
                      tempUnit: _tempUnit,
                      distanceUnit: _distanceUnit,
                      onBack: () => _goTo(AppScreen.home),
                      onAcknowledge: _acknowledgeAlert,
                      onClearAll: _clearAllAlerts,
                    ),

                  if (_currentScreen == AppScreen.vehicle)
                    VehicleProfileScreen(
                      vehicleType: _vehicleType,
                      vehicleNickname: _vehicleNickname,
                      thresholds: _thresholds,
                      onBack: () => _goTo(AppScreen.home),
                      onSave: (type, nickname, thresholds) async {
                        setState(() {
                          _vehicleType = type;
                          _vehicleNickname = nickname;
                        });

                        final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          await FirebaseService.updateUserDocument(uid, {
                            'vehicleType': type.name,
                            'vehicleNickname': nickname,
                          });
                        }
                      },
                    ),

                  if (_currentScreen == AppScreen.history)
                    HistoryLogsScreen(
                        alerts: _alerts,
                        tempUnit: _tempUnit,
                        distanceUnit: _distanceUnit,
                        onBack: () => _goTo(AppScreen.home),
                    ),

                  if (_currentScreen == AppScreen.settings)
                    Positioned.fill(
                        child: SettingsScreen(
                          userInfo: _userInfo,
                          notificationsEnabled: _notificationsEnabled,
                          soundEnabled: _soundEnabled,
                          tempUnit: _tempUnit,
                          distanceUnit: _distanceUnit,
                          onBack: () => _goTo(AppScreen.home),
                          onNotificationsChanged: (v) => setState(() => _notificationsEnabled = v),
                          onSoundChanged: (v) => setState(() => _soundEnabled = v),
                          onTempUnitChanged: (u) => setState(() => _tempUnit = u),
                          onDistanceUnitChanged: (u) => setState(() => _distanceUnit = u),
                          onUserInfoChanged: (info) => setState(() => _userInfo = info),
                          onGoToMyAccount: () => _goTo(AppScreen.myAccount),
                        ),
                    ),


                  if (_currentScreen == AppScreen.iotStatus)
                    IoTStatusScreen(
                      iotConnected: _iotConnected,
                      sensorData: _sensorData,
                      tempUnit: _tempUnit,
                      distanceUnit: _distanceUnit,
                      onBack: () => _goTo(AppScreen.home),
                    ),

                  if (_currentScreen == AppScreen.help)
                    HelpInfoScreen(onBack: () => _goTo(AppScreen.home),
                    ),

                  if (_currentScreen != AppScreen.login &&
                      _currentScreen != AppScreen.signup)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomNav(
                      currentScreen: _currentScreen,
                      alertCount: _activeAlerts.length,
                      onNavigate: _goTo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//pag hinde pa gawa ang screen, ayan muna ang lalabas
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  final VoidCallback onBack;

  const _PlaceholderScreen({required this.label, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.backgroundStart,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, color: AppColors.accent, size: 48),
          const SizedBox(height: 16),
          Text(
            '$label — Coming Soon',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This screen hasn\'t been made yet.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.accent),
            label: const Text(
              'Back to Home',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
