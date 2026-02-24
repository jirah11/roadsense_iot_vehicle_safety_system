import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../app_theme.dart';
import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  final SensorData sensorData;
  final VehicleThresholds thresholds;
  final String vehicleNickname;
  final List<AlertModel> activeAlerts;
  final bool iotConnected;
  final TemperatureUnit tempUnit;
  final DistanceUnit distanceUnit;
  final ValueChanged<AppScreen> onNavigate;

  const HomeScreen({
    super.key,
    required this.sensorData,
    required this.thresholds,
    required this.vehicleNickname,
    required this.activeAlerts,
    required this.iotConnected,
    required this.tempUnit,
    required this.distanceUnit,
    required this.onNavigate,
  });

  // Returns 'SAFE', 'CAUTION', or 'DANGER' for flood level
  String _floodStatus() {
    if (sensorData.floodLevel >= thresholds.floodDanger) return 'DANGER';
    if (sensorData.floodLevel >= thresholds.floodCaution) return 'CAUTION';
    return 'SAFE';
  }

  // Returns 'SAFE', 'CAUTION', or 'DANGER' for temperature
  String _tempStatus() {
    if (sensorData.temperature >= thresholds.tempDanger) return 'DANGER';
    if (sensorData.temperature >= thresholds.tempCaution) return 'CAUTION';
    return 'SAFE';
  }

  // Maps a status string to its display color
  Color _statusColor(String status) {
    if (status == 'DANGER') return AppColors.rose;
    if (status == 'CAUTION') return AppColors.caution;
    return AppColors.emerald;
  }

  // Progress bar fill (0.0 - 1.0) for flood and temperature
  double _floodPercent() => (sensorData.floodLevel / 60).clamp(0.0, 1.0);
  double _tempPercent() =>
      ((sensorData.temperature - 20) / 40).clamp(0.0, 1.0);

  // Formats the sensor timestamp as hh:mm:ss AM/PM
  // Note: called with () in the build method — _lastUpdated()
  String _lastUpdated() {
    final t = sensorData.timestamp;
    final hour = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final floodStatus = _floodStatus();
    final tempStatus = _tempStatus();

    // Convert units for display (internal data is always cm / °C)
    final bool useInches = distanceUnit == DistanceUnit.inches;
    final bool useFahrenheit = tempUnit == TemperatureUnit.fahrenheit;

    final double displayFlood =
    useInches ? sensorData.floodLevel / 2.54 : sensorData.floodLevel;
    final String floodUnit = useInches ? 'in' : 'cm';

    final double displayTemp = useFahrenheit
        ? sensorData.temperature * 9 / 5 + 32
        : sensorData.temperature;
    final String tempUnitLabel = useFahrenheit ? '°F' : '°C';

    // Threshold labels shown below the progress bar
    final String floodCautionLabel = useInches
        ? 'Caution: ${(thresholds.floodCaution / 2.54).toStringAsFixed(1)}in'
        : 'Caution: ${thresholds.floodCaution}cm';
    final String floodDangerLabel = useInches
        ? 'Danger: ${(thresholds.floodDanger / 2.54).toStringAsFixed(1)}in'
        : 'Danger: ${thresholds.floodDanger}cm';

    final String tempCautionLabel = useFahrenheit
        ? 'Caution: ${(thresholds.tempCaution * 9 / 5 + 32).toStringAsFixed(1)}°F'
        : 'Caution: ${thresholds.tempCaution}°C';
    final String tempDangerLabel = useFahrenheit
        ? 'Danger: ${(thresholds.tempDanger * 9 / 5 + 32).toStringAsFixed(1)}°F'
        : 'Danger: ${thresholds.tempDanger}°C';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RoadSense',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Vehicle Safety Monitor',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.accent),
                  ),
                ],
              ),
              Row(
                children: [
                  // Green/red dot indicating IoT connection status
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: iotConnected ? AppColors.emerald : AppColors.rose,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (iotConnected
                              ? AppColors.emerald
                              : AppColors.rose)
                              .withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    iotConnected ? 'Connected' : 'Offline',
                    style:
                    GoogleFonts.inter(fontSize: 12, color: AppColors.accent),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Active alerts banner (only shown when there are active alerts) ---
          if (activeAlerts.isNotEmpty)
            GestureDetector(
              onTap: () => onNavigate(AppScreen.alerts),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.rose.withValues(alpha: 0.5),
                      AppColors.roseDark.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: AppColors.rose.withValues(alpha: 0.3)),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.rose,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${activeAlerts.length} Active Alert${activeAlerts.length > 1 ? 's' : ''}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Tap to view details',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'View',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.rose,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (activeAlerts.isNotEmpty) const SizedBox(height: 24),

          // --- Sensor cards (Flood + Temperature side by side) ---
          Row(
            children: [
              Expanded(
                child: _SensorCard(
                  title: 'Flood Level',
                  value: displayFlood.toStringAsFixed(1),
                  unit: floodUnit,
                  status: floodStatus,
                  statusColor: _statusColor(floodStatus),
                  progress: _floodPercent(),
                  cautionLabel: floodCautionLabel,
                  dangerLabel: floodDangerLabel,
                  icon: Icons.water_drop,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SensorCard(
                  title: 'Temperature',
                  value: displayTemp.toStringAsFixed(1),
                  unit: tempUnitLabel,
                  status: tempStatus,
                  statusColor: _statusColor(tempStatus),
                  progress: _tempPercent(),
                  cautionLabel: tempCautionLabel,
                  dangerLabel: tempDangerLabel,
                  icon: Icons.thermostat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // FIX: was '$_lastUpdated' (printed the closure), now correctly calls _lastUpdated()
          Center(
            child: Text(
              'Last updated: ${_lastUpdated()}',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
            ),
          ),
          const SizedBox(height: 24),

          // --- Navigation shortcut cards ---
          Row(
            children: [
              Expanded(
                child: _NavCard(
                  title: 'Alerts',
                  subtitle: 'View warnings',
                  icon: Icons.warning_amber_rounded,
                  badge: activeAlerts.length,
                  onTap: () => onNavigate(AppScreen.alerts),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _NavCard(
                  title: 'Vehicle',
                  subtitle: 'Profile settings',
                  icon: Icons.directions_car,
                  onTap: () => onNavigate(AppScreen.vehicle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _NavCard(
                  title: 'History',
                  subtitle: 'Past alerts',
                  icon: Icons.history,
                  onTap: () => onNavigate(AppScreen.history),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _NavCard(
                  title: 'IoT Status',
                  subtitle: 'Device info',
                  icon: Icons.wifi,
                  onTap: () => onNavigate(AppScreen.iotStatus),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Help button ---
          GestureDetector(
            onTap: () => onNavigate(AppScreen.help),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.help_outline, color: AppColors.accent, size: 22),
                  const SizedBox(height: 8),
                  Text(
                    'Help & Info',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SensorCard — displays flood level or temperature with a progress bar
// ---------------------------------------------------------------------------

class _SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String status;
  final Color statusColor;
  final double progress;
  final String cautionLabel;
  final String dangerLabel;
  final IconData icon;

  const _SensorCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.progress,
    required this.cautionLabel,
    required this.dangerLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: removed AspectRatio(aspectRatio: 1) which caused overflow.
    // mainAxisSize.min lets the Column shrink to fit its content.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardDark, AppColors.cardDarker],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // shrink-wraps to content
        children: [
          // Icon + status badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
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

          // Label
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Big value display
          Center(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: value),
                  TextSpan(
                    text: unit,
                    style: GoogleFonts.inter(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          // Caution / Danger threshold labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  cautionLabel,
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.white38),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  dangerLabel,
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.white38),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF547792)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Red badge dot shown when there are unread alerts
            if (badge > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.rose,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

