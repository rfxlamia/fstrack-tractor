import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/work_plan_bloc.dart';
import '../bloc/work_plan_event.dart';
import '../bloc/work_plan_state.dart';

/// Bottom sheet for creating a new work plan
///
/// Features:
/// - Form validation for all fields
/// - Date picker with Indonesia locale
/// - Dropdown selections for pattern, shift, location, unit
/// - BLoC integration for state management
/// - Loading state handling
class CreateBottomSheet extends StatefulWidget {
  const CreateBottomSheet({super.key});

  /// Show the create bottom sheet with proper height constraint
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (modalContext) => BlocProvider.value(
        value: context.read<WorkPlanBloc>(),
        child: const CreateBottomSheet(),
      ),
    );
  }

  @override
  State<CreateBottomSheet> createState() => _CreateBottomSheetState();
}

class _CreateBottomSheetState extends State<CreateBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  // Form state
  DateTime _selectedDate = DateTime.now();
  String? _selectedPattern;
  String? _selectedShift;
  String? _selectedLocation;
  String? _selectedUnit;

  // Dropdown options (MVP: hardcoded)
  static const List<String> _patternOptions = ['Rotasi', 'Non-Rotasi'];
  static const List<String> _shiftOptions = ['Pagi', 'Sore', 'Malam'];
  static const List<String> _locationOptions = ['AFD01', 'AFD02', 'AFD03'];
  static const List<String> _unitOptions = ['TR01', 'TR02', 'TR03'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocConsumer<WorkPlanBloc, WorkPlanState>(
          listener: (context, state) {
            if (state is WorkPlanCreated) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rencana kerja berhasil dibuat!'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is WorkPlanError) {
              // Enhanced error handling for MVP hardcoded values mismatch
              String errorMessage = state.message;
              if (state.message.contains('400') ||
                  state.message.contains('422') ||
                  state.message.contains('validation')) {
                errorMessage =
                    'Gagal membuat rencana kerja. Periksa kembali data yang diisi.';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is WorkPlanLoading;
            return _buildForm(isLoading);
          },
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDateField(isLoading),
            const SizedBox(height: 16),
            _buildPatternDropdown(isLoading),
            const SizedBox(height: 16),
            _buildShiftDropdown(isLoading),
            const SizedBox(height: 16),
            _buildLocationDropdown(isLoading),
            const SizedBox(height: 16),
            _buildUnitDropdown(isLoading),
            const SizedBox(height: 24),
            _buildButtons(isLoading),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Buat Rencana Kerja Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDateField(bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal Kerja',
          border: const OutlineInputBorder(),
          enabled: !isLoading,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          _formatDate(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPatternDropdown(bool isLoading) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedPattern,
      decoration: InputDecoration(
        labelText: 'Pola Kerja',
        border: const OutlineInputBorder(),
        enabled: !isLoading,
      ),
      items: _patternOptions
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: isLoading
          ? null
          : (value) => setState(() => _selectedPattern = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field ini wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildShiftDropdown(bool isLoading) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedShift,
      decoration: InputDecoration(
        labelText: 'Shift',
        border: const OutlineInputBorder(),
        enabled: !isLoading,
      ),
      items: _shiftOptions
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: isLoading
          ? null
          : (value) => setState(() => _selectedShift = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field ini wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildLocationDropdown(bool isLoading) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLocation,
      decoration: InputDecoration(
        labelText: 'Lokasi',
        border: const OutlineInputBorder(),
        enabled: !isLoading,
      ),
      items: _locationOptions
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: isLoading
          ? null
          : (value) => setState(() => _selectedLocation = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field ini wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildUnitDropdown(bool isLoading) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedUnit,
      decoration: InputDecoration(
        labelText: 'Unit',
        border: const OutlineInputBorder(),
        enabled: !isLoading,
      ),
      items: _unitOptions
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: isLoading
          ? null
          : (value) => setState(() => _selectedUnit = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field ini wajib diisi';
        }
        return null;
      },
    );
  }

  Widget _buildButtons(bool isLoading) {
    return Column(
      children: [
        // Simpan button (primary - orange)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isLoading ? null : _onSubmit,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Batal button (outline)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  void _onSubmit() {
    // 1. Validate form
    if (!_formKey.currentState!.validate()) return;

    // 2. Dispatch to BLoC
    context.read<WorkPlanBloc>().add(
          CreateWorkPlanRequested(
            workDate: _selectedDate,
            pattern: _selectedPattern!,
            shift: _selectedShift!,
            locationId: _selectedLocation!,
            unitId: _selectedUnit!,
          ),
        );
  }
}
