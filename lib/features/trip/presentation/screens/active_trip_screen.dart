import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/trip_provider.dart';

class ActiveTripScreen extends ConsumerWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripNotifierProvider);

    // Cand GPS-ul esueaza, arata dialog manual automat
    ref.listen<ActiveTripState>(tripNotifierProvider, (prev, next) {
      if (next.status == TripStatus.gpsFailure &&
          prev?.status != TripStatus.gpsFailure) {
        _showManualStartDialog(context, ref);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip Tracker'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          // Buton manual mereu disponibil
          if (!tripState.isTracking && tripState.status != TripStatus.saving)
            TextButton.icon(
              onPressed: () => _showManualStartDialog(context, ref),
              icon:
                  Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
              label: Text('Manual',
                  style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _StatusBanner(state: tripState),
              const SizedBox(height: 24),

              // Locatii daca exista
              if (tripState.startLocation != null || tripState.isTracking)
                _LocationRow(state: tripState),

              const SizedBox(height: 24),
              _TrackingCircle(state: tripState),
              const SizedBox(height: 24),

              if (tripState.isTracking || tripState.status == TripStatus.saving)
                _StatsRow(state: tripState),

              const Spacer(),

              if (tripState.hasError)
                _ErrorBanner(
                  message: tripState.errorMessage!,
                  onManual: () => _showManualStartDialog(context, ref),
                ),

              const SizedBox(height: 16),
              _ActionButton(
                state: tripState,
                ref: ref,
                onStop: () => _confirmStop(context, ref),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showManualStartDialog(
      BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ManualLocationDialog(),
    );
    if (result != null) {
      await ref.read(tripNotifierProvider.notifier).startTripManual(
            startLocation: result['start'] ?? '',
            endLocation: result['end'],
          );
    }
  }

  Future<void> _confirmStop(BuildContext context, WidgetRef ref) async {
    // Dialog stop cu optiunea de a adauga locatia de destinatie
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _StopTripDialog(),
    );
    if (result != null && result['confirmed'] == true) {
      await ref.read(tripNotifierProvider.notifier).stopTrip(
            endLocation: result['endLocation'] as String?,
          );
    }
  }
}

// ── Manual Location Dialog ────────────────────────────────

class _ManualLocationDialog extends StatefulWidget {
  const _ManualLocationDialog();

  @override
  State<_ManualLocationDialog> createState() => _ManualLocationDialogState();
}

class _ManualLocationDialogState extends State<_ManualLocationDialog> {
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.edit_location_outlined,
              color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          const Text('Enter Locations', style: TextStyle(fontSize: 17)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GPS unavailable. Enter locations manually.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          // Start location
          TextField(
            controller: _startCtrl,
            decoration: InputDecoration(
              hintText: 'Start location (e.g. Cluj-Napoca)',
              prefixIcon:
                  Icon(Icons.trip_origin, color: AppColors.success, size: 18),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          // End location (optional)
          TextField(
            controller: _endCtrl,
            decoration: InputDecoration(
              hintText: 'Destination (optional)',
              prefixIcon:
                  Icon(Icons.place_outlined, color: AppColors.danger, size: 18),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_startCtrl.text.trim().isEmpty) return;
            Navigator.pop(context, {
              'start': _startCtrl.text.trim(),
              'end': _endCtrl.text.trim().isEmpty ? null : _endCtrl.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 40),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Start Trip'),
        ),
      ],
    );
  }
}

// ── Stop Trip Dialog ──────────────────────────────────────

class _StopTripDialog extends StatefulWidget {
  @override
  State<_StopTripDialog> createState() => _StopTripDialogState();
}

class _StopTripDialogState extends State<_StopTripDialog> {
  final _endCtrl = TextEditingController();

  @override
  void dispose() {
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Stop Trip?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Add your destination before saving (optional).'),
          const SizedBox(height: 16),
          TextField(
            controller: _endCtrl,
            decoration: InputDecoration(
              hintText: 'Destination (e.g. Bucharest)',
              prefixIcon:
                  Icon(Icons.place_outlined, color: AppColors.danger, size: 18),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, {'confirmed': false}),
          child: Text('Continue',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'confirmed': true,
            'endLocation':
                _endCtrl.text.trim().isEmpty ? null : _endCtrl.text.trim(),
          }),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 40),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Stop & Save'),
        ),
      ],
    );
  }
}

