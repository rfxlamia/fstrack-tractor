import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Initialize date formatting for Indonesia locale
///
/// Call this once at app startup before using formatWorkDate
Future<void> initializeDateFormattingId() async {
  await initializeDateFormatting('id_ID', null);
}

/// Format work date to Indonesia locale
///
/// Example: DateTime(2026, 2, 3) → "3 Februari 2026"
///
/// Note: Make sure to call initializeDateFormattingId() first
String formatWorkDate(DateTime date) {
  try {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  } catch (e) {
    // Fallback if locale not initialized
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }
}

/// Fallback month names in Indonesian
String _monthName(int month) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return months[month - 1];
}
