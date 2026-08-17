import 'package:flutter/material.dart';
import '../services/notification_store.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationStore.getAll();

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),

      body: notifications.isEmpty
          ? const Center(child: Text("No notifications"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];

                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(n.title),
                  subtitle: Text(n.message),
                  trailing: Text("${n.time.hour}:${n.time.minute}"),
                );
              },
            ),
    );
  }
}
