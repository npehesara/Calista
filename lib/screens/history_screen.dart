import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref("history");

    return Scaffold(
      backgroundColor: const Color(0xFFFBF5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF306D29),
        elevation: 0,
        title: const Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // HEADER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E1B1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "History Log",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D530E),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Review past pH measurements.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF306D29),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // DATA LIST
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: ref.onValue,
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final value = snapshot.data?.snapshot.value;

                    if (value == null) {
                      return const Center(
                        child: Text(
                          "No history yet",
                          style: TextStyle(color: Color(0xFF306D29)),
                        ),
                      );
                    }

                    // SAFE CAST (important fix)
                    Map<dynamic, dynamic> dataMap = {};

                    if (value is Map) {
                      dataMap = Map<dynamic, dynamic>.from(value);
                    } else {
                      return const Center(
                        child: Text(
                          "Invalid history format",
                          style: TextStyle(color: Color(0xFF306D29)),
                        ),
                      );
                    }

                    final entries = dataMap.entries.toList().reversed.toList();

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),

                      itemBuilder: (context, index) {
                        final entry = entries[index];

                        final item = Map<dynamic, dynamic>.from(entry.value);

                        final ph = item['ph']?.toString() ?? "N/A";
                        final time = item['time']?.toString() ?? "N/A";
                        final date = item['date']?.toString() ?? "";

                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE7E1B1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.water_drop,
                                  color: Color(0xFF306D29),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "pH: $ph",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0D530E),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "Time: $time",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF306D29),
                                      ),
                                    ),

                                    if (date.isNotEmpty)
                                      Text(
                                        "Date: $date",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}