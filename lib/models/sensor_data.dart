// purpose neto, pang-cacall ko siya sa mga screens gets? gets
class SensorData {
  final double floodLevel;
  final double temperature;
  final DateTime timestamp;

  const SensorData({
    required this.floodLevel,
    required this.temperature,
    required this.timestamp,
  });

  SensorData copyWith({
    double? floodLevel,
    double? temperature,
    DateTime? timestamp,
  }) {
    return SensorData(
        floodLevel: floodLevel ?? this.floodLevel,
        temperature: temperature ?? this.temperature,
        timestamp: timestamp ?? this.timestamp,
    );
  }

}