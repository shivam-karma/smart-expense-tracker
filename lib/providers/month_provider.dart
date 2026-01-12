import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMonthProvider = StateProvider<int>((ref) {
  final now = DateTime.now();
  return now.month; // default = current month
});
