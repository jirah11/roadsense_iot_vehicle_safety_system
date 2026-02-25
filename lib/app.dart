import 'dart:async';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models/models.dart';
import 'screens/home_screen.dart';
import 'widgets/bottom_nav.dart';
import 'screens/alerts_screen.dart';

enum AppScreen {
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
  AppScreen _currentScreen = AppScreen.home;

  late VehicleType _vehicleType;
  late String _vehicleNickname;
  late SensorData _sensorData;
  late List<AlertModel> _alerts;
  late bool _iotConnected;

  TemperatureUnit _tempUnit = TemperatureUnit.celsius;
  DistanceUnit _distanceUnit = DistanceUnit.centimeters;

  Timer? _sensorTimer;

  @override
  void initState() {
    super.initState();
    _vehicleType = VehicleType.sedan;
    _vehicleNickname = 'My Vehicle';
    _sensorData = SensorData(
      floodLevel: 12,
      temperature: 35,
      timestamp: DateTime.now(),
    );
    _alerts = _initialAlerts();
    _iotConnected = true;
    _startSensorSimulation();
  }


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

  void _startSensorSimulation() {
    _sensorTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        final prev = _sensorData;
        _sensorData = SensorData(
          floodLevel: (prev.floodLevel +
              (0.5 - (DateTime.now().millisecond % 1000) / 1000) * 3)
              .clamp(0.0, 60.0),
          temperature: (prev.temperature +
              (0.5 - (DateTime.now().millisecond % 1000) / 1000) * 2)
              .clamp(20.0, 60.0),
          timestamp: DateTime.now(),
        );
      });
      _checkAlerts();
    });
  }

  // --- Auto-generate alerts when thresholds are crossed ---

  void _checkAlerts() {
    final thresholds = VehicleThresholds.forType(_vehicleType);
    final newAlerts = <AlertModel>[];

    if (_sensorData.floodLevel >= thresholds.floodDanger) {
      newAlerts.add(AlertModel(
        id: 'flood-danger-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.flood,
        severity: AlertSeverity.danger,
        message: 'DANGER: High flood level detected! Avoid this area.',
        timestamp: DateTime.now(),
        value: _sensorData.floodLevel,
        acknowledged: false,
      ));
    } else if (_sensorData.floodLevel >= thresholds.floodCaution) {
      newAlerts.add(AlertModel(
        id: 'flood-caution-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.flood,
        severity: AlertSeverity.caution,
        message: 'CAUTION: Moderate flood level detected. Drive carefully.',
        timestamp: DateTime.now(),
        value: _sensorData.floodLevel,
        acknowledged: false,
      ));
    }

    if (_sensorData.temperature >= thresholds.tempDanger) {
      newAlerts.add(AlertModel(
        id: 'temp-danger-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.temperature,
        severity: AlertSeverity.danger,
        message: 'DANGER: Engine temperature critically high!',
        timestamp: DateTime.now(),
        value: _sensorData.temperature,
        acknowledged: false,
      ));
    } else if (_sensorData.temperature >= thresholds.tempCaution) {
      newAlerts.add(AlertModel(
        id: 'temp-caution-${DateTime.now().millisecondsSinceEpoch}',
        type: AlertType.temperature,
        severity: AlertSeverity.caution,
        message: 'CAUTION: Engine temperature elevated. Monitor closely.',
        timestamp: DateTime.now(),
        value: _sensorData.temperature,
        acknowledged: false,
      ));
    }

    if (newAlerts.isEmpty) return;

    setState(() {
      final existingKeys =
      _alerts.take(3).map((a) => '${a.type}-${a.severity}').toSet();
      final toAdd = newAlerts
          .where((a) => !existingKeys.contains('${a.type}-${a.severity}'));
      _alerts = [...toAdd, ..._alerts];
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    super.dispose();
  }

  // --- Convenience getters ---

  VehicleThresholds get _thresholds => VehicleThresholds.forType(_vehicleType);
  List<AlertModel> get _activeAlerts =>
      _alerts.where((a) => !a.acknowledged).toList();

  // --- Navigation ---

  void _goTo(AppScreen screen) => setState(() => _currentScreen = screen);

  // --- Build ---

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


                  if (_currentScreen == AppScreen.vehicle)
                    _PlaceholderScreen(
                      label: 'Vehicle',
                      onBack: () => _goTo(AppScreen.home),
                    ),
                  if (_currentScreen == AppScreen.history)
                    _PlaceholderScreen(
                      label: 'History',
                      onBack: () => _goTo(AppScreen.home),
                    ),
                  if (_currentScreen == AppScreen.settings)
                    _PlaceholderScreen(
                      label: 'Settings',
                      onBack: () => _goTo(AppScreen.home),
                    ),
                  if (_currentScreen == AppScreen.iotStatus)
                    _PlaceholderScreen(
                      label: 'IoT Status',
                      onBack: () => _goTo(AppScreen.home),
                    ),
                  if (_currentScreen == AppScreen.help)
                    _PlaceholderScreen(
                      label: 'Help & Info',
                      onBack: () => _goTo(AppScreen.home),
                    ),

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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.accent),
            label: const Text('Back to Home',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

