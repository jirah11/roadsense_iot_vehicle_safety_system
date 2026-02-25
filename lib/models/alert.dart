enum AlertType {
  flood,
  temperature
}

enum AlertSeverity{
  caution,
  danger
}
 // purpose neto, pang-cacall ko siya sa mga screens gets? gets
class AlertModel {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final double value;
  final bool acknowledged;

  const AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.value,
    this.acknowledged = false,
  });

  AlertModel copyWith({
    String? id,
    AlertType? type,
    AlertSeverity? severity,
    String? message,
    DateTime? timestamp,
    double? value,
    bool? acknowledged,
  }) {
    return AlertModel(
        id: id ?? this.id,
        type: type ?? this.type,
        severity: severity ?? this.severity,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        value: value ?? this.value,
        acknowledged: acknowledged ?? this.acknowledged,
    );
  }
}