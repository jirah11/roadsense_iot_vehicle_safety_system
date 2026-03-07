import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadsense_unang_hirit/app.dart';
import 'package:roadsense_unang_hirit/app_theme.dart';
import 'package:roadsense_unang_hirit/models/models.dart';

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

class _VehicleProfileScreenState extends State<VehicleProfileScreen> {
  late bool _isEditing;
  late String _nickname;
  late VehicleType _vehicleType;
  late int _floodCaution;
  late int _floodDanger;
  late int _tempCaution;
  late int _tempDanger;
  bool _showDropdown = false;
  final _nicknameController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
//note: march 7, di muna gagalawin. need daw simulan ko log-in, sign-up. ciao