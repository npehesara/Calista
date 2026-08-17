import 'package:firebase_database/firebase_database.dart';

class ScheduleService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("schedule");

  /// 🔥 Initialize default schedule (important for ESP)
  Future<void> initDefault() async {
    await ref.update({"time": "13:00", "enabled": false});
  }

  /// ⏰ Update schedule time
  Future<void> updateTime(String time) async {
    await ref.update({"time": time});
  }

  /// 🔘 Enable / Disable schedule
  Future<void> updateStatus(bool enabled) async {
    await ref.update({"enabled": enabled});
  }

  /// 📡 Real-time listener (Flutter UI)
  Stream<DatabaseEvent> getSchedule() {
    return ref.onValue;
  }

  /// 📥 Get current schedule once (ESP friendly)
  Future<Map<String, dynamic>> getOnce() async {
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      return {"time": "13:00", "enabled": false};
    }

    return Map<String, dynamic>.from(snapshot.value as Map);
  }
}
