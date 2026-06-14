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
  late final TextEditingController _workshopCtrl;
  late final TextEditingController _nextMileageCtrl;

  MaintenanceType _selectedType = MaintenanceType.oilChange;
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextServiceDate;

  bool get _isEditing => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecord;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _mileageCtrl = TextEditingController(
        text: r?.mileageAtService.toStringAsFixed(0) ?? '');
    _costCtrl = TextEditingController(text: r?.cost?.toStringAsFixed(0) ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _workshopCtrl = TextEditingController(text: r?.workshop ?? '');
    _nextMileageCtrl = TextEditingController(
        text: r?.nextServiceMileage?.toStringAsFixed(0) ?? '');
    _selectedType = r?.type ?? MaintenanceType.oilChange;
    _selectedDate = r?.date ?? DateTime.now();
    _nextServiceDate = r?.nextServiceDate;

    // Auto-fill titlu cand se schimba tipul
    if (r == null) {
      _titleCtrl.text = _selectedType.displayName;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _mileageCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    _workshopCtrl.dispose();
    _nextMileageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickNextServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _nextServiceDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );
    if (picked != null) setState(() => _nextServiceDate = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(maintenanceNotifierProvider.notifier)
        .saveRecord(
          vehicleId: widget.vehicleId,
          type: _selectedType,
          title: _titleCtrl.text,
          date: _selectedDate,
          mileageAtService: double.parse(_mileageCtrl.text),
          cost: _costCtrl.text.isNotEmpty
              ? double.tryParse(_costCtrl.text)
              : null,
          notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
          nextServiceMileage: _nextMileageCtrl.text.isNotEmpty
              ? double.tryParse(_nextMileageCtrl.text)
              : null,
          nextServiceDate: _nextServiceDate,
          workshop: _workshopCtrl.text.isNotEmpty ? _workshopCtrl.text : null,
          existingId: widget.existingRecord?.id,
        );

    if (!mounted) return;

    if (success) {
      ref.read(maintenanceNotifierProvider.notifier).reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEditing ? 'Record updated!' : 'Maintenance record saved!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(maintenanceNotifierProvider);

    ref.listen<MaintenanceSaveState>(maintenanceNotifierProvider, (_, next) {
      if (next.status == MaintenanceSaveStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage ?? 'Failed to save record'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
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
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      _isEditing ? 'Update Record' : 'Save Record',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
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
            // ── Tip serviciu ──────────────────────────────
            const _SectionHeader(title: 'Service Type'),
            const SizedBox(height: 12),
            _TypeGrid(
              selected: _selectedType,
              onSelected: (t) => setState(() {
                _selectedType = t;
                if (_titleCtrl.text.isEmpty ||
                    MaintenanceType.values
                        .any((v) => v.displayName == _titleCtrl.text)) {
                  _titleCtrl.text = t.displayName;
                }
              }),
            ),
            const SizedBox(height: 20),

            // ── Informatii de baza ────────────────────────
            const _SectionHeader(title: 'Details'),
            const SizedBox(height: 12),
            _buildField(
              controller: _titleCtrl,
              label: 'Title',
              hint: 'e.g. Oil Change',
              validator: (v) =>
                  v == null || v.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),

            // Data serviciului
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
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.outline.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16, color: AppColors.primary),
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _costCtrl,
                    label: 'Cost (optional)',
                    hint: 'e.g. 250',
                    suffix: 'RON',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _workshopCtrl,
              label: 'Workshop / Location (optional)',
              hint: 'e.g. Auto Service Cluj',
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _notesCtrl,
              label: 'Notes (optional)',
              hint: 'Any additional details...',
              maxLines: 3,
            ),

            // ── Urmatorul service ─────────────────────────
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Next Service Reminder'),
            const SizedBox(height: 12),

            _buildField(
              controller: _nextMileageCtrl,
              label: 'Next Service at Mileage (optional)',
              hint: 'e.g. 50000',
              suffix: 'km',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),

            // Data urmatoare
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Service Date (optional)',
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
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.outline.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          _nextServiceDate != null
                              ? DateFormat('dd MMMM yyyy')
                                  .format(_nextServiceDate!)
                              : 'Tap to set date',
                          style: TextStyle(
                            fontSize: 14,
                            color: _nextServiceDate != null
                                ? null
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        if (_nextServiceDate != null)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _nextServiceDate = null),
                            child: Icon(Icons.close,
                                size: 16, color: AppColors.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
          decoration: InputDecoration(hintText: hint, suffixText: suffix),
        ),
      ],
    );
  }
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.selected, required this.onSelected});
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
                  ? AppColors.primary.withValues(alpha: 0.12)
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
                Text(
                  type.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
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
