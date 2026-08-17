import 'package:firebase_database/firebase_database.dart';

class ChemicalService {
  static double parsePercentage(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final clean = value.trim().replaceAll('%', '');
      return double.tryParse(clean) ?? 0.0;
    }

    return 0.0;
  }

  final DatabaseReference acidRef = FirebaseDatabase.instance.ref(
    "chemicalTank/acid",
  );

  final DatabaseReference baseRef = FirebaseDatabase.instance.ref(
    "chemicalTank/base",
  );

  Stream<double> getAcidLevel() {
    return acidRef.onValue.map((event) {
      return parsePercentage(event.snapshot.value);
    });
  }

  Stream<double> getBaseLevel() {
    return baseRef.onValue.map((event) {
      return parsePercentage(event.snapshot.value);
    });
  }
}
