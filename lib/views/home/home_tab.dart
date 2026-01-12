import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/expense_provider.dart';
import '../../providers/month_provider.dart';
import '../../widgets/expense_card.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    // 📅 Filter by selected month
    final monthlyExpenses = expenses
        .where((e) => e.date.month == selectedMonth)
        .toList();

    // 💰 Monthly total
    final total = monthlyExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    // 🔥 Highest expense
    final highest = monthlyExpenses.isEmpty
        ? null
        : (monthlyExpenses..sort((a, b) => b.amount.compareTo(a.amount))).first;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📅 MONTH DROPDOWN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Overview",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: selectedMonth,
                  underline: const SizedBox(),
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem(
                      value: month,
                      child: Text(_monthName(month)),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(selectedMonthProvider.notifier).state = value;
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 💎 TOTAL CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.indigo, Colors.deepPurple],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total this month",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${total.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 🔥 HIGHEST EXPENSE CARD
            if (highest != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Highest expense this month",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            highest.title,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${highest.amount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            const Text(
              "Recent expenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            // 📜 FILTERED LIST
            Expanded(
              child: monthlyExpenses.isEmpty
                  ? const Center(child: Text("No expenses this month"))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: monthlyExpenses.length,
                      itemBuilder: (context, index) {
                        final e = monthlyExpenses[index];

                        return Dismissible(
                          key: ValueKey(e.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            ref
                                .read(expenseProvider.notifier)
                                .deleteExpense(e.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Expense deleted")),
                            );
                          },
                          child: ExpenseCard(
                            title: e.title,
                            amount: e.amount,
                            date: e.category,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 🗓 Month name helper
  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}
