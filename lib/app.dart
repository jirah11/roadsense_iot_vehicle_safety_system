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
import 'screens/launch_screen.dart';
import 'screens/onboarding_screen.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:provider/provider.dart';
import 'backend/controller/user.dart';

//--ENUMS--
enum AppScreen {
  launch,
  onboarding,
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
  // - - 1. NAVIGATION + AUTH STATE - -
  AppScreen _currentScreen = AppScreen.launch;
  AppScreen _myAccountReturnTo = AppScreen.settings;

  // - - 2. VEHICLE + USER DATA - -
  late VehicleType _vehicleType;
  late String _vehicleNickname;
  late UserInfo _userInfo; //holds profile data

  // - - 3. IOT + SENSOR DATA - -
  late SensorData _sensorData;
  late List<AlertModel> _alerts;
  late bool _iotConnected;
  late bool _iotPaired;
  Timer? _sensorTimer; //simulation

  // - - 4. USER PREFERENCES - -
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  TemperatureUnit _tempUnit = TemperatureUnit.celsius;
  DistanceUnit _distanceUnit = DistanceUnit.centimeters;

  // - - 5. LIFECYCLE METHODS - -
  @override
  void initState() {
    super.initState();
    _userInfo = const UserInfo();
    _vehicleType = VehicleType.sedan;
    _vehicleNickname = 'My Vehicle';
    _sensorData = SensorData(
      floodLevel: 0,
      temperature: 0,
      timestamp: DateTime.now(),
    );
    _alerts = [];
    _iotConnected = false;
    _iotPaired = false;
    _notificationsEnabled = true;
    _soundEnabled = true;
    _startSensorSimulation(); //3 sec loop

    // ✅ FIX: AUTO LOAD USER IF ALREADY LOGGED IN
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userController = context.read<UserController>();

      if (userController.isAuthenticated) {
        print("🔄 AUTO-LOADING USER ON APP START...");
        // await userController.refreshUser();
        print("✅ USER LOADED: ${userController.userModel}");
      }
    });
  }

  @override
  void dispose() {
    //cancel timer para iwas memory leaks
    _sensorTimer?.cancel();
    super.dispose();
  }

  // - - 6. NAVIGATION LOGIC - -
  void _goTo(AppScreen screen) => setState(() => _currentScreen = screen);

  void _goToMyAccount({required AppScreen returnTo}) {
    final userController = context.read<UserController>();

    userController.refreshUser(); // 🔥 THIS LINE FIXES YOUR PROBLEM

    setState(() {
      _myAccountReturnTo = returnTo;
      _currentScreen = AppScreen.myAccount;
    });
  }

  // - - 8. IOT + SENSOR LOGIC - -
  //check if nagfoflow data
  bool get _iotLive => _iotPaired && _iotConnected;

  //simulates real time sensor
  // generated number every 3 sec for the sensors, kada mag-uupdate, icacall _checkAlerts()
  void _startSensorSimulation() {
    _sensorTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        if (!_iotLive) {
          _sensorData = SensorData(
            floodLevel: 0,
            temperature: 0,
            timestamp: DateTime.now(),
          );
          return;
        }
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
    if (!_iotLive) return;
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

  //logic sa pair and connect para sa iot sensor device
  void _onConnectIotDevice({
    required String deviceId,
    required String password,
  }) {
    setState(() {
      //mark device both paired, saved sa settings tapos connected sa ano keme sa lahat
      _iotPaired = true;
      _iotConnected = true;
      //ui shi pag connected na sa sensor reading
      _sensorData = SensorData(
        floodLevel: 12,
        temperature: 35,
        timestamp: DateTime.now(),
      );
    });
  }

  //handles logic sa disconnecting shi
  void _onDisconnectIotDevice() {
    setState(() {
      //resets connection states
      _iotPaired = false;
      _iotConnected = false;
      //tanggal lahat ng nasa alerts list since wala na iot aww :((
      _alerts = [];
      //no sensor data, back to 0
      _sensorData = SensorData(
        floodLevel: 0,
        temperature: 0,
        timestamp: DateTime.now(),
      );
    });
  }

  // - - 9. ALERT MANAGEMENT - -
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

  //  - - 10. CONVENIENCE GETTERS + HELPERS - -
  VehicleThresholds get _thresholds => VehicleThresholds.forType(_vehicleType);
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

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }

  // build
  // going from home screen to other screens using the nav bar or nav cards sa home screen
  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>(); // ✅ HERE
    return Scaffold(
      //main container
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
          //prevents ui from overlapping
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
                          //conditional rendering para malaman kung anong screen active
                          //based sa _currentScreen
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

                                  setState(() {
                                    _currentScreen = AppScreen.home;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Login failed"),
                                    ),
                                  );
                                }
                              },
                            ),

                          if (_currentScreen == AppScreen.signup)
                            SignUpScreen(
                              onGoToLogin: () => _goTo(AppScreen.login),
                              onSignUp:
                                  ({
                                    required String firstName,
                                    required String middleName,
                                    required String lastName,
                                    required String email,
                                    required String phoneNumber,
                                    required String password,
                                  }) async {
                                    try {
                                      await userController.signup(
                                        firstName: firstName,
                                        middleName: middleName,
                                        lastName: lastName,
                                        email: email,
                                        phoneNumber: phoneNumber,
                                        password: password,
                                        vehicleType: "sedan",
                                        vehicleNickname: "My Vehicle",
                                      );

                                      if (!context.mounted) return;

                                      setState(() {
                                        _currentScreen = AppScreen.home;
                                      });
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  },
                            ),

                          if (_currentScreen == AppScreen.myAccount) ...[
                            Builder(
                              builder: (context) {
                                final user = userController.userModel;
                                print("🖥️ UI USER MODEL: $user");
                                // Optional loading state
                                if (user == null) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                return MyAccountScreen(
                                  userInfo: UserInfo(
                                    firstName: user.firstName,
                                    middleName: user.middleName,
                                    lastName: user.lastName,
                                    email: user.email,
                                    phoneNumber: user.phoneNumber,
                                    createdAt: user.createdAt,
                                  ),

                                  onBack: () => _goTo(_myAccountReturnTo),
                                  onUserInfoChanged: (info) async {
                                    await userController.updateProfile({
                                      'firstName': info.firstName,
                                      'middleName': info.middleName,
                                      'lastName': info.lastName,
                                      'email': info.email,
                                      'phoneNumber': info.phoneNumber,
                                    });

                                    await userController
                                        .refreshUser(); // 🔥 THIS IS THE MISSING PART
                                  },

                                  onLogout: () async {
                                    await userController.logout();
                                    if (!mounted) return;
                                    _goTo(AppScreen.login);
                                  },

                                  onDeleteAccount: () async {
                                    await userController.deleteAccount();
                                    if (!mounted) return;
                                    _goTo(AppScreen.login);
                                  },
                                );
                              },
                            ),
                          ],

                          if (_currentScreen == AppScreen.home)
                            HomeScreen(
                              sensorData: _sensorData,
                              thresholds: _thresholds,
                              vehicleNickname: _vehicleNickname,
                              activeAlerts: _activeAlerts,
                              iotConnected: _iotConnected,
                              iotLive: _iotLive,
                              tempUnit: _tempUnit,
                              distanceUnit: _distanceUnit,
                              onNavigate: _goTo,
                            ),

                          if (_currentScreen == AppScreen.alerts)
                            AlertsScreen(
                              alerts: _alerts,
                              iotLive: _iotLive,
                              tempUnit: _tempUnit,
                              distanceUnit: _distanceUnit,
                              onBack: () => _goTo(AppScreen.home),
                              onAcknowledge: _acknowledgeAlert,
                              onClearAll: _clearAllAlerts,
                            ),

                          if (_currentScreen == AppScreen.vehicle)
                            Positioned.fill(
                              child: VehicleProfileScreen(
                                vehicleType: _vehicleType,
                                vehicleNickname: _vehicleNickname,
                                thresholds: _thresholds,
                                onBack: () => _goTo(AppScreen.home),
                                onSave: (type, nickname, thresholds) async {
                                  setState(() {
                                    _vehicleType = type;
                                    _vehicleNickname = nickname;
                                  });
                                  //sync update vehicle stuff sa firestore
                                  final uid = firebase_auth
                                      .FirebaseAuth
                                      .instance
                                      .currentUser
                                      ?.uid;
                                  if (uid != null) {
                                    await FirebaseService.updateUserDocument(
                                      uid,
                                      {
                                        'vehicleType': type.name,
                                        'vehicleNickname': nickname,
                                      },
                                    );
                                  }
                                },
                              ),
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
                                onNotificationsChanged: (v) =>
                                    setState(() => _notificationsEnabled = v),
                                onSoundChanged: (v) =>
                                    setState(() => _soundEnabled = v),
                                onTempUnitChanged: (u) =>
                                    setState(() => _tempUnit = u),
                                onDistanceUnitChanged: (u) =>
                                    setState(() => _distanceUnit = u),
                                onUserInfoChanged: (info) =>
                                    setState(() => _userInfo = info),
                                onGoToMyAccount: () =>
                                    _goTo(AppScreen.myAccount),
                              ),
                            ),

                          if (_currentScreen == AppScreen.iotStatus)
                            IoTStatusScreen(
                              iotConnected: _iotConnected,
                              iotPaired: _iotPaired,
                              sensorData: _sensorData,
                              tempUnit: _tempUnit,
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
              //overlay layer
              // //magdidisplay lang bottomnav if not on auth/onboarding screens
              if (_currentScreen != AppScreen.login &&
                  _currentScreen != AppScreen.signup &&
                  _currentScreen != AppScreen.launch &&
                  _currentScreen != AppScreen.onboarding)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomNav(
                    currentScreen: _currentScreen,
                    alertCount: _activeAlerts.length,
                    onNavigate: _goTo,
                    onGoToMyAccount: () =>
                        _goToMyAccount(returnTo: _currentScreen),
                    onLogout: () async {
                      await userController.logout();
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