// ── Location Row ──────────────────────────────────────────

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.state});
  final ActiveTripState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.trip_origin, color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.startLocation ?? 'GPS tracking',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (state.endLocation != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 7),
              child: Container(width: 2, height: 12, color: AppColors.outline),
            ),
            Row(
              children: [
                Icon(Icons.place_outlined, color: AppColors.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.endLocation!,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Status Banner ─────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state});
  final ActiveTripState state;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (state.status) {
      case TripStatus.idle:
        color = AppColors.onSurfaceVariant;
        icon = Icons.radio_button_unchecked;
        label = 'Ready to start';
        break;
      case TripStatus.requesting:
        color = AppColors.warning;
        icon = Icons.gps_not_fixed;
        label = 'Getting GPS signal...';
        break;
      case TripStatus.gpsFailure:
        color = AppColors.warning;
        icon = Icons.gps_off;
        label = 'GPS unavailable — enter manually';
        break;
      case TripStatus.active:
        color = AppColors.success;
        icon = Icons.gps_fixed;
        label = '● TRIP ACTIVE';
        break;
      case TripStatus.activeManual:
        color = AppColors.secondary;
        icon = Icons.edit_location_alt_outlined;
        label = '● TRIP ACTIVE — Manual mode';
        break;
      case TripStatus.paused:
        color = AppColors.warning;
        icon = Icons.pause_circle_outline;
        label = 'Trip paused';
        break;
      case TripStatus.saving:
        color = AppColors.info;
        icon = Icons.cloud_upload_outlined;
        label = 'Saving trip...';
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          if (state.status == TripStatus.requesting)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main Circle ───────────────────────────────────────────

class _TrackingCircle extends StatelessWidget {
  const _TrackingCircle({required this.state});
  final ActiveTripState state;

  @override
  Widget build(BuildContext context) {
    final isActive = state.isTracking;
    final isManual = state.status == TripStatus.activeManual;
    final activeColor = isManual ? AppColors.secondary : AppColors.success;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(
          color:
              isActive ? activeColor.withValues(alpha: 0.5) : AppColors.outline,
          width: isActive ? 2.5 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 32,
                    spreadRadius: 4)
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.distanceDisplay,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: isActive ? activeColor : AppColors.onSurfaceVariant,
              letterSpacing: -1,
            ),
          ),
          Text('distance',
              style:
                  TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          Container(width: 40, height: 0.5, color: AppColors.outline),
          const SizedBox(height: 16),
          Text(
            state.elapsedDisplay,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color:
                  isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text('duration',
              style:
                  TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});
  final ActiveTripState state;

  @override
  Widget build(BuildContext context) {
    final avgSpeed = state.elapsedSeconds > 0
        ? (state.distanceKm / (state.elapsedSeconds / 3600))
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.speed_outlined,
            label: 'Avg Speed',
            value: '${avgSpeed.toStringAsFixed(1)} km/h',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.timer_outlined,
            label: 'Elapsed',
            value: state.elapsedDisplay,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface)),
                Text(label,
                    style: TextStyle(
                        fontSize: 10, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onManual});
  final String message;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(fontSize: 12, color: AppColors.danger)),
          ),
          TextButton(
            onPressed: onManual,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Manual',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.state, required this.ref, required this.onStop});
  final ActiveTripState state;
  final WidgetRef ref;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final isDisabled = state.status == TripStatus.requesting ||
        state.status == TripStatus.saving;

    if (state.isTracking) {
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          onPressed: isDisabled ? null : onStop,
          icon: const Icon(Icons.stop_rounded, size: 22),
          label: const Text('Stop & Save Trip',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    if (isDisabled) {
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white)),
              const SizedBox(width: 12),
              Text(
                state.status == TripStatus.saving
                    ? 'Saving trip...'
                    : 'Getting GPS...',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: () => ref.read(tripNotifierProvider.notifier).startTrip(),
        icon: const Icon(Icons.play_arrow_rounded, size: 24),
        label: const Text('Start Trip',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
