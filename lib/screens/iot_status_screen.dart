import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roadsense_unang_hirit/app_theme.dart';
import 'package:roadsense_unang_hirit/models/sensor_data.dart';

abstract class IotStatusScreen extends StatelessWidget {
  final bool iotConnected;
  final SensorData? sensorData;
  final VoidCallback onBack;

  const IotStatusScreen({
    super.key,
    required this.iotConnected,
    this.sensorData,
    required this.onBack
  });
}
