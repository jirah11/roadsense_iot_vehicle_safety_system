import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';


class HelpInfoScreen extends StatefulWidget {
  final VoidCallback onBack;


  const HelpInfoScreen({super.key, required this.onBack});

//call
  @override
  State<HelpInfoScreen> createState() => _HelpInfoScreenState();
}

//call
class _HelpInfoScreenState extends State<HelpInfoScreen> {
  String? _expanded;


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton( //back to home
                onPressed: widget.onBack,
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
                    'Help & Info',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Guide & safety tips',
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
            width: double.infinity, //wow, ngayon ko lang narealize na ginagawa niyang expandable mga widget, wow
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF547792)],
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
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'About RoadSense',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'RoadSense is a Vehicle Safety Monitoring System that uses IoT sensors to detect flood levels and temperature hazards in real-time, keeping you safe on the road.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          //contents na nakalagay sa expandables
          _expansion('how-it-works', 'How It Works', Icons.menu_book, [
            '1. IoT sensors in your vehicle continuously monitor flood levels and temperature',
            '2. Data is transmitted to the app in real-time via WiFi connection',
            '3. System compares readings against your vehicle\'s safety thresholds',
            '4. Alerts are triggered when caution or danger levels are detected',
            '5. You receive instant notifications to take appropriate action',
          ]),
          _expansion('quick-start', 'Quick Start Guide', Icons.shield, [
            '1. Install IoT Module: Mount the RoadSense module in your vehicle and connect to power supply.',
            '2. Configure WiFi: Connect the module to your Wi-Fi network through the Settings page.',
            '3. Set Vehicle Profile: Select your vehicle type to optimize safety thresholds.',
            '4. Monitor & Drive Safely: Check your dashboard before and during trips for real-time safety status.',
          ]),
          _expansion(
            'thresholds',
            'Safety Thresholds Explained',
            Icons.info_outline,
            [
              'Flood Levels: Measured in centimeters from ground level. Higher readings indicate deeper water that may damage your vehicle or make it unsafe to drive.',
              'Temperature: Engine and ambient temperature monitoring. High temperatures can lead to overheating and engine damage.',
            ],
          ),
          _expansion(
            'safety-status',
            'Understanding Alerts',
            Icons.warning_amber_rounded,
            [
              'SAFE – All readings are within normal range. Continue driving safely.',
              'CAUTION – Readings approaching warning thresholds. Drive carefully and monitor conditions.',
              'DANGER – Critical levels detected. Take immediate action to ensure safety.',
            ],
          ),
          _expansion('flood-safety', 'Flood Safety Tips', Icons.water_drop, [
            'Never drive through flooded areas if water level exceeds your vehicle\'s threshold',
            'Turn around and find an alternate route when caution alerts appear',
            'Moving water is more dangerous than it appears - just 6 inches can sweep away a vehicle',
            'If your vehicle stalls in water, abandon it immediately and move to higher ground',
            'Watch for debris and hidden hazards in floodwater',
          ]),
          _expansion('temp-safety', 'Temperature Safety Tips', Icons.thermostat, [
            'Pull over safely if engine temperature reaches danger levels',
            'Turn off air conditioning and turn on heater to help cool the engine',
            'Never remove radiator cap when engine is hot',
            'Check coolant levels regularly and before long trips',
            'Schedule regular maintenance to prevent overheating issues',
          ]),
          //need more help box, nakalagay mga contact details
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF547792)],
              ),
              borderRadius: BorderRadius.circular(24),
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
                Text(
                  'Need More Help?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.phone, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Technical Support',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '+63 912 345 6789',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.email, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Support',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'roadsense@example.com',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// eto yung container or box nung nageexpand if nagclick ka ng topic sa help info.
// depende yung container sa content kung gaano siya kahaba tas kalaki
  Widget _expansion(
      String key,
      String title,
      IconData icon,
      List<String> items,
      ) {
    final isExpanded = _expanded == key;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = isExpanded ? null : key),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map(
                      (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      e,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

