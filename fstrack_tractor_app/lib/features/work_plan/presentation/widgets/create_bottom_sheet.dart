import 'package:flutter/material.dart';

/// Bottom sheet for creating a new work plan
///
/// This is a placeholder implementation for Story 2.1.
/// Full implementation will be done in Story 2.2.
class CreateBottomSheet extends StatelessWidget {
  const CreateBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buat Rencana Kerja Baru',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Tanggal Kerja',
              hintText: 'Pilih tanggal',
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Pola Kerja',
              hintText: 'Masukkan pola kerja',
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Shift',
              hintText: 'Pilih shift',
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Lokasi',
              hintText: 'Pilih lokasi',
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Unit',
              hintText: 'Pilih unit',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Placeholder - will be implemented in Story 2.2
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }

  /// Show the create bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateBottomSheet(),
    );
  }
}
