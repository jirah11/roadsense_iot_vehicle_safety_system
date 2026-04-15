// purpose neto, pang-cacall ko siya sa mga screens gets? gets
// warning feb 26, wala pang vehicle keme, dito lang muna to
//march 7 update tinatry ko gawin yehey
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

// CORRECT: danger distance is LOWER than caution distance
// sedan: caution when within 30cm, danger when within 15cm
  static const VehicleThresholds sedan = VehicleThresholds(
    floodCaution: 30,   // warn when sensor reads ≤ 30cm
    floodDanger: 15,    // danger when sensor reads ≤ 15cm (water very close)
    tempCaution: 40,
    tempDanger: 50,
  );

  static const VehicleThresholds suv = VehicleThresholds(
    floodCaution: 40,
    floodDanger: 20,
    tempCaution: 45,
    tempDanger: 55,
  );

  static const VehicleThresholds hatchback = VehicleThresholds(
    floodCaution: 28,
    floodDanger: 12,
    tempCaution: 38,
    tempDanger: 48,
  );

  static const VehicleThresholds coupe = VehicleThresholds(
    floodCaution: 25,
    floodDanger: 10,
    tempCaution: 40,
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

VehicleType vehicleTypeFromString(String? value) {
  if (value == null) return VehicleType.sedan;
  return VehicleType.values.firstWhere(
        (t) => t.name.toLowerCase() == value.toLowerCase(),
    orElse: () => VehicleType.sedan,
  );
}
