import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.onSurface),
                onPressed: () => context.pop(),
              )
            : null,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: AppColors.outline),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),

          // ── Avatar ────────────────────────────────────
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              user?.displayName ?? 'Driver',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user?.email ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Account ───────────────────────────────────
          const _SectionLabel(label: 'Account'),
          const SizedBox(height: 10),
          _ProfileTile(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profile',
            onTap: () => _showEditProfileSheet(context, ref, user?.displayName),
          ),
          _ProfileTile(
            icon: Icons.lock_outline_rounded,
            label: 'Change Password',
            onTap: () => _showChangePasswordSheet(context, ref, user?.email),
          ),
          _ProfileTile(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            onTap: () => _showNotificationsSheet(context),
          ),
          const SizedBox(height: 24),

          // ── App ───────────────────────────────────────
          const _SectionLabel(label: 'App'),
          const SizedBox(height: 10),
          _ProfileTile(
            icon: Icons.directions_car_outlined,
            label: 'My Vehicles',
            onTap: () => context.push(RouteNames.vehicles),
          ),
          _ProfileTile(
            icon: Icons.bar_chart_outlined,
            label: 'Statistics',
            onTap: () => context.go(RouteNames.statistics),
          ),
          _ProfileTile(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Assistant',
            onTap: () => context.push(RouteNames.assistant),
          ),
          const SizedBox(height: 24),

          // ── Session ───────────────────────────────────
          const _SectionLabel(label: 'Session'),
          const SizedBox(height: 10),
          _ProfileTile(
            icon: Icons.swap_horiz_rounded,
            label: 'Switch Account',
            onTap: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go(RouteNames.login);
            },
          ),
          _ProfileTile(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            color: AppColors.danger,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  title: const Text('Log Out',
                      style: TextStyle(
                          color: AppColors.onSurface,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600)),
                  content: const Text('Are you sure you want to log out?',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'Poppins')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Log Out',
                          style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) context.go(RouteNames.login);
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Edit Profile ──────────────────────────────────────
  static void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, String? currentName) {
    final nameCtrl = TextEditingController(text: currentName ?? '');
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profile',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    try {
                      await ref
                          .read(authNotifierProvider.notifier)
                          .updateDisplayName(nameCtrl.text.trim());
                    } catch (_) {}
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Change Password ───────────────────────────────────
  static void _showChangePasswordSheet(
      BuildContext context, WidgetRef ref, String? email) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Change Password',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.check_circle_outline_rounded),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (newCtrl.text != confirmCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Passwords do not match'),
                          backgroundColor: AppColors.danger),
                    );
                    return;
                  }
                  if (newCtrl.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Password must be at least 6 characters'),
                          backgroundColor: AppColors.danger),
                    );
                    return;
                  }
                  try {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .changePassword(
                          email: email ?? '',
                          currentPassword: currentCtrl.text,
                          newPassword: newCtrl.text,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password changed successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Notifications ─────────────────────────────────────
  static void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _NotificationsSheet(),
    );
  }
}

// ── Notifications sheet ───────────────────────────────────

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _documents = true;
  bool _maintenance = true;
  bool _trips = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Notifications',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose which notifications you receive',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 20),
          _NotifToggle(
            icon: Icons.description_outlined,
            label: 'Document Expiry Reminders',
            subtitle: 'At 30 days, 7 days, and daily',
            value: _documents,
            onChanged: (v) => setState(() => _documents = v),
          ),
          const SizedBox(height: 12),
          _NotifToggle(
            icon: Icons.build_outlined,
            label: 'Maintenance Reminders',
            subtitle: 'When service is due soon',
            value: _maintenance,
            onChanged: (v) => setState(() => _maintenance = v),
          ),
          const SizedBox(height: 12),
          _NotifToggle(
            icon: Icons.route_outlined,
            label: 'Trip Summaries',
            subtitle: 'After each completed trip',
            value: _trips,
            onChanged: (v) => setState(() => _trips = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save Preferences'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  const _NotifToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        fontFamily: 'Poppins')),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white, // ✅ înlocuit activeColor
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        fontFamily: 'Poppins',
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: tileColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: tileColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
