import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../app_theme.dart';
import '../models/models.dart';

//mga pang-call YEHEY I AM GOING INSANE
class AlertsScreen extends StatelessWidget {
  final List<AlertModel> alerts;
  final VoidCallback onBack;
  final void Function(String id) onAcknowledge;
  final VoidCallback onClearAll;
  final TemperatureUnit tempUnit;
  final DistanceUnit distanceUnit;

  const AlertsScreen({
    super.key,
    required this.alerts,
    required this.onBack,
    required this.onAcknowledge,
    required this.onClearAll,
    required this.tempUnit,
    required this.distanceUnit,
  });

  //mga getter
  List<AlertModel> get activeAlerts =>
      alerts.where((a) => !a.acknowledged).toList();
  List<AlertModel> get acknowledgedAlerts =>
      alerts.where((a) => a.acknowledged).toList();

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  //container ng alert cards, mga status banners din caution and danger + the active alert ewan ko teh andiyan naman na siya
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.3),
                ),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alerts',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Safety notifications',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (activeAlerts.isNotEmpty)
                TextButton(
                  onPressed: onClearAll,
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (activeAlerts.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF547792)],
                ),
                borderRadius: BorderRadius.circular(20),
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.rose,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${activeAlerts.length} Active Alert${activeAlerts.length > 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Requires your attention',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (activeAlerts.isEmpty && alerts.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.emerald, AppColors.emeraldDark],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All Clear',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'No active alerts at this time',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          if (activeAlerts.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Active Warnings',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...activeAlerts.map(
              (a) => _AlertCard(
                alert: a,
                isActive: true,
                formatTime: _formatTime,
                onAcknowledge: onAcknowledge,
                tempUnit: tempUnit,
                distanceUnit: distanceUnit,
              ),
            ),
          ],
          if (acknowledgedAlerts.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Recent History',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            ...acknowledgedAlerts
                .take(5)
                .map(
                  (a) => _AlertCard(
                    alert: a,
                    isActive: false,
                    formatTime: _formatTime,
                    onAcknowledge: onAcknowledge,
                    tempUnit: tempUnit,
                    distanceUnit: distanceUnit,
                  ),
                ),
          ],
          if (alerts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.accent,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Alerts Yet',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "You'll see safety notifications here",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.accent,
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

//babasahin mo ba 'to sir pinca?
class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  final bool isActive;
  final String Function(DateTime) formatTime;
  final void Function(String) onAcknowledge;
  final TemperatureUnit tempUnit;
  final DistanceUnit distanceUnit;

  const _AlertCard({
    required this.alert,
    required this.isActive,
    required this.formatTime,
    required this.onAcknowledge,
    required this.tempUnit,
    required this.distanceUnit,
  });

  // loob ng alert cards
  @override
  Widget build(BuildContext context) {
    final isDanger = alert.severity == AlertSeverity.danger;
    final gradient = isDanger
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.caution, AppColors.cautionDark],
          );
    final icon = alert.type == AlertType.flood
        ? Icons.water_drop
        : Icons.thermostat;
    final bool isFlood = alert.type == AlertType.flood;
    final String unit;
    double displayValue;
    if (isFlood) {
      if (distanceUnit == DistanceUnit.inches) {
        displayValue = alert.value / 2.54;
        unit = ' in';
      } else {
        displayValue = alert.value;
        unit = ' cm';
      }
    } else {
      if (tempUnit == TemperatureUnit.fahrenheit) {
        displayValue = alert.value * 9 / 5 + 32;
        unit = ' °F';
      } else {
        displayValue = alert.value;
        unit = ' °C';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: isActive ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${alert.type.name.toUpperCase()} Alert',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            if (!isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Acknowledged',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          formatTime(alert.timestamp),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    IconButton(
                      onPressed: () => onAcknowledge(alert.id),
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alert.message,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${displayValue.toStringAsFixed(1)}$unit',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      alert.severity.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
