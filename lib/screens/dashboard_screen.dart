import 'package:flutter/material.dart';
import '../services/ph_service.dart';
import '../services/chemical_service.dart';
import '../services/schedule_service.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import '../widgets/notification_banner.dart';
import 'notification_screen.dart';
import '../services/notification_store.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final phService = PhService();
  final chemicalService = ChemicalService();
  final scheduleService = ScheduleService();

  String? alertTitle;
  String? alertMessage;

  bool phAlertSent = false;

  void showAlert(String title, String message) {
    setState(() {
      alertTitle = title;
      alertMessage = message;
    });

    // ✅ SAVE TO NOTIFICATION INBOX
    NotificationStore.add(title, message);
  }

  void clearAlert() {
    setState(() {
      alertTitle = null;
      alertMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF306D29),
        elevation: 0,
        title: const Text(
          "Calista",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            if (alertTitle != null)
              NotificationBanner(
                title: alertTitle!,
                message: alertMessage!,
                onClose: clearAlert,
              ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE7E1B1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good day",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF306D29),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Your system is ready",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D530E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Color(0xFF306D29),
                    child: Icon(Icons.track_changes, color: Color(0xFFFBF5DD)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            StreamBuilder<double>(
              stream: phService.getPhStream(),
              builder: (context, snapshot) {
                final ph = snapshot.data ?? 0.0;
                String status = "Normal";
                if (ph < 7) status = "Acidic";
                if (ph > 7.8) status = "Alkaline";

                if (ph > 8.0 && !phAlertSent) {
                  phAlertSent = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showAlert("High pH Warning", "Chemical adjustment needed!");
                  });
                }

                if (ph <= 8.0) {
                  phAlertSent = false;
                }

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "pH Value",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF306D29),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7E1B1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0D530E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ph.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D530E),
                        ),
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: (ph.clamp(0.0, 14.0) / 14.0),
                        color: const Color(0xFF306D29),
                        backgroundColor: const Color(0xFFF1E8C0),
                        minHeight: 8,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<double>(
                    stream: chemicalService.getAcidLevel(),
                    builder: (context, snapshot) {
                      final acid = snapshot.data ?? 0.0;
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.science, color: Color(0xFF306D29)),
                            const SizedBox(height: 12),
                            const Text(
                              "Acid Tank",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${acid.toStringAsFixed(2)}%",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF306D29),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<double>(
                    stream: chemicalService.getBaseLevel(),
                    builder: (context, snapshot) {
                      final base = snapshot.data ?? 0.0;
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.science, color: Color(0xFF306D29)),
                            const SizedBox(height: 12),
                            const Text(
                              "Base Tank",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${base.toStringAsFixed(2)}%",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF306D29),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: scheduleService.getSchedule(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.snapshot.value == null) {
                  return const SizedBox();
                }

                final data = Map<dynamic, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );

                bool enabled = data["enabled"] ?? false;
                String time = data["time"] ?? "20:00";

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Automatic Control",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D530E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Enable Schedule"),
                        value: enabled,
                        onChanged: (value) {
                          scheduleService.updateStatus(value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Scheduled Time",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF306D29),
                            ),
                          ),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D530E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF306D29),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(Icons.schedule, size: 20),
                          label: const Text(
                            "Update Schedule Time",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () async {
                            final selected = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );

                            if (selected != null) {
                              final formatted =
                                  "${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}";
                              await scheduleService.updateTime(formatted);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
