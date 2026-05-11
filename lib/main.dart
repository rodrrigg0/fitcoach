import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/router/app_router.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/core/providers/locale_provider.dart';
import 'package:fitcoach/data/services/auth_service.dart';
import 'package:fitcoach/data/services/firestore_service.dart';
import 'package:fitcoach/firebase_options.dart';
import 'package:fitcoach/presentation/auth/auth_provider.dart';
import 'package:fitcoach/data/services/onboarding_provider.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/data/services/chat_provider.dart';
import 'package:fitcoach/data/services/training_provider.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final localeProvider = LocaleProvider();
  await localeProvider.cargarPreferencia();

  runApp(FitCoachApp(localeProvider: localeProvider));
}

class FitCoachApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  const FitCoachApp({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(
          create: (_) => TrainingProvider()..cargarHistorial(),
        ),
        ChangeNotifierProxyProvider<ChatProvider, HomeProvider>(
          create: (_) => HomeProvider()..cargarDatos(),
          update: (_, chat, home) {
            chat.onPlanNutricionActualizado = () {
              home?.sincronizarNutricion(chat.planNutricion);
            };
            chat.onPlanEntrenamientoActualizado = () {
              home?.sincronizarEntrenamiento(chat.planEntrenamiento);
            };
            return home!;
          },
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) => MaterialApp.router(
          title: 'FitCoach',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: locale.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es'),
            Locale('en'),
          ],
          scrollBehavior: const ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
            scrollbars: false,
          ),
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
