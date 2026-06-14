import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vehicle_document.dart';
import '../providers/document_provider.dart';

class AddDocumentScreen extends ConsumerStatefulWidget {
  const AddDocumentScreen({
    super.key,
    required this.vehicleId,
    this.existingDocument,
  });

  final String vehicleId;
  final VehicleDocument? existingDocument;

  @override
  ConsumerState<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends ConsumerState<AddDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _notesCtrl;

  DocumentType _selectedType = DocumentType.insurance;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));

  // Notificările se trimit automat: 30 zile, 7 zile, zilnic în ultimele 7 zile
  // Nu mai e nevoie de reminder ales manual
  static const int _autoReminderDays = 30;

  bool get _isEditing => widget.existingDocument != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existingDocument;
    _notesCtrl = TextEditingController(text: d?.notes ?? '');
    _selectedType = d?.type ?? DocumentType.insurance;
    _expiryDate =
        d?.expiryDate ?? DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success =
        await ref.read(documentNotifierProvider.notifier).saveDocument(
              vehicleId: widget.vehicleId,
              type: _selectedType,
              expiryDate: _expiryDate,
              reminderDaysBefore: _autoReminderDays,
              notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
              existingId: widget.existingDocument?.id,
            );

    if (!mounted) return;

    if (success) {
      ref.read(documentNotifierProvider.notifier).reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Document updated!' : 'Document saved!'),
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
    final state = ref.watch(documentNotifierProvider);

    ref.listen<DocumentSaveState>(documentNotifierProvider, (_, next) {
      if (next.status == DocumentSaveStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage ?? 'Failed to save document'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Document' : 'Add Document'),
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
                      _isEditing ? 'Update Document' : 'Save Document',
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
            // ── Tip document ──────────────────────────────
            const _SectionHeader(title: 'Document Type'),
            const SizedBox(height: 12),
            _TypeGrid(
              selected: _selectedType,
              onSelected: (t) => setState(() => _selectedType = t),
            ),
            const SizedBox(height: 24),

            // ── Data expirare ─────────────────────────────
            const _SectionHeader(title: 'Expiry Date'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickExpiryDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMMM yyyy').format(_expiryDate),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right,
                        color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Info notificări automate ───────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      color: AppColors.primaryLight, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'You\'ll be notified automatically at 30 days, 7 days, and daily in the last week before expiry.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Note ─────────────────────────────────────
            const _SectionHeader(title: 'Notes (optional)'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Policy number, insurer name, etc.',
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.selected, required this.onSelected});
  final DocumentType selected;
  final ValueChanged<DocumentType> onSelected;

  IconData _iconFor(DocumentType type) {
    switch (type) {
      case DocumentType.insurance:
        return Icons.shield_outlined;
      case DocumentType.itp:
        return Icons.fact_check_outlined;
      case DocumentType.rovinieta:
        return Icons.route_outlined;
      case DocumentType.rcaCard:
        return Icons.description_outlined;
      case DocumentType.registrationCertificate:
        return Icons.app_registration_outlined;
      case DocumentType.drivingLicense:
        return Icons.credit_card_outlined;
      case DocumentType.other:
        return Icons.folder_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: DocumentType.values.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onSelected(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.10)
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
                  size: 24,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Text(
                  type.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
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
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }
}
