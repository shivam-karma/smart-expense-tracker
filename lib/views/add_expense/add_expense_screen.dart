import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    String category = "Food";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Expense",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Food", child: Text("Food")),
                        DropdownMenuItem(
                          value: "Travel",
                          child: Text("Travel"),
                        ),
                        DropdownMenuItem(value: "Bills", child: Text("Bills")),
                        DropdownMenuItem(
                          value: "Office",
                          child: Text("Office"),
                        ),
                      ],
                      onChanged: (value) => category = value!,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Add Expense"),
                        onPressed: () {
                          if (titleController.text.isEmpty ||
                              amountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all fields"),
                              ),
                            );
                            return;
                          }

                          final expense = Expense(
                            id: "",
                            title: titleController.text,
                            amount: double.tryParse(amountController.text) ?? 0,
                            category: category,
                            date: DateTime.now(),
                          );

                          ref
                              .read(expenseProvider.notifier)
                              .addExpense(expense);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Expense Added")),
                          );

                          titleController.clear();
                          amountController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
