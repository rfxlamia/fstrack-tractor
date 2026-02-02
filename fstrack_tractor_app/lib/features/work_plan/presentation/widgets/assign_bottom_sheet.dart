import 'package:flutter/material.dart';

/// Bottom sheet for assigning an operator to a work plan
///
/// This is a placeholder implementation for Story 2.1.
/// Full implementation will be done in Story 2.3.
class AssignBottomSheet extends StatelessWidget {
  final String workPlanId;

  const AssignBottomSheet({
    super.key,
    required this.workPlanId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tugaskan Operator',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Rencana Kerja ID: $workPlanId',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Pilih Operator',
              hintText: 'Cari operator...',
            ),
          ),
          const SizedBox(height: 16),
          // Placeholder list of operators
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('Operator ${index + 1}'),
                  subtitle: Text('ID: OP00${index + 1}'),
                  onTap: () {
                    // Placeholder - will be implemented in Story 2.3
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ),
        ],
      ),
    );
  }

  /// Show the assign bottom sheet
  static void show(BuildContext context, {required String workPlanId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AssignBottomSheet(workPlanId: workPlanId),
    );
  }
}
