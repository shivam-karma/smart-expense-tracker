import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/expense_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  Map<String, double> groupByCategory(List expenses) {
    final Map<String, double> data = {};
    for (var e in expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }
    return data;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);

    if (expenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              "No transactions yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final grouped = groupByCategory(expenses);
    final total = grouped.values.fold<double>(0, (a, b) => a + b);

    final colors = [
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.green,
      Colors.blueGrey,
      Colors.redAccent,
    ];

    final entries = grouped.entries.toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overall Analytics",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 🔥 CHART + LEGEND
          Row(
            children: [
              // PIE
              Expanded(
                flex: 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 230,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 70,
                          sectionsSpace: 3,
                          sections: List.generate(entries.length, (i) {
                            final item = entries[i];
                            return PieChartSectionData(
                              value: item.value,
                              color: colors[i % colors.length],
                              radius: 26,
                              showTitle: false,
                            );
                          }),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "All time spent",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${total.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // LEGEND
              Expanded(
                flex: 4,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final item = entries[i];
                    final percent = (item.value / total) * 100;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text("${percent.toStringAsFixed(1)}%"),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "All Transactions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          // 📋 TRANSACTIONS LIST
          Expanded(
            child: ListView(
              children: expenses.map((e) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                      color: Colors.indigo,
                    ),
                    title: Text(e.title),
                    subtitle: Text(e.category),
                    trailing: Text(
                      "₹${e.amount.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
