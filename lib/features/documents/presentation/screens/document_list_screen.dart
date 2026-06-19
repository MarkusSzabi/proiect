import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../vehicle/presentation/providers/vehicle_provider.dart';
import '../../domain/entities/vehicle_document.dart';
import '../providers/document_provider.dart';
import 'add_document_screen.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(documentsProvider);
    final activeVehicle = ref.watch(activeVehicleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      floatingActionButton: activeVehicle == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddDocumentScreen(vehicleId: activeVehicle.id),
                  ),
                );
                ref.invalidate(documentsProvider);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Document'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
      body: activeVehicle == null
          ? const _NoVehiclePrompt()
          : docs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ListErrorState(message: 'Error: $e'),
              data: (list) {
                if (list.isEmpty) return const _EmptyState();

                final sorted = [...list]
                  ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

                return _DocumentsList(
                  documents: sorted,
                  onDeleted: () => ref.invalidate(documentsProvider),
                  onEdited: () => ref.invalidate(documentsProvider),
                  vehicleId: activeVehicle.id,
                );
              },
            ),
    );
  }
}

class _DocumentsList extends ConsumerWidget {
  const _DocumentsList({
    required this.documents,
    required this.onDeleted,
    required this.onEdited,
    required this.vehicleId,
  });

  final List<VehicleDocument> documents;
  final VoidCallback onDeleted;
  final VoidCallback onEdited;
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expired = documents.where((d) => d.isExpired).toList();
    final expiringSoon =
        documents.where((d) => !d.isExpired && d.isExpiringSoon).toList();
    final valid =
        documents.where((d) => !d.isExpired && !d.isExpiringSoon).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _SummaryRow(
          total: documents.length,
          expired: expired.length,
          expiringSoon: expiringSoon.length,
        ),
        const SizedBox(height: 18),
        if (expired.isNotEmpty) ...[
          const _GroupHeader(label: 'Expired', color: AppColors.danger),
          const SizedBox(height: 8),
          ...expired.map(
            (d) => _DocumentTile(
              document: d,
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddDocumentScreen(
                      vehicleId: vehicleId,
                      existingDocument: d,
                    ),
                  ),
                );
                onEdited();
              },
              onDelete: () async {
                final confirmed =
                    await _confirmDelete(context, d.type.displayName);
                if (confirmed) {
                  await ref
                      .read(documentNotifierProvider.notifier)
                      .deleteDocument(d.id);
                  onDeleted();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${d.type.displayName} deleted.'),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (expiringSoon.isNotEmpty) ...[
          const _GroupHeader(label: 'Expiring Soon', color: AppColors.warning),
          const SizedBox(height: 8),
          ...expiringSoon.map(
            (d) => _DocumentTile(
              document: d,
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddDocumentScreen(
                      vehicleId: vehicleId,
                      existingDocument: d,
                    ),
                  ),
                );
                onEdited();
              },
              onDelete: () async {
                final confirmed =
                    await _confirmDelete(context, d.type.displayName);
                if (confirmed) {
                  await ref
                      .read(documentNotifierProvider.notifier)
                      .deleteDocument(d.id);
                  onDeleted();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${d.type.displayName} deleted.'),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (valid.isNotEmpty) ...[
          const _GroupHeader(label: 'Valid', color: AppColors.success),
          const SizedBox(height: 8),
          ...valid.map(
            (d) => _DocumentTile(
              document: d,
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddDocumentScreen(
                      vehicleId: vehicleId,
                      existingDocument: d,
                    ),
                  ),
                );
                onEdited();
              },
              onDelete: () async {
                final confirmed =
                    await _confirmDelete(context, d.type.displayName);
                if (confirmed) {
                  await ref
                      .read(documentNotifierProvider.notifier)
                      .deleteDocument(d.id);
                  onDeleted();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${d.type.displayName} deleted.'),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String docName) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Document'),
            content: Text(
              'Are you sure you want to delete "$docName"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.total,
    required this.expired,
    required this.expiringSoon,
  });

  final int total;
  final int expired;
  final int expiringSoon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryCard(
          label: 'Total',
          value: total.toString(),
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        _SummaryCard(
          label: 'Expired',
          value: expired.toString(),
          color: AppColors.danger,
        ),
        const SizedBox(width: 10),
        _SummaryCard(
          label: 'Soon',
          value: expiringSoon.toString(),
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.document,
    required this.onEdit,
    required this.onDelete,
  });

  final VehicleDocument document;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
    final expiryStr = DateFormat('dd MMM yyyy').format(document.expiryDate);
    final statusColor = document.isExpired
        ? AppColors.danger
        : document.isExpiringSoon
            ? AppColors.warning
            : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: document.isExpired
              ? AppColors.danger.withValues(alpha: 0.4)
              : document.isExpiringSoon
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : AppColors.outline.withValues(alpha: 0.3),
          width: (document.isExpired || document.isExpiringSoon) ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconFor(document.type),
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.type.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: $expiryStr',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    document.statusDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.folder_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No documents yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the add button to save your first insurance, ITP, rovinieta, or other document.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoVehiclePrompt extends StatelessWidget {
  const _NoVehiclePrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 40,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No vehicle selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add or select a vehicle first to manage its documents.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListErrorState extends StatelessWidget {
  const _ListErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 42,
              color: AppColors.danger,
            ),
            const SizedBox(height: 14),
            const Text(
              'Could not load documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
