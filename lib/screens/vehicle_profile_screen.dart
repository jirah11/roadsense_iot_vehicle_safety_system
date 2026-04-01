import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadsense_unang_hirit/app.dart';
import '../app_theme.dart';
import '../models/models.dart';

// mga pang call
class VehicleProfileScreen extends StatefulWidget {
  final VehicleType vehicleType;
  final String vehicleNickname;
  final VehicleThresholds thresholds;
  final VoidCallback onBack;
  final void Function(
    VehicleType type,
    String nickname,
    VehicleThresholds thresholds,
  )
  onSave;

  const VehicleProfileScreen({
    super.key,
    required this.vehicleType,
    required this.vehicleNickname,
    required this.thresholds,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<VehicleProfileScreen> createState() => _VehicleProfileScreenState();
}

//eto yung class na naghohold ng temporary changes if clinick edit, bago magsave yung users
class _VehicleProfileScreenState extends State<VehicleProfileScreen> {
  late bool
  _isEditing; // boolean na nagtotoggle sa UI between sa display and edit ng vehicle profile
  late String _nickname;
  late VehicleType _vehicleType;
  late int _floodCaution;
  late int _floodDanger;
  late int _tempCaution;
  late int _tempDanger;
  bool _showDropdown = false;
  final _nicknameController = TextEditingController(); //text input sa vehicle nickname
  DistanceUnit _floodDisplayUnit = DistanceUnit.centimeters;
  TemperatureUnit _tempDisplayUnit = TemperatureUnit.celsius;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _nickname = widget.vehicleNickname;
    _vehicleType = widget.vehicleType;
    _floodCaution = widget.thresholds.floodCaution;
    _floodDanger = widget.thresholds.floodDanger;
    _tempCaution = widget.thresholds.tempCaution;
    _tempDanger = widget.thresholds.tempDanger;
  }

  // pag nagclick si user ng vehicle type, naguupdate yung _vehicleType
  // finefetch niya yung default threshold nung type na yun
  void _applyType(VehicleType type) {
    setState(() {
      _vehicleType = type;
      final t = VehicleThresholds.forType(type);
      _floodCaution = t.floodCaution;
      _floodDanger = t.floodDanger;
      _tempCaution = t.tempCaution;
      _tempDanger = t.tempDanger;
      _showDropdown = false;
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(
      _vehicleType,
      _nicknameController.text
              .trim()
              .isEmpty //if wala nilagay na text sa edit, babalik lang siya sa lumang nickname
          ? _nickname
          : _nicknameController.text.trim(),
      VehicleThresholds(
        floodCaution: _floodCaution,
        floodDanger: _floodDanger,
        tempCaution: _tempCaution,
        tempDanger: _tempDanger,
      ),
    );
    setState(() => _isEditing = false);
  }

  // if hindi sinave ni user changesm magrereset lang siya, babalik yung orig values tapos mageexit in edit mode
  void _cancel() {
    _nicknameController.text = widget.vehicleNickname;
    setState(() {
      _isEditing = false;
      _nickname = widget.vehicleNickname;
      _vehicleType = widget.vehicleType;
      _floodCaution = widget.thresholds.floodCaution;
      _floodDanger = widget.thresholds.floodDanger;
      _tempCaution = widget.thresholds.tempCaution;
      _tempDanger = widget.thresholds.tempDanger;
      _showDropdown = false;
    });
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
                    'Vehicle Profile',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Configure vehicle settings',
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
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nickname,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        VehicleThresholds.typeLabel(_vehicleType),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section('Vehicle Nickname', [
            _isEditing
                ? TextField(
                    controller: _nicknameController,
                    onChanged: (v) => setState(() => _nickname = v),
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'My Vehicle',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  )
                : Text(
                    _nickname,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ]),
          _section('Vehicle Type', [
            _isEditing
                ? GestureDetector(
                    onTap: () => setState(() => _showDropdown = !_showDropdown),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            VehicleThresholds.typeLabel(_vehicleType),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  )
                : Text(
                    VehicleThresholds.typeLabel(_vehicleType),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
            if (_showDropdown)
              ...VehicleType.values.map(
                (t) => ListTile(
                  title: Text(
                    VehicleThresholds.typeLabel(t),
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  onTap: () => _applyType(t),
                ),
              ),
          ]),
          _thresholdSection(
            title: 'Flood Threshold',
            subtitle: 'Flood threshold description',
            icon: Icons.water_drop,
            caution: _floodCaution,
            danger: _floodDanger,
            isFlood: true,
            onChanged: (c, d) {
              setState(() {
                _floodCaution = c;
                _floodDanger = d;
              });
            },
          ),
          _thresholdSection(
            title: 'Temperature Threshold',
            subtitle: 'Temperature threshold description',
            icon: Icons.thermostat,
            caution: _tempCaution,
            danger: _tempDanger,
            isFlood: false,
            onChanged: (c, d) {
              setState(() {
                _tempCaution = c;
                _tempDanger = d;
              });
            },
          ),
          const SizedBox(height: 24),
          if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save, size: 20),
                    label: Text(
                      'Save Changes',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _nicknameController.text = _nickname;
                      setState(() => _isEditing = true);
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
                      'Edit Profile',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _section(String label, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
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
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  static int _cmToInches(int cm) => (cm / 2.54).round();


  static int _inchesToCm(int inches) => (inches * 2.54).round();


  static int _celsiusToFahrenheit(int c) => ((c * 9) ~/ 5 + 32);


  static int _fahrenheitToCelsius(int f) => (((f - 32) * 5) / 9).round();


  int _floodEditDisplay(int cm) =>
      _floodDisplayUnit == DistanceUnit.centimeters ? cm : _cmToInches(cm);


  int _floodStorageFromEdit(int value) =>
      _floodDisplayUnit == DistanceUnit.centimeters ? value : _inchesToCm(value);


  int _tempEditDisplay(int celsius) => _tempDisplayUnit == TemperatureUnit.celsius
      ? celsius
      : _celsiusToFahrenheit(celsius);


  int _tempStorageFromEdit(int value) =>
      _tempDisplayUnit == TemperatureUnit.celsius
          ? value
          : _fahrenheitToCelsius(value);


  String _floodValueLabel(int cm) {
    if (_floodDisplayUnit == DistanceUnit.centimeters) return '${cm}cm';
    return '${_cmToInches(cm)}in';
  }


  String _tempValueLabel(int celsius) {
    if (_tempDisplayUnit == TemperatureUnit.celsius) return '$celsius°C';
    return '${_celsiusToFahrenheit(celsius)}°F';
  }


  Widget _thresholdUnitSegment({
    required String left,
    required String right,
    required bool leftSelected,
    required VoidCallback onLeft,
    required VoidCallback onRight,
  }) {
    Widget chip(String label, bool selected, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.white60,
            ),
          ),
        ),
      );
    }


    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip(left, leftSelected, onLeft),
        const SizedBox(width: 6),
        chip(right, !leftSelected, onRight),
      ],
    );
  }


  Widget _thresholdSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required int caution,
    required int danger,
    required bool isFlood,
    required void Function(int c, int d) onChanged,
  }) {
    final cautionLabel = isFlood ? 'Flood Caution' : 'Temp Caution';
    final dangerLabel = isFlood ? 'Flood Danger' : 'Temp Danger';
    final displayCaution = isFlood ? _floodValueLabel(caution) : _tempValueLabel(caution);
    final displayDanger = isFlood ? _floodValueLabel(danger) : _tempValueLabel(danger);
    final editCaution = isFlood ? _floodEditDisplay(caution) : _tempEditDisplay(caution);
    final editDanger = isFlood ? _floodEditDisplay(danger) : _tempEditDisplay(danger);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isFlood)
                  _thresholdUnitSegment(
                    left: 'cm',
                    right: 'in',
                    leftSelected: _floodDisplayUnit == DistanceUnit.centimeters,
                    onLeft: () => setState(
                          () => _floodDisplayUnit = DistanceUnit.centimeters,
                    ),
                    onRight: () => setState(
                          () => _floodDisplayUnit = DistanceUnit.inches,
                    ),
                  )
                else
                  _thresholdUnitSegment(
                    left: '°C',
                    right: '°F',
                    leftSelected: _tempDisplayUnit == TemperatureUnit.celsius,
                    onLeft: () => setState(
                          () => _tempDisplayUnit = TemperatureUnit.celsius,
                    ),
                    onRight: () => setState(
                          () => _tempDisplayUnit = TemperatureUnit.fahrenheit,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundStart.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_isEditing) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$cautionLabel:',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        SizedBox(
                          width: 88,
                          child: TextFormField(
                            key: ValueKey(
                              'c_${isFlood}_${_floodDisplayUnit}_${_tempDisplayUnit}_$caution',
                            ),
                            initialValue: '$editCaution',
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final parsed =
                                  int.tryParse(v) ?? (isFlood ? _floodEditDisplay(caution) : _tempEditDisplay(caution));
                              final stored = isFlood
                                  ? _floodStorageFromEdit(parsed)
                                  : _tempStorageFromEdit(parsed);
                              onChanged(stored, danger);
                            },
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$dangerLabel:',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        SizedBox(
                          width: 88,
                          child: TextFormField(
                            key: ValueKey(
                              'd_${isFlood}_${_floodDisplayUnit}_${_tempDisplayUnit}_$danger',
                            ),
                            initialValue: '$editDanger',
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final parsed =
                                  int.tryParse(v) ?? (isFlood ? _floodEditDisplay(danger) : _tempEditDisplay(danger));
                              final stored = isFlood
                                  ? _floodStorageFromEdit(parsed)
                                  : _tempStorageFromEdit(parsed);
                              onChanged(caution, stored);
                            },
                            style: GoogleFonts.inter(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$cautionLabel:',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        Text(
                          displayCaution,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$dangerLabel:',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        Text(
                          displayDanger,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
