import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../app_theme.dart';
import '../models/sensor_data.dart';

//mga pang-call if kunware, gusto mo siya ipunta sa screen, ganto ok?
class IoTStatusScreen extends StatelessWidget {
  final bool iotConnected;
  final SensorData? sensorData;
  final TemperatureUnit tempUnit;
  final DistanceUnit distanceUnit;
  final VoidCallback onBack;

  const IoTStatusScreen({
    super.key,
    required this.iotConnected,
    this.sensorData,
    required this.tempUnit,
    required this.distanceUnit,
    required this.onBack,
  });

  //"last updated" eme
  String _formatLastSync() {
    final lastSync = DateTime.now().subtract(const Duration(minutes: 2));
    final diff = DateTime.now().difference(lastSync);
    if (diff.inSeconds < 60) return '${diff.inSeconds} seconds ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  //placeholder lang siya, information kunware ng iot device
  @override
  Widget build(BuildContext context) {
    const deviceId = 'RS-IOT-2026-1234';
    const deviceModel = 'RoadSense V1';
    const serialNumber = 'SN-12A-345-BCD';
    const firmwareVersion = 'v1.0.0';
    const signalStrength = 85;
    const batteryLevel = 78;
    const isCharging = false;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IoT Status',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Device & Connection',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: iotConnected
                    ? [AppColors.emerald, AppColors.emeraldDark]
                    : [AppColors.rose, AppColors.roseDark],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  iotConnected ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        iotConnected ? 'Connected' : 'Disconnected',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        iotConnected ? 'Device is online' : 'Device is offline',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: iotConnected ? Colors.white : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16), //placeholder info lang sa iot since wala pa naman backend
          _progressCard(
            'Signal Strength',
            'Network connection quality',
            Icons.wifi,
            signalStrength,
            signalStrength >= 70
                ? AppColors.emerald
                : (signalStrength >= 40 ? AppColors.caution : AppColors.rose),
            signalStrength >= 70
                ? 'Excellent'
                : (signalStrength >= 40 ? 'Good' : 'Poor'),
          ),
          const SizedBox(height: 16),
          _progressCard(
            'Battery Level',
            'Device power status',
            isCharging ? Icons.battery_charging_full : Icons.battery_std,
            batteryLevel,
            batteryLevel >= 60
                ? AppColors.emerald
                : (batteryLevel >= 30 ? AppColors.caution : AppColors.rose),
            batteryLevel >= 60
                ? 'Good'
                : (batteryLevel >= 30 ? 'Low' : 'Critical'),
          ),
          const SizedBox(height: 24),
          _infoCard(
            'Device Information',
            'Hardware & software details',
            Icons.memory,
            [
              _row('Device ID', deviceId, Icons.tag),
              _row('Device Model', deviceModel, Icons.memory),
              _row('Serial Number', serialNumber, Icons.tag),
              _row('Firmware Version', firmwareVersion, Icons.verified_user),
              _row('Last Sync', _formatLastSync(), Icons.refresh),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Sensor Status',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _sensorTile(
            'Flood Level Sensor',
            'Ultrasonic distance sensor',
            Icons.water_drop,
            _formatFloodReading(),
          ),
          const SizedBox(height: 12),
          _sensorTile(
            'Temperature Sensor',
            'Digital thermometer',
            Icons.thermostat,
            _formatTempReading(),
          ),
        ],
      ),
    );
  }

  //sensor status
  // random values tas numbers muna since wala pa orig data
  String _formatFloodReading() {
    if (sensorData == null) return 'N/A';
    final useInches = distanceUnit == DistanceUnit.inches;
    final value = useInches
        ? sensorData!.floodLevel / 2.54
        : sensorData!.floodLevel;
    final unit = useInches ? 'in' : 'cm';
    return '${value.toStringAsFixed(1)} $unit';
  }

  String _formatTempReading() {
    if (sensorData == null) return 'N/A';
    final useFahrenheit = tempUnit == TemperatureUnit.fahrenheit;
    final value = useFahrenheit
        ? sensorData!.temperature * 9 / 5 + 32
        : sensorData!.temperature;
    final unit = useFahrenheit ? '°F' : '°C';
    return '${value.toStringAsFixed(1)} $unit';
  }

  Widget _progressCard(
    String title,
    String subtitle,
    IconData icon,
    int value,
    Color color,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardDark, AppColors.cardDarker],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Strength', style: GoogleFonts.inter(color: Colors.white70)),
              Text(
                '$value%',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    String title,
    String subtitle,
    IconData icon,
    List<Widget> rows,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardDark, AppColors.cardDarker],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white60),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sensorTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardDarker, Color(0xFF2F3D54)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Reading:',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
