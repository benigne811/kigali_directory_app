// lib/main.dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'utils/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/detail/service_detail_screen.dart';
import 'screens/directory/category_screen.dart';
import 'screens/listings/add_listing_screen.dart';
import 'screens/listings/edit_listing_screen.dart';
import 'models/listing_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: KigaliDirectoryApp()));
}

class KigaliDirectoryApp extends ConsumerWidget {
  const KigaliDirectoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Kigali City Directory',
      theme: AppTheme.theme,
      routerConfig: _buildRouter(ref),
      debugShowCheckedModeBanner: false,
    );
  }
}

GoRouter _buildRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      ref.read(authServiceProvider).authStateChanges,
    ),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final path = state.matchedLocation;

      if (!isLoggedIn) {
        if (path == '/register') return null;
        if (path == '/verify-email') return null;
        if (path == '/login') return null;
        return '/login';
      }

      // Logged in — check if awaiting mock verification
      final needsVerify = ref.read(needsVerificationProvider);
      if (needsVerify && path != '/verify-email') return '/verify-email';
      if (!needsVerify && path == '/verify-email') return '/home';

      if (path == '/login' || path == '/register') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: '/verify-email', builder: (_, __) => const VerifyEmailScreen()),
      GoRoute(path: '/home', builder: (_, __) => const MainShell()),
      GoRoute(
        path: '/listing/:id',
        builder: (_, state) => ServiceDetailScreen(
          listingId: state.pathParameters['id']!,
          listing: state.extra as ListingModel?,
        ),
      ),
      GoRoute(
        path: '/category/:cat',
        builder: (_, state) => CategoryScreen(
          category: ListingCategory.fromValue(state.pathParameters['cat']),
        ),
      ),
      GoRoute(
          path: '/add-listing', builder: (_, __) => const AddListingScreen()),
      GoRoute(
        path: '/edit-listing/:id',
        builder: (_, state) => EditListingScreen(
          listing: state.extra as ListingModel,
        ),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
