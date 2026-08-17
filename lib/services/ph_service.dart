import 'package:firebase_database/firebase_database.dart';

class PhService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref(
    "phData/currentPH",
  );

  Stream<double> getPhStream() {
    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      return double.tryParse(value.toString()) ?? 0.0;
    });
  }
}
