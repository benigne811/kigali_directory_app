// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

final _notifProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(_notifProvider.notifier).state = prefs.getBool('loc_notif') ?? false;
  }

  Future<void> _toggleNotif(bool val) async {
    ref.read(_notifProvider.notifier).state = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loc_notif', val);
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(authNotifierProvider.notifier).signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authUser  = ref.watch(authStateProvider).value;
    final userAsync = ref.watch(currentUserProvider);
    final notif     = ref.watch(_notifProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Profile card ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.primary,
                child: Text(
                  (authUser?.email ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(authUser?.email ?? '…',
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (authUser?.uid != null)
                      Text('ID: ${authUser!.uid.substring(0, 12)}…',
                          style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    userAsync.when(
                      data: (u) => u != null
                          ? Text(
                              'Member since ${DateFormat('MMM yyyy').format(u.createdAt)}',
                              style: AppTextStyles.caption)
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error:   (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('✓  Active account',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Preferences ─────────────────────────────────────────
          _label('Preferences'),
          _tile(
            icon: Icons.notifications_outlined,
            title: 'Location Notifications',
            subtitle: notif
                ? 'ON — Alerts enabled for nearby services'
                : 'OFF — Tap to enable nearby service alerts',
            trailing: Switch(
              value: notif,
              activeThumbColor: AppColors.primary,
              onChanged: _toggleNotif,
            ),
          ),
          const SizedBox(height: 20),

          // ── Account info ─────────────────────────────────────────
          _label('Account'),
          _tile(
            icon: Icons.email_outlined,
            title: 'Email Address',
            subtitle: authUser?.email ?? '…',
          ),
          const SizedBox(height: 8),
          _tile(
            icon: Icons.fingerprint,
            title: 'User ID',
            subtitle: authUser?.uid ?? '…',
          ),
          const SizedBox(height: 8),
          _tile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0  —  Kigali City Directory',
          ),
          const SizedBox(height: 32),

          // ── Sign out ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t,
        style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary)),
  );

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title:    Text(title,    style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
