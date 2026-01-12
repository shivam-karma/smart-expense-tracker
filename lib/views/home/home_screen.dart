import 'package:flutter/material.dart';

import '../add_expense/add_expense_screen.dart';
import '../stats/stats_screen.dart';
import '../import/import_pdf_screen.dart';
import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = const [HomeTab(), AddExpenseScreen(), StatsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Expense Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: "Import PDF Statement",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImportPdfScreen()),
              );
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.add), label: "Add"),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: "Stats"),
        ],
      ),
    );
  }
}
