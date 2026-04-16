import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Splash screen tagline
  ///
  /// In es, this message translates to:
  /// **'Tu entrenador personal con IA'**
  String get appTagline;

  /// Bottom nav: Home
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// Bottom nav: Training
  ///
  /// In es, this message translates to:
  /// **'Entreno'**
  String get navTraining;

  /// Bottom nav: Nutrition
  ///
  /// In es, this message translates to:
  /// **'Nutrición'**
  String get navNutrition;

  /// Bottom nav: Chat
  ///
  /// In es, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// Login screen title
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get loginTitle;

  /// Login screen subtitle
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para continuar'**
  String get loginSubtitle;

  /// Email field hint
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get loginEmailHint;

  /// Password field hint
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPasswordHint;

  /// Login button label
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginButton;

  /// Forgot password link
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get loginForgotPassword;

  /// Create account button
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta nueva'**
  String get loginCreateAccount;

  /// Recovery dialog title
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get loginRecoverTitle;

  /// Recovery email sent message
  ///
  /// In es, this message translates to:
  /// **'Email de recuperación enviado. Revisa tu bandeja.'**
  String get loginRecoverSent;

  /// Recovery email error message
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el email de recuperación'**
  String get loginRecoverError;

  /// Login error message
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get loginError;

  /// Cancel button
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Send button
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get send;

  /// Save button
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Or divider text
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get or;

  /// Register screen title
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get registerTitle;

  /// Register screen subtitle
  ///
  /// In es, this message translates to:
  /// **'Empieza tu transformación hoy'**
  String get registerSubtitle;

  /// Full name field hint
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get registerNameHint;

  /// Confirm password field hint
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get registerConfirmPasswordHint;

  /// Register button label
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get registerButton;

  /// Terms text prefix
  ///
  /// In es, this message translates to:
  /// **'Al registrarte aceptas nuestros\n'**
  String get registerTerms;

  /// Terms and conditions link
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get registerTermsLink;

  /// Register error message
  ///
  /// In es, this message translates to:
  /// **'Error al crear la cuenta'**
  String get registerError;

  /// Validate email empty
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo'**
  String get validateEmail;

  /// Validate email format
  ///
  /// In es, this message translates to:
  /// **'Formato de correo no válido'**
  String get validateEmailFormat;

  /// Validate password empty
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get validatePassword;

  /// Validate password length
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get validatePasswordLength;

  /// Validate confirm password empty
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get validateConfirmPassword;

  /// Validate password mismatch
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get validatePasswordMismatch;

  /// Validate name empty
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get validateName;

  /// Home greeting
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String homeHello(String name);

  /// Streak badge
  ///
  /// In es, this message translates to:
  /// **'🔥 {days} días'**
  String homeStreak(int days);

  /// Hero card day tag
  ///
  /// In es, this message translates to:
  /// **'HOY · {category}'**
  String homeHeroTag(String category);

  /// Rest day message
  ///
  /// In es, this message translates to:
  /// **'El descanso es parte del entrenamiento'**
  String get homeRestMessage;

  /// Start session button
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get homeStartSession;

  /// View full plan link
  ///
  /// In es, this message translates to:
  /// **'Ver plan completo'**
  String get homeViewFullPlan;

  /// Calories today label
  ///
  /// In es, this message translates to:
  /// **'Calorías hoy'**
  String get homeCaloriesToday;

  /// Next meal label
  ///
  /// In es, this message translates to:
  /// **'Próxima comida'**
  String get homeNextMeal;

  /// All meals completed label
  ///
  /// In es, this message translates to:
  /// **'Plan completado'**
  String get homePlanCompleted;

  /// Current weight label
  ///
  /// In es, this message translates to:
  /// **'Peso actual'**
  String get homeCurrentWeight;

  /// Weight source label
  ///
  /// In es, this message translates to:
  /// **'desde el perfil'**
  String get homeWeightFromProfile;

  /// Sleep label when registered
  ///
  /// In es, this message translates to:
  /// **'Sueño anoche'**
  String get homeSleepLabel;

  /// Sleep question when not registered
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto dormiste?'**
  String get homeSleepQuestion;

  /// Register sleep button
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get homeSleepRegister;

  /// Sleep hours modal title
  ///
  /// In es, this message translates to:
  /// **'Horas de sueño'**
  String get homeSleepHours;

  /// Weekly tracker label
  ///
  /// In es, this message translates to:
  /// **'SEMANA ACTUAL'**
  String get homeWeekLabel;

  /// Daily macros label
  ///
  /// In es, this message translates to:
  /// **'MACROS DE HOY'**
  String get homeMacrosLabel;

  /// No plan label
  ///
  /// In es, this message translates to:
  /// **'Sin plan'**
  String get homeNoPlan;

  /// No active plan label
  ///
  /// In es, this message translates to:
  /// **'Sin plan activo'**
  String get homeNoPlanActive;

  /// Generating plan with AI
  ///
  /// In es, this message translates to:
  /// **'Generando plan con IA...'**
  String get homeGeneratingAI;

  /// Generate plan button
  ///
  /// In es, this message translates to:
  /// **'Generar mi plan'**
  String get homeGeneratePlan;

  /// Generate plan description
  ///
  /// In es, this message translates to:
  /// **'Genera tu plan de entrenamiento personalizado con IA'**
  String get homeGeneratePlanDesc;

  /// Coach name in quick access
  ///
  /// In es, this message translates to:
  /// **'Entrenador FitCoach'**
  String get homeCoach;

  /// Chat question when no plan
  ///
  /// In es, this message translates to:
  /// **'¿Tienes alguna duda sobre tu plan?'**
  String get homeNoPlanQuestion;

  /// Chat question on rest day
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te has recuperado hoy?'**
  String get homeRestQuestion;

  /// Chat question before session
  ///
  /// In es, this message translates to:
  /// **'¿Listo para tu sesión de {sport}?'**
  String homeReadyQuestion(String sport);

  /// Calories consumed of goal
  ///
  /// In es, this message translates to:
  /// **'{consumed} de {goal} kcal'**
  String homeCaloriesOf(int consumed, int goal);

  /// Protein macro label
  ///
  /// In es, this message translates to:
  /// **'Proteína'**
  String get homeMacroProtein;

  /// Carbs macro label
  ///
  /// In es, this message translates to:
  /// **'Carbos'**
  String get homeMacroCarbs;

  /// Fat macro label
  ///
  /// In es, this message translates to:
  /// **'Grasas'**
  String get homeMacroFat;

  /// Training screen title
  ///
  /// In es, this message translates to:
  /// **'Entrenamiento'**
  String get trainingTitle;

  /// Regenerate plan button
  ///
  /// In es, this message translates to:
  /// **'Regenerar'**
  String get trainingRegenerate;

  /// Empty state title
  ///
  /// In es, this message translates to:
  /// **'Tu plan está siendo preparado'**
  String get trainingEmptyTitle;

  /// Empty state description
  ///
  /// In es, this message translates to:
  /// **'Genera tu primer plan de entrenamiento\npersonalizado con IA'**
  String get trainingEmptyDesc;

  /// Generate plan button
  ///
  /// In es, this message translates to:
  /// **'Generar mi plan'**
  String get trainingGeneratePlan;

  /// Why this distribution label
  ///
  /// In es, this message translates to:
  /// **'POR QUÉ ESTA DISTRIBUCIÓN'**
  String get trainingWhyTitle;

  /// Previous sessions label
  ///
  /// In es, this message translates to:
  /// **'SESIONES ANTERIORES'**
  String get trainingPreviousSessions;

  /// View full history link
  ///
  /// In es, this message translates to:
  /// **'Ver todo el historial'**
  String get trainingViewHistory;

  /// Generate new plan button
  ///
  /// In es, this message translates to:
  /// **'Generar nuevo plan'**
  String get trainingNewPlan;

  /// Full history label
  ///
  /// In es, this message translates to:
  /// **'HISTORIAL COMPLETO'**
  String get trainingFullHistory;

  /// Gym type label
  ///
  /// In es, this message translates to:
  /// **'GIMNASIO'**
  String get trainingTypeGym;

  /// Sport type label
  ///
  /// In es, this message translates to:
  /// **'DEPORTE'**
  String get trainingTypeSport;

  /// Rest type label
  ///
  /// In es, this message translates to:
  /// **'DESCANSO'**
  String get trainingTypeRest;

  /// Exercise count
  ///
  /// In es, this message translates to:
  /// **'{count} ejercicios'**
  String trainingExercises(int count);

  /// No series registered
  ///
  /// In es, this message translates to:
  /// **'Sin series registradas'**
  String get trainingNoSeries;

  /// Start session button in detail
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get sessionStartButton;

  /// Why today section title
  ///
  /// In es, this message translates to:
  /// **'Por qué hoy'**
  String get sessionWhyToday;

  /// Objectives section label
  ///
  /// In es, this message translates to:
  /// **'OBJETIVOS'**
  String get sessionObjectives;

  /// Exercises section label
  ///
  /// In es, this message translates to:
  /// **'EJERCICIOS'**
  String get sessionExercises;

  /// Nutrition screen title
  ///
  /// In es, this message translates to:
  /// **'Nutrición'**
  String get nutritionTitle;

  /// Today tab
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get nutritionTabToday;

  /// Week tab
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get nutritionTabWeek;

  /// Shopping tab
  ///
  /// In es, this message translates to:
  /// **'Compra'**
  String get nutritionTabShop;

  /// Regenerate nutrition plan
  ///
  /// In es, this message translates to:
  /// **'Regenerar'**
  String get nutritionRegenerate;

  /// Macros button
  ///
  /// In es, this message translates to:
  /// **'Macros'**
  String get nutritionMacros;

  /// Empty nutrition plan title
  ///
  /// In es, this message translates to:
  /// **'Tu plan de nutrición'**
  String get nutritionEmptyTitle;

  /// Empty nutrition plan subtitle
  ///
  /// In es, this message translates to:
  /// **'está siendo preparado'**
  String get nutritionEmptySubtitle;

  /// Empty nutrition plan description
  ///
  /// In es, this message translates to:
  /// **'Genera tu plan nutricional personalizado con IA para alcanzar tus objetivos'**
  String get nutritionEmptyDesc;

  /// Generate nutrition plan button
  ///
  /// In es, this message translates to:
  /// **'Generar plan nutricional'**
  String get nutritionGeneratePlan;

  /// Monday
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get nutritionDayMon;

  /// Tuesday
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get nutritionDayTue;

  /// Wednesday
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get nutritionDayWed;

  /// Thursday
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get nutritionDayThu;

  /// Friday
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get nutritionDayFri;

  /// Saturday
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get nutritionDaySat;

  /// Sunday
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get nutritionDaySun;

  /// Today badge in week view
  ///
  /// In es, this message translates to:
  /// **'HOY'**
  String get nutritionToday;

  /// Shopping list title
  ///
  /// In es, this message translates to:
  /// **'Lista de la compra'**
  String get nutritionShopTitle;

  /// Shopping list empty message
  ///
  /// In es, this message translates to:
  /// **'Genera tu lista de la compra semanal con IA'**
  String get nutritionShopEmpty;

  /// Generate shopping list button
  ///
  /// In es, this message translates to:
  /// **'Generar lista'**
  String get nutritionShopGenerate;

  /// Generating shopping list
  ///
  /// In es, this message translates to:
  /// **'Generando lista...'**
  String get nutritionShopGenerating;

  /// Shopping list progress
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} items'**
  String nutritionShopProgress(int done, int total);

  /// Ingredients section label
  ///
  /// In es, this message translates to:
  /// **'INGREDIENTES'**
  String get nutritionIngredients;

  /// Preparation section label
  ///
  /// In es, this message translates to:
  /// **'PREPARACIÓN'**
  String get nutritionPreparation;

  /// Mark meal as done button
  ///
  /// In es, this message translates to:
  /// **'Marcar como completada'**
  String get nutritionMarkDone;

  /// Meal completed button state
  ///
  /// In es, this message translates to:
  /// **'Completada ✓'**
  String get nutritionMarkCompleted;

  /// Chat welcome line 1
  ///
  /// In es, this message translates to:
  /// **'¿En qué puedo'**
  String get chatWelcomeLine1;

  /// Chat welcome line 2
  ///
  /// In es, this message translates to:
  /// **'ayudarte hoy?'**
  String get chatWelcomeLine2;

  /// Chat welcome greeting with name
  ///
  /// In es, this message translates to:
  /// **'Hola {name}, soy tu entrenador personal'**
  String chatWelcomeGreeting(String name);

  /// Chat welcome greeting anonymous
  ///
  /// In es, this message translates to:
  /// **'Hola, soy tu entrenador personal'**
  String get chatWelcomeGreetingAnon;

  /// Chat input hint text
  ///
  /// In es, this message translates to:
  /// **'Escribe tu pregunta...'**
  String get chatInputHint;

  /// Profile screen title
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// Personal data section
  ///
  /// In es, this message translates to:
  /// **'DATOS PERSONALES'**
  String get profileSectionPersonal;

  /// Settings section
  ///
  /// In es, this message translates to:
  /// **'AJUSTES'**
  String get profileSectionSettings;

  /// Language setting label
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get profileLanguage;

  /// Logout button
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileLogout;

  /// Weight evolution section
  ///
  /// In es, this message translates to:
  /// **'EVOLUCIÓN DE PESO'**
  String get profileWeightSection;

  /// Register weight button
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get profileWeightRegister;

  /// Weight modal title
  ///
  /// In es, this message translates to:
  /// **'Registrar peso'**
  String get profileWeightModalTitle;

  /// Weight notes hint
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get profileWeightNotesHint;

  /// No weight data message
  ///
  /// In es, this message translates to:
  /// **'Registra tu peso para ver la evolución'**
  String get profileWeightNoData;

  /// Last weight entry label
  ///
  /// In es, this message translates to:
  /// **'Último registro'**
  String get profileWeightLastLabel;

  /// Weight delta message
  ///
  /// In es, this message translates to:
  /// **'{delta} kg desde el anterior'**
  String profileWeightDelta(String delta);

  /// Loading phase 0 text
  ///
  /// In es, this message translates to:
  /// **'Analizando tu perfil...'**
  String get onboardingLoadingPhase0;

  /// Loading phase 1 text
  ///
  /// In es, this message translates to:
  /// **'Creando tu plan personalizado...'**
  String get onboardingLoadingPhase1;

  /// Loading done title
  ///
  /// In es, this message translates to:
  /// **'¡Listo, {name}!'**
  String onboardingLoadingDone(String name);

  /// Plan ready subtitle
  ///
  /// In es, this message translates to:
  /// **'Tu plan está preparado'**
  String get onboardingLoadingPlanReady;

  /// Progress photos section label
  ///
  /// In es, this message translates to:
  /// **'FOTOS DE PROGRESO'**
  String get profilePhotosSection;

  /// Add photo button
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get profilePhotosAdd;

  /// Empty photos state message
  ///
  /// In es, this message translates to:
  /// **'Añade tu primera foto\npara ver tu evolución'**
  String get profilePhotosEmpty;

  /// Compare photos button
  ///
  /// In es, this message translates to:
  /// **'Comparar'**
  String get profilePhotosCompare;

  /// Camera source option
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get profilePhotosCamera;

  /// Gallery source option
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get profilePhotosGallery;

  /// Photo notes field hint
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get profilePhotosNotesHint;

  /// Photo weight field hint
  ///
  /// In es, this message translates to:
  /// **'Peso en esta foto, ej: 75.5'**
  String get profilePhotosWeightHint;

  /// Upload photo button
  ///
  /// In es, this message translates to:
  /// **'Subir foto'**
  String get profilePhotosUploadButton;

  /// Uploading state label
  ///
  /// In es, this message translates to:
  /// **'Subiendo...'**
  String get profilePhotosUploading;

  /// Delete photo confirmation title
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar esta foto?'**
  String get profilePhotosDeleteConfirm;

  /// Delete photo confirmation message
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer'**
  String get profilePhotosDeleteMessage;

  /// Delete button
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get profilePhotosDelete;

  /// Comparison sheet title
  ///
  /// In es, this message translates to:
  /// **'Comparativa de progreso'**
  String get profilePhotosCompareTitle;

  /// First photo label in comparison
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get profilePhotosFirst;

  /// Latest photo label in comparison
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get profilePhotosLatest;

  /// Photo saved snackbar message
  ///
  /// In es, this message translates to:
  /// **'Foto guardada'**
  String get profilePhotosSaved;

  /// Photo deleted snackbar message
  ///
  /// In es, this message translates to:
  /// **'Foto eliminada'**
  String get profilePhotosDeleted;

  /// Upload error snackbar message
  ///
  /// In es, this message translates to:
  /// **'Error al subir la foto'**
  String get profilePhotosErrorUpload;

  /// Weight delta in comparison
  ///
  /// In es, this message translates to:
  /// **'{delta} kg de diferencia'**
  String profilePhotosWeightDelta(String delta);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
