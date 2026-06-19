import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/maintenance_record.dart';
import '../providers/maintenance_provider.dart';

class AddMaintenanceScreen extends ConsumerStatefulWidget {
  const AddMaintenanceScreen({
    super.key,
    required this.vehicleId,
    this.existingRecord,
  });

  final String vehicleId;
  final MaintenanceRecord? existingRecord;

  @override
  ConsumerState<AddMaintenanceScreen> createState() =>
      _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends ConsumerState<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _mileageCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _nextMileageCtrl;
  late final TextEditingController _workshopCtrl;

  MaintenanceType _selectedType = MaintenanceType.oilChange;
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextServiceDate;

  bool get _isEditing => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    final record = widget.existingRecord;

    _titleCtrl = TextEditingController(
      text: record?.title ?? MaintenanceType.oilChange.displayName,
    );
    _mileageCtrl = TextEditingController(
      text: record?.mileageAtService.toStringAsFixed(0) ?? '',
    );
    _costCtrl = TextEditingController(
      text: record?.cost?.toStringAsFixed(0) ?? '',
    );
    _notesCtrl = TextEditingController(text: record?.notes ?? '');
    _nextMileageCtrl = TextEditingController(
      text: record?.nextServiceMileage?.toStringAsFixed(0) ?? '',
    );
    _workshopCtrl = TextEditingController(text: record?.workshop ?? '');

