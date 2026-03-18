import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _nicknameController =
      TextEditingController(); //text input sa vehicle nickname

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
            'Flood Threshold',
            'Flood threshold description',
            Icons.water_drop,
            _floodCaution,
            _floodDanger,
            'cm',
            (c, d) {
              setState(() {
                _floodCaution = c;
                _floodDanger = d;
              });
            },
          ),
          _thresholdSection(
            'Temperature Threshold',
            'Temperature threshold description',
            Icons.thermostat,
            _tempCaution,
            _tempDanger,
            '°C',
            (c, d) {
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

  Widget _thresholdSection(
    String title,
    String subtitle,
    IconData icon,
    int caution,
    int danger,
    String unit,
    void Function(int c, int d) onChanged,
  ) {
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
                          'Caution:',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue: '$caution',
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                onChanged(int.tryParse(v) ?? caution, danger),
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
                          'Danger:',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue: '$danger',
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                onChanged(caution, int.tryParse(v) ?? danger),
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
                          'Caution:',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        Text(
                          '$caution$unit',
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
                          'Danger:',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        Text(
                          '$danger$unit',
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
