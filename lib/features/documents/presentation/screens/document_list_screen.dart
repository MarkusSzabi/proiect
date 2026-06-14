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
          ? _NoVehiclePrompt()
          : docs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) return const _EmptyState();
                return _DocumentsList(
                  documents: list,
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
        if (expired.isNotEmpty) ...[
          _GroupHeader(label: 'Expired', color: AppColors.danger),
          const SizedBox(height: 8),
          ...expired.map((d) => _DocumentTile(
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
                  final confirmed = await _confirmDelete(context);
                  if (confirmed) {
                    await ref
                        .read(documentNotifierProvider.notifier)
                        .deleteDocument(d.id);
                    onDeleted();
                  }
                },
              )),
          const SizedBox(height: 16),
        ],
        if (expiringSoon.isNotEmpty) ...[
          _GroupHeader(label: 'Expiring Soon', color: AppColors.warning),
          const SizedBox(height: 8),
          ...expiringSoon.map((d) => _DocumentTile(
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
                  final confirmed = await _confirmDelete(context);
                  if (confirmed) {
                    await ref
                        .read(documentNotifierProvider.notifier)
                        .deleteDocument(d.id);
                    onDeleted();
                  }
                },
              )),
          const SizedBox(height: 16),
        ],
        if (valid.isNotEmpty) ...[
          _GroupHeader(label: 'Valid', color: AppColors.success),
          const SizedBox(height: 8),
          ...valid.map((d) => _DocumentTile(
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
                  final confirmed = await _confirmDelete(context);
                  if (confirmed) {
                    await ref
                        .read(documentNotifierProvider.notifier)
                        .deleteDocument(d.id);
                    onDeleted();
                  }
                },
              )),
        ],
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Document'),
            content:
                const Text('Are you sure you want to delete this document?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    Text('Delete', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
            // ── NOU: Icon în loc de Text(emoji) ──────────
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
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 11, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: $expiryStr',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.onSurfaceVariant),
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
            icon: Icon(Icons.more_vert,
                color: AppColors.onSurfaceVariant, size: 20),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'delete',
                child:
                    Text('Delete', style: TextStyle(color: AppColors.danger)),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No documents yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tap + to add your first document',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _NoVehiclePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No vehicle selected',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Add a vehicle first to manage documents',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