    _selectedType = record?.type ?? MaintenanceType.oilChange;
    _selectedDate = record?.date ?? DateTime.now();
    _nextServiceDate = record?.nextServiceDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _mileageCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    _nextMileageCtrl.dispose();
    _workshopCtrl.dispose();
    super.dispose();
  }

  String _normalizeText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickNextServiceDate() async {
    final initial =
        _nextServiceDate ?? _selectedDate.add(const Duration(days: 180));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );

    if (picked != null) {
      setState(() => _nextServiceDate = picked);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final mileageAtService = double.parse(_mileageCtrl.text.trim());
    final nextServiceMileage = _nextMileageCtrl.text.trim().isNotEmpty
        ? double.tryParse(_nextMileageCtrl.text.trim())
        : null;

    if (nextServiceMileage != null && nextServiceMileage <= mileageAtService) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Next service mileage must be greater than the current service mileage.',
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_nextServiceDate != null && _nextServiceDate!.isBefore(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Next service date must be after or equal to the current service date.',
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success =
        await ref.read(maintenanceNotifierProvider.notifier).saveRecord(
              vehicleId: widget.vehicleId,
              type: _selectedType,
              title: _normalizeText(_titleCtrl.text),
              date: _selectedDate,
              mileageAtService: mileageAtService,
              cost: _costCtrl.text.trim().isNotEmpty
                  ? double.tryParse(_costCtrl.text.trim())
                  : null,
              notes: _normalizeText(_notesCtrl.text).isNotEmpty
                  ? _normalizeText(_notesCtrl.text)
                  : null,
              nextServiceMileage: nextServiceMileage,
              nextServiceDate: _nextServiceDate,
              workshop: _normalizeText(_workshopCtrl.text).isNotEmpty
                  ? _normalizeText(_workshopCtrl.text)
                  : null,
              existingId: widget.existingRecord?.id,
            );

    if (!mounted) return;

    if (success) {
      ref.read(maintenanceNotifierProvider.notifier).reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Maintenance record updated successfully.'
                : 'Maintenance record saved successfully.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 450));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(maintenanceNotifierProvider);

    ref.listen<MaintenanceSaveState>(maintenanceNotifierProvider, (_, next) {
      if (next.status == MaintenanceSaveStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Failed to save record.'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Record' : 'Add Service Record'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditing ? 'Update Record' : 'Save Record',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          children: [
            const _SectionHeader(title: 'Service Type'),
            const SizedBox(height: 12),
            _TypeGrid(
              selected: _selectedType,
              onSelected: (type) {
                setState(() {
                  _selectedType = type;
                  if (_titleCtrl.text.trim().isEmpty ||
                      MaintenanceType.values.any(
                        (v) => v.displayName == _titleCtrl.text.trim(),
                      )) {
                    _titleCtrl.text = type.displayName;
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Details'),
            const SizedBox(height: 12),
            _buildField(
              controller: _titleCtrl,
              label: 'Title',
              hint: 'e.g. Oil Change',
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = _normalizeText(v ?? '');
                if (value.isEmpty) return 'Title is required';
                if (value.length < 3) return 'Title is too short';
                if (value.length > 80) return 'Title is too long';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Date',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('dd MMMM yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _mileageCtrl,
                    label: 'Mileage at Service',
                    hint: 'e.g. 45000',
                    suffix: 'km',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(7),
                    ],
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Mileage is required';
                      final parsed = double.tryParse(value);
                      if (parsed == null) return 'Invalid mileage';
                      if (parsed < 0) return 'Mileage cannot be negative';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _costCtrl,
                    label: 'Cost',
                    hint: 'e.g. 250',
                    suffix: 'RON',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return null;
                      final parsed = double.tryParse(value);
                      if (parsed == null) return 'Invalid cost';
                      if (parsed < 0) return 'Cost cannot be negative';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _workshopCtrl,
              label: 'Workshop / Location',
              hint: 'e.g. Auto Service Cluj',
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = _normalizeText(v ?? '');
                if (value.length > 100) return 'Text is too long';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _notesCtrl,
              label: 'Notes',
              hint: 'Any additional details...',
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              validator: (v) {
                final value = _normalizeText(v ?? '');
                if (value.length > 400) return 'Notes are too long';
                return null;
              },
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Next Service Reminder'),
            const SizedBox(height: 12),
            _buildField(
              controller: _nextMileageCtrl,
              label: 'Next Service at Mileage',
              hint: 'e.g. 50000',
              suffix: 'km',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return null;
                final parsed = double.tryParse(value);
                if (parsed == null) return 'Invalid mileage';
                if (parsed < 0) return 'Mileage cannot be negative';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Service Date',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _pickNextServiceDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _nextServiceDate != null
                              ? DateFormat('dd MMMM yyyy')
                                  .format(_nextServiceDate!)
                              : 'Tap to set date',
                          style: TextStyle(
                            fontSize: 14,
                            color: _nextServiceDate != null
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        if (_nextServiceDate != null)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _nextServiceDate = null),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ReminderInfoCard(
              nextDate: _nextServiceDate,
              nextMileage: _nextMileageCtrl.text.trim(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? suffix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
          ),
        ),
      ],
    );
  }
}

class _ReminderInfoCard extends StatelessWidget {
  const _ReminderInfoCard({
    required this.nextDate,
    required this.nextMileage,
  });

  final DateTime? nextDate;
  final String nextMileage;

  @override
  Widget build(BuildContext context) {
    final hasDate = nextDate != null;
    final hasMileage = nextMileage.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasDate || hasMileage
                  ? 'This record can help you remember the next service based on date or mileage.'
                  : 'You can optionally set the next service date or mileage for better tracking.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({
    required this.selected,
    required this.onSelected,
  });

  final MaintenanceType selected;
  final ValueChanged<MaintenanceType> onSelected;

  IconData _iconFor(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.oilChange:
        return Icons.oil_barrel_rounded;
      case MaintenanceType.tireRotation:
        return Icons.tire_repair_rounded;
      case MaintenanceType.brakeService:
        return Icons.emergency_rounded;
      case MaintenanceType.battery:
        return Icons.battery_charging_full_rounded;
      case MaintenanceType.airFilter:
        return Icons.air_rounded;
      case MaintenanceType.inspection:
        return Icons.fact_check_rounded;
      case MaintenanceType.sparkPlugs:
        return Icons.bolt_rounded;
      case MaintenanceType.transmission:
        return Icons.settings_rounded;
      case MaintenanceType.coolant:
        return Icons.thermostat_rounded;
      case MaintenanceType.timing:
        return Icons.timer_rounded;
      case MaintenanceType.other:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.85,
      children: MaintenanceType.values.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onSelected(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.12)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconFor(type),
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    type.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }
}
