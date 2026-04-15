import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../app_theme.dart';
import '../models/sensor_data.dart';
import '../backend/service/iot.dart';

class IoTStatusScreen extends StatefulWidget {
  final bool iotConnected;
  final bool iotPaired;
  final SensorData? sensorData;
  final TemperatureUnit tempUnit;
  final DistanceUnit distanceUnit;
  final String? connectedDeviceId; // nullable — null means no device linked
  final void Function({required String deviceId, required String password})
  onConnectDevice;
  final VoidCallback onDisconnect;
  final VoidCallback onBack;

  const IoTStatusScreen({
    super.key,
    required this.iotConnected,
    required this.iotPaired,
    this.sensorData,
    required this.tempUnit,
    required this.distanceUnit,
    this.connectedDeviceId,
    required this.onConnectDevice,
    required this.onDisconnect,
    required this.onBack,
  });

  @override
  State<IoTStatusScreen> createState() => _IoTStatusScreenState();
}

class _IoTStatusScreenState extends State<IoTStatusScreen> {
  bool _didPrompt = false;

  late final TextEditingController _deviceIdCtrl;
  final TextEditingController _passwordCtrl = TextEditingController();

  late final IoTService _iotService;

  String _serial = '—';
  String _model = '—';
  String _firmware = '—';
  int _batteryLevel = 0;
  DateTime? _lastConnected;
  bool _loadingDeviceInfo = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with already connected device id if available
    _deviceIdCtrl = TextEditingController(
        text: widget.connectedDeviceId ?? '');
    _iotService = IoTService();
    if (widget.iotPaired) {
      _fetchDeviceInfo();
    }
  }

  @override
  void didUpdateWidget(IoTStatusScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.iotPaired && widget.iotPaired) {
      _fetchDeviceInfo();
    }
    // Update device id field if it changes
    if (oldWidget.connectedDeviceId != widget.connectedDeviceId &&
        widget.connectedDeviceId != null) {
      _deviceIdCtrl.text = widget.connectedDeviceId!;
    }
  }

  @override
  void dispose() {
    _deviceIdCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchDeviceInfo() async {
    if (!mounted) return;
    setState(() => _loadingDeviceInfo = true);

    try {
      final deviceId = widget.connectedDeviceId ??
          (_deviceIdCtrl.text.trim().isNotEmpty
              ? _deviceIdCtrl.text.trim()
              : null);

      if (deviceId == null) return;

      final data = await _iotService.getDevice(deviceId);
      if (data == null || !mounted) return;

      final info = data['info'] != null
          ? Map<String, dynamic>.from(data['info'] as Map)
          : <String, dynamic>{};
      final status = data['status'] != null
          ? Map<String, dynamic>.from(data['status'] as Map)
          : <String, dynamic>{};

      setState(() {
        _serial = info['serial'] as String? ?? '—';
        _model = info['model'] as String? ?? '—';
        _firmware = info['firmware'] as String? ?? '—';
        _batteryLevel = (status['battery_level'] ?? 0) is int
            ? status['battery_level'] as int
            : (status['battery_level'] as num?)?.toInt() ?? 0;
        final rawTs = status['last_connected'];
        if (rawTs != null) {
          _lastConnected = rawTs is int
              ? DateTime.fromMillisecondsSinceEpoch(rawTs)
              : null;
        }
      });
    } catch (e) {
      debugPrint('❌ [IoTStatusScreen] _fetchDeviceInfo error: $e');
    } finally {
      if (mounted) setState(() => _loadingDeviceInfo = false);
    }
  }

  String _formatLastSync() {
    if (_lastConnected == null) return '—';
    final diff = DateTime.now().difference(_lastConnected!);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _formatFloodReading() {
    if (widget.sensorData == null) return 'N/A';
    final useInches = widget.distanceUnit == DistanceUnit.inches;
    final value = useInches
        ? widget.sensorData!.floodLevel / 2.54
        : widget.sensorData!.floodLevel;
    final unit = useInches ? 'in' : 'cm';
    return '${value.toStringAsFixed(1)} $unit';
  }

  String _formatTempReading() {
    if (widget.sensorData == null) return 'N/A';
    final useFahrenheit = widget.tempUnit == TemperatureUnit.fahrenheit;
    final value = useFahrenheit
        ? widget.sensorData!.temperature * 9 / 5 + 32
        : widget.sensorData!.temperature;
    final unit = useFahrenheit ? '°F' : '°C';
    return '${value.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    // Only auto-prompt if no device is linked at all
    if (!_didPrompt && !widget.iotPaired && widget.connectedDeviceId == null) {
      _didPrompt = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openConnectDeviceModal();
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.accent, size: 26),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('IoT Status',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('Device & Connection',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.accent)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // CONNECT PROMPT (no device linked)
          if (!widget.iotPaired) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.cardDark, AppColors.cardDarker],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4))
                ],
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.wifi,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Connect your device',
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text(
                              'Connect your RoadSense IoT to view status, battery, and sensors.',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openConnectDeviceModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Connect Device',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // CONNECTION STATUS CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.iotConnected
                    ? [AppColors.emerald, AppColors.emeraldDark]
                    : [AppColors.rose, AppColors.roseDark],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                Icon(widget.iotConnected ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.iotConnected
                              ? 'Connected'
                              : 'Disconnected',
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(
                          widget.iotConnected
                              ? 'Device is online'
                              : 'Device is offline',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.iotConnected
                        ? Colors.white
                        : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // PAIRED CONTENT
          if (widget.iotPaired) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openDisconnectConfirm,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.rose,
                  side: const BorderSide(color: AppColors.rose),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Disconnect device',
                    style:
                    GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openConnectDeviceModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Configure WiFi Connection',
                    style:
                    GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),

            _loadingDeviceInfo
                ? _loadingPlaceholder()
                : _progressCard(
              'Battery Level',
              'Device power status',
              _batteryLevel <= 20
                  ? Icons.battery_alert
                  : Icons.battery_std,
              _batteryLevel,
              _batteryLevel >= 60
                  ? AppColors.emerald
                  : (_batteryLevel >= 30
                  ? AppColors.caution
                  : AppColors.rose),
              _batteryLevel >= 60
                  ? 'Good'
                  : (_batteryLevel >= 30 ? 'Low' : 'Critical'),
            ),
            const SizedBox(height: 24),

            _loadingDeviceInfo
                ? _loadingPlaceholder()
                : _infoCard(
              'Device Information',
              'Hardware & software details',
              Icons.memory,
              [
                _row('Device ID',
                    widget.connectedDeviceId ?? _deviceIdCtrl.text.trim(),
                    Icons.tag),
                _row('Device Model', _model, Icons.memory),
                _row('Serial Number', _serial, Icons.tag),
                _row('Firmware Version', _firmware,
                    Icons.verified_user),
                _row('Last Sync', _formatLastSync(), Icons.refresh),
              ],
            ),
            const SizedBox(height: 24),

            Text('Sensor Status',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
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
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.cardDark, AppColors.cardDarker],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Connect your IoT device to view battery health, device information, and sensor status.',
                style: GoogleFonts.inter(
                    color: Colors.white70, height: 1.35),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _loadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.cardDark, AppColors.cardDarker]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
            color: AppColors.accent, strokeWidth: 2),
      ),
    );
  }

  Future<void> _openDisconnectConfirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B3E54), Color(0xFF213448)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white10),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black54,
                    blurRadius: 30,
                    offset: Offset(0, 18))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Disconnect device?',
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, false),
                      icon: const Icon(Icons.close,
                          color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your IoT device will be disconnected and unlinked from your account. You can reconnect anytime.',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text('Cancel',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rose,
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Disconnect',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true && mounted) {
      widget.onDisconnect();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('IoT device disconnected and unlinked')));
    }
  }

  Future<void> _openConnectDeviceModal() async {
    var obscurePassword = true;
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2B3E54), Color(0xFF213448)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black54,
                        blurRadius: 30,
                        offset: Offset(0, 18))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Connect Device',
                              style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close,
                              color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Device ID',
                        style:
                        GoogleFonts.inter(color: Colors.white70)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _deviceIdCtrl,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: 'e.g. RSD1',
                        hintStyle:
                        GoogleFonts.inter(color: Colors.white38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.accent, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Password',
                        style:
                        GoogleFonts.inter(color: Colors.white70)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: obscurePassword,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: 'Enter device password',
                        hintStyle:
                        GoogleFonts.inter(color: Colors.white38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.accent, width: 2),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setModalState(() =>
                          obscurePassword = !obscurePassword),
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text('Cancel',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final deviceId =
                              _deviceIdCtrl.text.trim();
                              final password = _passwordCtrl.text;
                              if (deviceId.isEmpty) return;
                              widget.onConnectDevice(
                                deviceId: deviceId,
                                password: password,
                              );
                              Navigator.pop(dialogContext);
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) {
                                if (!mounted) return;
                                _fetchDeviceInfo();
                                messenger.showSnackBar(const SnackBar(
                                    content: Text('Connecting...')));
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16)),
                            ),
                            child: Text('Connect',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _progressCard(String title, String subtitle, IconData icon,
      int value, Color color, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardDark, AppColors.cardDarker],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))
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
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white60)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient:
                  LinearGradient(colors: [color, color.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level',
                  style: GoogleFonts.inter(color: Colors.white70)),
              Text('$value%',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String subtitle, IconData icon,
      List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardDark, AppColors.cardDarker],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))
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
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.white60)),
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
          Text(label,
              style:
              GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _sensorTile(
      String title, String subtitle, IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardDarker, Color(0xFF2F3D54)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))
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
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white60)),
                  ],
                ),
              ),
              widget.iotConnected
                  ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Active',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              )
                  : Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Offline',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Reading:',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white70)),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}