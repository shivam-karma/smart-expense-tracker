import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';

class ImportPdfScreen extends ConsumerStatefulWidget {
  const ImportPdfScreen({super.key});

  @override
  ConsumerState<ImportPdfScreen> createState() => _ImportPdfScreenState();
}

class _ImportPdfScreenState extends ConsumerState<ImportPdfScreen> {
  String extractedText = "";
  bool loading = false;

  List<Map<String, dynamic>> detectedExpenses = [];

  // 🏷 AUTO CATEGORY DETECTION
  String detectCategory(String text) {
    final t = text.toLowerCase();

    if (t.contains("zomato") || t.contains("swiggy") || t.contains("food")) {
      return "Food";
    } else if (t.contains("uber") ||
        t.contains("ola") ||
        t.contains("rapido")) {
      return "Travel";
    } else if (t.contains("bill") ||
        t.contains("recharge") ||
        t.contains("electric") ||
        t.contains("internet")) {
      return "Bills";
    } else if (t.contains("amazon") ||
        t.contains("flipkart") ||
        t.contains("myntra")) {
      return "Shopping";
    } else if (t.contains("transfer") ||
        t.contains("upi") ||
        t.contains("paytm") ||
        t.contains("phonepe")) {
      return "Transfer";
    } else {
      return "Other";
    }
  }

  // 🔥 BANK-STYLE EXPENSE PARSER
  List<Map<String, dynamic>> parseExpenses(String text) {
    final lines = text.split('\n');
    final List<Map<String, dynamic>> expenses = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.toUpperCase().contains("DEBIT")) {
        try {
          String amountLine = "";
          String titleLine = "";

          for (int j = i + 1; j < i + 8 && j < lines.length; j++) {
            final l = lines[j].trim();

            if (amountLine.isEmpty && RegExp(r'^[\d,]+$').hasMatch(l)) {
              amountLine = l.replaceAll(',', '');
            } else if (amountLine.isNotEmpty &&
                l.isNotEmpty &&
                !l.toUpperCase().contains("CREDIT") &&
                !l.toUpperCase().contains("DEBIT")) {
              titleLine = l;
              break;
            }
          }

          if (amountLine.isNotEmpty && titleLine.isNotEmpty) {
            final category = detectCategory(titleLine);

            expenses.add({
              "title": titleLine,
              "amount": double.parse(amountLine),
              "category": category,
            });
          }
        } catch (_) {}
      }
    }

    return expenses;
  }

  // 📥 PICK & READ PDF
  Future<void> pickAndReadPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) return;

      setState(() => loading = true);

      Uint8List bytes;

      if (kIsWeb) {
        bytes = result.files.single.bytes!;
      } else {
        final file = File(result.files.single.path!);
        bytes = await file.readAsBytes();
      }

      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText();
      document.dispose();

      final parsed = parseExpenses(text);

      setState(() {
        extractedText = text;
        detectedExpenses = parsed;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error reading PDF: $e")));
    }
  }

  // ✅ IMPORT TO APP
  void importAllExpenses() {
    for (final e in detectedExpenses) {
      final expense = Expense(
        id: "",
        title: e["title"],
        amount: e["amount"],
        category: e["category"],
        date: DateTime.now(),
      );

      ref.read(expenseProvider.notifier).addExpense(expense);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Expenses imported successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Import PDF Statement")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: pickAndReadPdf,
              icon: const Icon(Icons.upload_file),
              label: const Text("Select PDF Statement"),
            ),

            if (detectedExpenses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: importAllExpenses,
                  icon: const Icon(Icons.download_done),
                  label: const Text("Import all expenses"),
                ),
              ),

            const SizedBox(height: 20),

            loading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: detectedExpenses.isEmpty
                        ? SingleChildScrollView(
                            child: Text(
                              extractedText.isEmpty
                                  ? "No PDF selected"
                                  : extractedText,
                              style: const TextStyle(fontSize: 14),
                            ),
                          )
                        : ListView.builder(
                            itemCount: detectedExpenses.length,
                            itemBuilder: (context, index) {
                              final e = detectedExpenses[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.receipt_long_rounded,
                                  ),
                                  title: Text(e["title"]),
                                  subtitle: Text(e["category"]),
                                  trailing: Text("₹${e["amount"]}"),
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
}
