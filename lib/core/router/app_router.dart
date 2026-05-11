import 'package:go_router/go_router.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/core/router/app_transitions.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/presentation/auth/splash_screen.dart';
import 'package:fitcoach/presentation/auth/login_screen.dart';
import 'package:fitcoach/presentation/auth/register_screen.dart';
import 'package:fitcoach/presentation/onboarding/onboarding_screen.dart';
import 'package:fitcoach/presentation/onboarding/profile_loading_screen.dart';
import 'package:fitcoach/presentation/home/main_screen.dart';
import 'package:fitcoach/presentation/training/session_detail_screen.dart';
import 'package:fitcoach/presentation/training/active_session_screen.dart';
import 'package:fitcoach/presentation/profile/profile_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.routeSplash,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        pageBuilder: (context, state) => fadePage(
          child: const SplashScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        pageBuilder: (context, state) => fadePage(
          child: const LoginScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        pageBuilder: (context, state) => slideHorizontal(
          child: const RegisterScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        pageBuilder: (context, state) => fadePage(
          child: const OnboardingScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: AppConstants.routeProfileLoading,
        pageBuilder: (context, state) => fadePage(
          child: ProfileLoadingScreen(
            profile: state.extra as UserProfile,
          ),
          state: state,
        ),
      ),
      GoRoute(
        path: AppConstants.routeHome,
        pageBuilder: (context, state) => fadePage(
          child: const MainScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: AppConstants.routeSessionDetail,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return fadeSlideUp(
            child: SessionDetailScreen(
              workout: args['workout'] as WorkoutDay,
              diaNombre: args['diaNombre'] as String,
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeActiveSession,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return fadeSlideUp(
            child: ActiveSessionScreen(
              workout: args['workout'] as WorkoutDay,
              diaNombre: args['diaNombre'] as String,
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeProfile,
        pageBuilder: (context, state) => slideHorizontal(
          child: const ProfileScreen(),
          state: state,
        ),
      ),
    ],
  );
}
