import 'package:go_router/go_router.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/presentation/auth/splash_screen.dart';
import 'package:fitcoach/presentation/auth/login_screen.dart';
import 'package:fitcoach/presentation/auth/register_screen.dart';
import 'package:fitcoach/presentation/onboarding/onboarding_screen.dart';
import 'package:fitcoach/presentation/onboarding/profile_loading_screen.dart';
import 'package:fitcoach/presentation/home/home_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.routeSplash,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppConstants.routeProfileLoading,
        builder: (context, state) => ProfileLoadingScreen(
          profile: state.extra as UserProfile,
        ),
      ),
      GoRoute(
        path: AppConstants.routeHome,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
