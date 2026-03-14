import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../app_theme.dart';
import '../models/models.dart';

//call call call, you used to call me on my cellphone, late night when you need my love
class HistoryLogsScreen extends StatefulWidget {
  final List<AlertModel> alerts;
  final VoidCallback onBack;
  final TemperatureUnit tempUnit;
  final DistanceUnit distanceUnit;


  const HistoryLogsScreen({
    super.key,
    required this.alerts,
    required this.onBack,
    required this.tempUnit,
    required this.distanceUnit,
  });

//filters the timeframe
  @override
  State<HistoryLogsScreen> createState() => _HistoryLogsScreenState();
}


class _HistoryLogsScreenState extends State<HistoryLogsScreen> {
  String _filter = 'all'; // today, week, month, all

  List<AlertModel> get _filteredAlerts {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));


    return widget.alerts.where((a) {
      final d = a.timestamp;
      switch (_filter) {
        case 'today':
          return d.isAfter(today.subtract(const Duration(days: 1)));
        case 'week':
          return d.isAfter(weekAgo);
        case 'month':
          return d.isAfter(monthAgo);
        default:
          return true;
      }
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    //renders the filtered list galing sa logic sa taas
    final filtered = _filteredAlerts;
    final total = filtered.length;
    final floodCount = filtered.where((a) => a.type == AlertType.flood).length;
    final tempCount = filtered.where((a) => a.type == AlertType.temperature).length;
    final dangerCount = filtered.where((a) => a.severity == AlertSeverity.danger).length;


    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.accent, size: 26),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('History & Logs', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('View past alerts', style: GoogleFonts.inter(fontSize: 14, color: AppColors.accent)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('Today', 'today'),
                const SizedBox(width: 8),
                _chip('Last Week', 'week'),
                const SizedBox(width: 8),
                _chip('Last Month', 'month'),
                const SizedBox(width: 8),
                _chip('All', 'all'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _StatCard(value: '$total', label: 'Total Alerts', icon: Icons.trending_up),
              _StatCard(value: '$floodCount', label: 'Flood Alerts', icon: Icons.water_drop, color: AppColors.accent),
              _StatCard(value: '$tempCount', label: 'Temp Alerts', icon: Icons.thermostat),
              _StatCard(value: '$dangerCount', label: 'Danger Level', icon: Icons.warning_amber_rounded, color: AppColors.rose),
            ],
          ),
          const SizedBox(height: 24),
          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.cardDark, AppColors.cardDarker]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: AppColors.emerald, size: 48),
                  const SizedBox(height: 12),
                  Text('No Alerts Found', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                  Text(
                    _filter == 'all' ? 'No alerts have been recorded yet.' : 'No alerts found for the selected time period.',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...filtered.map(
                  (a) => _HistoryCard(
                alert: a,
                tempUnit: widget.tempUnit,
                distanceUnit: widget.distanceUnit,
              ),
            ),
        ],
      ),
    );
  }


  Widget _chip(String label, String value) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, Color(0xFF547792)]) : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: isActive ? Colors.white : Colors.white70)),
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? color;


  const _StatCard({required this.value, required this.label, required this.icon, this.color});


  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.cardDark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, color?.withValues(alpha: 0.8) ?? AppColors.cardDarker],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }
}


class _HistoryCard extends StatelessWidget {
  final AlertModel alert;
  final TemperatureUnit tempUnit;
  final DistanceUnit distanceUnit;


  const _HistoryCard({
    required this.alert,
    required this.tempUnit,
    required this.distanceUnit,
  });

// logic nung color nung mga notifs, if sa caution and danger + conversion ng units
  @override
  Widget build(BuildContext context) {
    final isDanger = alert.severity == AlertSeverity.danger;
    final gradient = isDanger
        ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
        : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.caution, AppColors.cautionDark]);
    final icon = alert.type == AlertType.flood ? Icons.water_drop : Icons.thermostat;
    final bool isFlood = alert.type == AlertType.flood;
    final String unit;
    double displayValue;
    if (isFlood) {
      if (distanceUnit == DistanceUnit.inches) {
        displayValue = alert.value / 2.54;
        unit = 'in';
      } else {
        displayValue = alert.value;
        unit = 'cm';
      }
    } else {
      if (tempUnit == TemperatureUnit.fahrenheit) {
        displayValue = alert.value * 9 / 5 + 32;
        unit = '°F';
      } else {
        displayValue = alert.value;
        unit = '°C';
      }
    }


    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(alert.severity.name.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(alert.message, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                      Text('${alert.type.name}: ${displayValue.toStringAsFixed(1)} $unit', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                if (alert.acknowledged)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('Seen', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${alert.timestamp.month}/${alert.timestamp.day}/${alert.timestamp.year}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                Text('${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, '0')}', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

