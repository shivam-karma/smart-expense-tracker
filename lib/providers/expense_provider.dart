import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../services/api_service.dart';

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((
  ref,
) {
  return ExpenseNotifier();
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    loadExpenses();
  }

  final ApiService _api = ApiService();

  Future<void> loadExpenses() async {
    final expenses = await _api.fetchExpenses();
    state = expenses;
  }

  Future<void> addExpense(Expense expense) async {
    await _api.addExpense(expense);
    loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _api.deleteExpense(id);
    loadExpenses();
  }
}
