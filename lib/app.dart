import 'dart:async';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models/models.dart';
import 'screens/home_screen.dart';

enum AppScreen {
  home, help, alerts, vehicle, history, iotStatus
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>{
  late VehicleType _vehicleType;
  late SensorData _sensorData;
  late List<AlertModel> _alerts;
  late bool _iotConnected;
  
  Timer? _sensorTimer;
  
  @override
  void initState() {
    super.initState();
    _vehicleType = VehicleType.sedan;
    _sensorData = SensorData(
        floodLevel: 12, 
        temperature: 35, 
        timestamp: DateTime.now()
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
          severity: AlertSeverity.danger, 
          message: 'DANGER: Engine temperature critically high', 
          timestamp: now.subtract(const Duration(hours: 2)), 
          value: 52,
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
            floodLevel: (prev.floodLevel + (0.5 - (DateTime.now().millisecond % 1000) / 1000) * 3).clamp(0.0, 60.0),
            temperature: (prev.temperature + (0.5 - (DateTime.now().millisecond % 1000) / 1000) * 2).clamp(20.0, 60.0),
            timestamp: DateTime.now()
        );
      });
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    super.dispose();
  }

  VehicleThresholds get _thresholds => VehicleThresholds.forType(_vehicleType);
  List<AlertModel> get _activeAlerts => _alerts.where((a) => !a.acknowledged).toList();

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
                  child: HomeScreen(
                    sensorData: _sensorData,
                    thresholds: _thresholds,
                    vehicleNickname: 'My Vehicle',
                    iotConnected: _iotConnected,
                    onNavigate: (_) {},
                    activeAlerts: [],
                  ),
              ),
            )),
      ),
    );
  }
}