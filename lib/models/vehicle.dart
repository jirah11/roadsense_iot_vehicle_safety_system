// purpose neto, pang-cacall ko siya sa mga screens gets? gets
// warning feb 26, wala pang vehicle keme, dito lang muna to
enum VehicleType {
  sedan,
  suv,
  hatchback,
  coupe
}

class VehicleThresholds {
  final int floodCaution;
  final int floodDanger;
  final int tempCaution;
  final int tempDanger;

  const VehicleThresholds({
    required this.floodCaution,
    required this.floodDanger,
    required this.tempCaution,
    required this.tempDanger,
  });

  static const VehicleThresholds sedan = VehicleThresholds(
      floodCaution: 20,
      floodDanger: 35,
      tempCaution: 40,
      tempDanger: 50,
  );

  static const VehicleThresholds suv = VehicleThresholds(
      floodCaution: 30,
      floodDanger: 50,
      tempCaution: 45,
      tempDanger: 55,
  );

  static const VehicleThresholds hatchback = VehicleThresholds(
      floodCaution: 18,
      floodDanger: 30,
      tempCaution: 38,
      tempDanger: 48,
  );

  static const VehicleThresholds coupe = VehicleThresholds(
      floodCaution: 15,
      floodDanger: 28,
      tempCaution: 48,
      tempDanger: 50,
  );

  static VehicleThresholds forType(VehicleType type) {
    switch (type) {
      case VehicleType.sedan:
        return sedan;
      case VehicleType.suv:
        return suv;
      case VehicleType.hatchback:
        return hatchback;
      case VehicleType.coupe:
        return coupe;
    }
  }

  static String typeLabel(VehicleType type) {
    switch (type) {
      case VehicleType.sedan:
        return 'Sedan';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.hatchback:
        return 'Hatchback';
      case VehicleType.coupe:
        return 'Coupe';
    }
  }
}