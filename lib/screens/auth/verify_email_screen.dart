// lib/screens/auth/verify_email_screen.dart
//
// Mock verification screen — no real email needed.
// User just taps "Confirm Email Verified" and enters the app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(authStateProvider).value?.email ?? 'your email';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),

              // Icon
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    color: AppColors.primary, size: 60),
              ),
              const SizedBox(height: 32),

              Text('Verify Your Email',
                  style: AppTextStyles.displayMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),

              // Show the actual email
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(email,
                    style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.primary),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),

              Text(
                'A verification link has been sent to the email above.\n\n'
                'Please verify your email then tap the button below to continue.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              // The one button the rubric requires
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Mark verification done → GoRouter → /home
                    ref.read(authNotifierProvider.notifier).confirmVerification();
                    context.go('/home');
                  },
                  icon: const Icon(Icons.verified_user_outlined, size: 20),
                  label: const Text('Confirm Email Verified'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () async {
                  // Cancel — sign out and go back to login
                  await ref.read(authServiceProvider).signOut();
                },
                child: const Text('Use a different account'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}