import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_model.dart';

class ApiService {
  static const String baseUrl =
      "https://695f3ea57f037703a8131ea1.mockapi.io/api/v1/expenses";

  // 👉 GET all expenses
  Future<List<Expense>> fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      print("API STATUS: ${response.statusCode}");
      print("API BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Expense.fromJson(e)).toList();
      } else {
        // ❌ Don't throw, just log
        print("API ERROR: Non-200 response");
        return [];
      }
    } catch (e) {
      print("API ERROR (fetchExpenses catch): $e");
      return [];
    }
  }

  // 👉 POST new expense
  Future<void> addExpense(Expense expense) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(expense.toJson()),
      );

      print("POST STATUS: ${res.statusCode}");
      print("POST BODY: ${res.body}");
    } catch (e) {
      print("API ERROR (addExpense): $e");
    }
  }

  // 👉 DELETE expense
  Future<void> deleteExpense(String id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/$id"));
      print("DELETE STATUS: ${res.statusCode}");
    } catch (e) {
      print("API ERROR (deleteExpense): $e");
    }
  }
}
