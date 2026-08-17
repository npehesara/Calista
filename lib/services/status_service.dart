import 'package:firebase_database/firebase_database.dart';

class StatusService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("status/online");

  Stream<bool> getStatus() {
    return ref.onValue.map((event) {
      return event.snapshot.value == true;
    });
  }

  Future<void> setOnline(bool value) async {
    await ref.set(value);
  }
}
