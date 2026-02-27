import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../app_theme.dart';

//mga pangcall sa settings screen
class SettingsScreen extends StatefulWidget {
  final TemperatureUnit tempUnit;
  final DistanceUnit distanceUnit;
  final VoidCallback onBack;
  final ValueChanged<TemperatureUnit> onTempUnitChanged;
  final ValueChanged<DistanceUnit> onDistanceUnitChanged;

  const SettingsScreen({
    super.key,
    required this.tempUnit,
    required this.distanceUnit,
    required this.onBack,
    required this.onTempUnitChanged,
    required this.onDistanceUnitChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showWifiConfig = false;
  final TextEditingController _ssidController =
  TextEditingController(text: 'RoadSense-IoT');
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.accent, size: 26),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Configure app preferences',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.accent),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // display units
          Text(
            'Display Units',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.cardDark, AppColors.cardDarker],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.thermostat, color: Colors.white70, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Temperature',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _unitButton(
                        label: 'Celsius (°C)',
                        isActive: widget.tempUnit == TemperatureUnit.celsius,
                        onTap: () => widget.onTempUnitChanged(TemperatureUnit.celsius),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _unitButton(
                        label: 'Fahrenheit (°F)',
                        isActive: widget.tempUnit == TemperatureUnit.fahrenheit,
                        onTap: () => widget.onTempUnitChanged(TemperatureUnit.fahrenheit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(Icons.straighten, color: Colors.white70, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Distance',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _unitButton(
                        label: 'Centimeters',
                        isActive: widget.distanceUnit == DistanceUnit.centimeters,
                        onTap: () => widget.onDistanceUnitChanged(DistanceUnit.centimeters),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _unitButton(
                        label: 'Inches',
                        isActive: widget.distanceUnit == DistanceUnit.inches,
                        onTap: () => widget.onDistanceUnitChanged(DistanceUnit.inches),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // iot device
          Text(
            'IoT Device',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.cardDark, AppColors.cardDarker],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                // wifi config
                GestureDetector(
                  onTap: () => setState(() => _showWifiConfig = !_showWifiConfig),
                  child: Row(
                    children: [
                      Icon(Icons.wifi, color: Colors.white70, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WiFi Configuration',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Configure device connection',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _showWifiConfig
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.white38,
                      ),
                    ],
                  ),
                ),

                // wifi config if clinick
                if (_showWifiConfig) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDarker,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Network SSID',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _ssidController,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'WiFi Network Name',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Password',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: GoogleFonts.inter(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'WiFi Password',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            suffixIcon: const Icon(
                              Icons.visibility_off,
                              color: Colors.white54,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('WiFi settings saved')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Save WiFi Settings',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // unit button, pag active may fill yung square, if inde stroke lang
  Widget _unitButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    if (isActive) {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 12)),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12)),
    );
  }
}