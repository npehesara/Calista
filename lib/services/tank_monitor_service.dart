import 'package:firebase_database/firebase_database.dart';
import 'chemical_service.dart';
import 'notification_store.dart';
import 'notification_service.dart';

class TankMonitorService {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("chemicalTank");

  final NotificationService notificationService = NotificationService();

  bool alertSent = false;

  void startMonitoring() {
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;

      if (data == null) return;

      final acid = ChemicalService.parsePercentage(data["acid"]);
      final base = ChemicalService.parsePercentage(data["base"]);

      // 🔥 ACID LOW ALERT
      if (acid <= 10 && !alertSent) {
        alertSent = true;

        _triggerAlert("Low Acid Tank", "Acid level is $acid%");
      }

      // 🔥 BASE LOW ALERT
      if (base <= 10 && !alertSent) {
        alertSent = true;

        _triggerAlert("Low Base Tank", "Base level is $base%");
      }

      // reset when normal
      if (acid > 10 && base > 10) {
        alertSent = false;
      }
    });
  }

  void _triggerAlert(String title, String msg) {
    // 📥 Save to inbox
    NotificationStore.add(title, msg);

    // 🔔 Local notification (foreground)
    notificationService.showNotification(title, msg);
  }
}
