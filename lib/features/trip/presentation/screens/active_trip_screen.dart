import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/trip_provider.dart';

class ActiveTripScreen extends ConsumerWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripNotifierProvider);

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
    final tripState = ref.read(tripNotifierProvider);
    final isManual = tripState.status == TripStatus.activeManual;
    final hasNoGpsDistance = tripState.distanceKm == 0;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) =>
          _StopTripDialog(askForManualKm: isManual && hasNoGpsDistance),
    );

    if (result != null && result['confirmed'] == true) {
      await ref.read(tripNotifierProvider.notifier).stopTrip(
            endLocation: result['endLocation'] as String?,
            manualDistanceKm: result['manualKm'] as double?,
          );
    }
  }
}

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

class _StopTripDialog extends StatefulWidget {
  const _StopTripDialog({required this.askForManualKm});
  final bool askForManualKm;

  @override
  State<_StopTripDialog> createState() => _StopTripDialogState();
}

class _StopTripDialogState extends State<_StopTripDialog> {
  final _endCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();

  @override
  void dispose() {
    _endCtrl.dispose();
    _kmCtrl.dispose();
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
          if (widget.askForManualKm) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _kmCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              decoration: InputDecoration(
                hintText: 'Distance driven (km)',
                prefixIcon: Icon(Icons.route_outlined,
                    color: AppColors.primary, size: 18),
                suffixText: 'km',
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, {'confirmed': false}),
          child: Text('Continue',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
        ElevatedButton(
          onPressed: () {
            final endLoc =
                _endCtrl.text.trim().isEmpty ? null : _endCtrl.text.trim();
            final manualKm = double.tryParse(_kmCtrl.text.trim());
            Navigator.pop(context, {
              'confirmed': true,
              'endLocation': endLoc,
              'manualKm': manualKm,
            });
          },
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
      ),
      child: Row(
        children: [
          Column(
            children: [
              Icon(Icons.trip_origin, color: AppColors.success, size: 16),
              Container(
                  width: 1, height: 20, color: AppColors.onSurfaceVariant),
              Icon(Icons.place_outlined, color: AppColors.danger, size: 16),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.startLocation ?? 'Getting GPS...',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  state.endLocation ?? 'In progress...',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state});
  final ActiveTripState state;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    IconData icon;

    switch (state.status) {
      case TripStatus.idle:
        text = 'Ready to start';
        color = AppColors.onSurfaceVariant;
        icon = Icons.directions_car_outlined;
      case TripStatus.requesting:
        text = 'Getting GPS signal...';
        color = AppColors.primary;
        icon = Icons.gps_fixed;
      case TripStatus.gpsFailure:
        text = 'GPS unavailable — switch to manual mode';
        color = AppColors.warning;
        icon = Icons.gps_off;
      case TripStatus.active:
        text = 'Tracking with GPS';
        color = AppColors.success;
        icon = Icons.gps_fixed;
      case TripStatus.activeManual:
        text = 'Manual mode — timer running';
        color = AppColors.primary;
        icon = Icons.edit_location_alt_outlined;
      case TripStatus.paused:
        text = 'Trip paused';
        color = AppColors.warning;
        icon = Icons.pause_circle_outline;
      case TripStatus.saving:
        text = 'Saving trip...';
        color = AppColors.primary;
        icon = Icons.save_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _TrackingCircle extends StatelessWidget {
  const _TrackingCircle({required this.state});
  final ActiveTripState state;

  @override
  Widget build(BuildContext context) {
    final isActive = state.isTracking;
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive ? null : AppColors.surfaceVariant,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.isTracking ? state.elapsedDisplay : '00:00',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : AppColors.onSurface,
              fontFamily: 'Poppins',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isActive ? 'elapsed' : 'tap to start',
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? Colors.white.withOpacity(0.8)
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});
  final ActiveTripState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatChip(
          icon: Icons.route_outlined,
          value: state.distanceDisplay,
          label: 'Distance',
        ),
        _StatChip(
          icon: Icons.timer_outlined,
          value: state.elapsedDisplay,
          label: 'Duration',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins')),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onManual});
  final String message;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gps_off, color: AppColors.warning, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onManual,
            child: Text(
              'Switch to manual mode →',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.state,
    required this.ref,
    required this.onStop,
  });
  final ActiveTripState state;
  final WidgetRef ref;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    if (state.status == TripStatus.saving) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isTracking) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: onStop,
          icon: const Icon(Icons.stop_rounded, size: 22),
          label: const Text('Stop & Save Trip',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    if (state.status == TripStatus.requesting) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white)),
              const SizedBox(width: 12),
              const Text('Getting GPS...',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => ref.read(tripNotifierProvider.notifier).startTrip(),
        icon: const Icon(Icons.play_arrow_rounded, size: 24),
        label: const Text('Start Trip',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
