import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/vehicle.dart';
import '../providers/vehicle_provider.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key, this.existingVehicle});
  final Vehicle? existingVehicle;

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _makeCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _mileageCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _vinCtrl;
  FuelType _selectedFuel = FuelType.petrol;

  bool get _isEditing => widget.existingVehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.existingVehicle;
    _makeCtrl = TextEditingController(text: v?.make ?? '');
    _modelCtrl = TextEditingController(text: v?.model ?? '');
    _yearCtrl = TextEditingController(
        text: v?.year.toString() ?? DateTime.now().year.toString());
    _plateCtrl = TextEditingController(text: v?.licensePlate ?? '');
    _mileageCtrl = TextEditingController(
        text: v?.initialMileageKm.toStringAsFixed(0) ?? '');
    _colorCtrl = TextEditingController(text: v?.color ?? '');
    _vinCtrl = TextEditingController(text: v?.vin ?? '');
    _selectedFuel = v?.fuelType ?? FuelType.petrol;
  }

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _mileageCtrl.dispose();
    _colorCtrl.dispose();
    _vinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final success =
        await ref.read(vehicleNotifierProvider.notifier).saveVehicle(
              userId: user.uid,
              make: _makeCtrl.text,
              model: _modelCtrl.text,
              year: int.parse(_yearCtrl.text),
              licensePlate: _plateCtrl.text,
              initialMileageKm: double.parse(_mileageCtrl.text),
              fuelType: _selectedFuel,
              color: _colorCtrl.text.isEmpty ? null : _colorCtrl.text,
              vin: _vinCtrl.text.isEmpty ? null : _vinCtrl.text,
              existingId: widget.existingVehicle?.id,
            );

    if (!mounted) return;

    if (success) {
      // ── FIX: reset starea ca sa nu ramana in loading ──
      ref.read(vehicleNotifierProvider.notifier).reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Vehicle updated successfully!'
              : 'Vehicle added successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleNotifierProvider);

    ref.listen<VehicleSaveState>(vehicleNotifierProvider, (_, next) {
      if (next.status == VehicleSaveStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage ?? 'Failed to save vehicle'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _submit,
              child: state.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      _isEditing ? 'Update Vehicle' : 'Add Vehicle',
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
            const _SectionHeader(title: 'Basic Information'),
            const SizedBox(height: 12),
            _buildField(
              controller: _makeCtrl,
              label: 'Make',
              hint: 'e.g. Toyota',
              validator: (v) =>
                  v == null || v.isEmpty ? 'Make is required' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _modelCtrl,
              label: 'Model',
              hint: 'e.g. Corolla',
              validator: (v) =>
                  v == null || v.isEmpty ? 'Model is required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _yearCtrl,
                    label: 'Year',
                    hint: '2020',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final year = int.tryParse(v ?? '');
                      if (year == null) return 'Invalid year';
                      if (year < 1900 || year > DateTime.now().year + 1) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FuelTypeDropdown(
                    value: _selectedFuel,
                    onChanged: (v) =>
                        setState(() => _selectedFuel = v ?? FuelType.petrol),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _plateCtrl,
              label: 'License Plate',
              hint: 'e.g. B-123-ABC',
              textCapitalization: TextCapitalization.characters,
              validator: (v) =>
                  v == null || v.isEmpty ? 'License plate is required' : null,
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Mileage'),
            const SizedBox(height: 8),
            const _MileageInfoCard(),
            const SizedBox(height: 12),
            _buildField(
              controller: _mileageCtrl,
              label: 'Current Mileage (km)',
              hint: 'e.g. 45000',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              suffix: 'km',
              validator: (v) {
                if (v == null || v.isEmpty) return 'Mileage is required';
                final km = double.tryParse(v);
                if (km == null || km < 0) return 'Invalid mileage';
                return null;
              },
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Optional Details'),
            const SizedBox(height: 12),
            _buildField(
              controller: _colorCtrl,
              label: 'Color',
              hint: 'e.g. Midnight Blue',
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _vinCtrl,
              label: 'VIN (Vehicle ID Number)',
              hint: '17-character code',
              textCapitalization: TextCapitalization.characters,
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: InputDecoration(hintText: hint, suffixText: suffix),
        ),
      ],
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
          letterSpacing: 1.2),
    );
  }
}

class _MileageInfoCard extends StatelessWidget {
  const _MileageInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enter your vehicle\'s current odometer reading. All future trips will be added on top of this.',
              style:
                  TextStyle(fontSize: 12, color: AppColors.info, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelTypeDropdown extends StatelessWidget {
  const _FuelTypeDropdown({required this.value, required this.onChanged});
  final FuelType value;
  final ValueChanged<FuelType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fuel Type',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        DropdownButtonFormField<FuelType>(
          value: value,
          onChanged: onChanged,
          decoration: const InputDecoration(),
          items: FuelType.values
              .map(
                  (f) => DropdownMenuItem(value: f, child: Text(f.displayName)))
              .toList(),
        ),
      ],
    );
  }
}
