// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTagline => 'Tu entrenador personal con IA';

  @override
  String get navHome => 'Inicio';

  @override
  String get navTraining => 'Entreno';

  @override
  String get navNutrition => 'Nutrición';

  @override
  String get navChat => 'Chat';

  @override
  String get loginTitle => 'Bienvenido';

  @override
  String get loginSubtitle => 'Inicia sesión para continuar';

  @override
  String get loginEmailHint => 'Correo electrónico';

  @override
  String get loginPasswordHint => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginCreateAccount => 'Crear cuenta nueva';

  @override
  String get loginRecoverTitle => 'Recuperar contraseña';

  @override
  String get loginRecoverSent =>
      'Email de recuperación enviado. Revisa tu bandeja.';

  @override
  String get loginRecoverError => 'No se pudo enviar el email de recuperación';

  @override
  String get loginError => 'Error al iniciar sesión';

  @override
  String get cancel => 'Cancelar';

  @override
  String get send => 'Enviar';

  @override
  String get save => 'Guardar';

  @override
  String get or => 'o';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerSubtitle => 'Empieza tu transformación hoy';

  @override
  String get registerNameHint => 'Nombre completo';

  @override
  String get registerConfirmPasswordHint => 'Confirmar contraseña';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get registerTerms => 'Al registrarte aceptas nuestros\n';

  @override
  String get registerTermsLink => 'Términos y condiciones';

  @override
  String get registerError => 'Error al crear la cuenta';

  @override
  String get validateEmail => 'Ingresa tu correo';

  @override
  String get validateEmailFormat => 'Formato de correo no válido';

  @override
  String get validatePassword => 'Ingresa tu contraseña';

  @override
  String get validatePasswordLength => 'Mínimo 8 caracteres';

  @override
  String get validateConfirmPassword => 'Confirma tu contraseña';

  @override
  String get validatePasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get validateName => 'Ingresa tu nombre';

  @override
  String homeHello(String name) {
    return 'Hola, $name';
  }

  @override
  String homeStreak(int days) {
    return '🔥 $days días';
  }

  @override
  String homeHeroTag(String category) {
    return 'HOY · $category';
  }

  @override
  String get homeRestMessage => 'El descanso es parte del entrenamiento';

  @override
  String get homeStartSession => 'Iniciar sesión';

  @override
  String get homeViewFullPlan => 'Ver plan completo';

  @override
  String get homeCaloriesToday => 'Calorías hoy';

  @override
  String get homeNextMeal => 'Próxima comida';

  @override
  String get homePlanCompleted => 'Plan completado';

  @override
  String get homeCurrentWeight => 'Peso actual';

  @override
  String get homeWeightFromProfile => 'desde el perfil';

  @override
  String get homeSleepLabel => 'Sueño anoche';

  @override
  String get homeSleepQuestion => '¿Cuánto dormiste?';

  @override
  String get homeSleepRegister => 'Registrar';

  @override
  String get homeSleepHours => 'Horas de sueño';

  @override
  String get homeWeekLabel => 'SEMANA ACTUAL';

  @override
  String get homeMacrosLabel => 'MACROS DE HOY';

  @override
  String get homeNoPlan => 'Sin plan';

  @override
  String get homeNoPlanActive => 'Sin plan activo';

  @override
  String get homeGeneratingAI => 'Generando plan con IA...';

  @override
  String get homeGeneratePlan => 'Generar mi plan';

  @override
  String get homeGeneratePlanDesc =>
      'Genera tu plan de entrenamiento personalizado con IA';

  @override
  String get homeCoach => 'Entrenador FitCoach';

  @override
  String get homeNoPlanQuestion => '¿Tienes alguna duda sobre tu plan?';

  @override
  String get homeRestQuestion => '¿Cómo te has recuperado hoy?';

  @override
  String homeReadyQuestion(String sport) {
    return '¿Listo para tu sesión de $sport?';
  }

  @override
  String homeCaloriesOf(int consumed, int goal) {
    return '$consumed de $goal kcal';
  }

  @override
  String get homeMacroProtein => 'Proteína';

  @override
  String get homeMacroCarbs => 'Carbos';

  @override
  String get homeMacroFat => 'Grasas';

  @override
  String get trainingTitle => 'Entrenamiento';

  @override
  String get trainingRegenerate => 'Regenerar';

  @override
  String get trainingEmptyTitle => 'Tu plan está siendo preparado';

  @override
  String get trainingEmptyDesc =>
      'Genera tu primer plan de entrenamiento\npersonalizado con IA';

  @override
  String get trainingGeneratePlan => 'Generar mi plan';

  @override
  String get trainingWhyTitle => 'POR QUÉ ESTA DISTRIBUCIÓN';

  @override
  String get trainingPreviousSessions => 'SESIONES ANTERIORES';

  @override
  String get trainingViewHistory => 'Ver todo el historial';

  @override
  String get trainingNewPlan => 'Generar nuevo plan';

  @override
  String get trainingFullHistory => 'HISTORIAL COMPLETO';

  @override
  String get trainingTypeGym => 'GIMNASIO';

  @override
  String get trainingTypeSport => 'DEPORTE';

  @override
  String get trainingTypeRest => 'DESCANSO';

  @override
  String trainingExercises(int count) {
    return '$count ejercicios';
  }

  @override
  String get trainingNoSeries => 'Sin series registradas';

  @override
  String get sessionStartButton => 'Iniciar sesión';

  @override
  String get sessionWhyToday => 'Por qué hoy';

  @override
  String get sessionObjectives => 'OBJETIVOS';

  @override
  String get sessionExercises => 'EJERCICIOS';

  @override
  String get nutritionTitle => 'Nutrición';

  @override
  String get nutritionTabToday => 'Hoy';

  @override
  String get nutritionTabWeek => 'Semana';

  @override
  String get nutritionTabShop => 'Compra';

  @override
  String get nutritionRegenerate => 'Regenerar';

  @override
  String get nutritionMacros => 'Macros';

  @override
  String get nutritionEmptyTitle => 'Tu plan de nutrición';

  @override
  String get nutritionEmptySubtitle => 'está siendo preparado';

  @override
  String get nutritionEmptyDesc =>
      'Genera tu plan nutricional personalizado con IA para alcanzar tus objetivos';

  @override
  String get nutritionGeneratePlan => 'Generar plan nutricional';

  @override
  String get nutritionDayMon => 'Lunes';

  @override
  String get nutritionDayTue => 'Martes';

  @override
  String get nutritionDayWed => 'Miércoles';

  @override
  String get nutritionDayThu => 'Jueves';

  @override
  String get nutritionDayFri => 'Viernes';

  @override
  String get nutritionDaySat => 'Sábado';

  @override
  String get nutritionDaySun => 'Domingo';

  @override
  String get nutritionToday => 'HOY';

  @override
  String get nutritionShopTitle => 'Lista de la compra';

  @override
  String get nutritionShopEmpty =>
      'Genera tu lista de la compra semanal con IA';

  @override
  String get nutritionShopGenerate => 'Generar lista';

  @override
  String get nutritionShopGenerating => 'Generando lista...';

  @override
  String nutritionShopProgress(int done, int total) {
    return '$done de $total items';
  }

  @override
  String get nutritionIngredients => 'INGREDIENTES';

  @override
  String get nutritionPreparation => 'PREPARACIÓN';

  @override
  String get nutritionMarkDone => 'Marcar como completada';

  @override
  String get nutritionMarkCompleted => 'Completada ✓';

  @override
  String get chatWelcomeLine1 => '¿En qué puedo';

  @override
  String get chatWelcomeLine2 => 'ayudarte hoy?';

  @override
  String chatWelcomeGreeting(String name) {
    return 'Hola $name, soy tu entrenador personal';
  }

  @override
  String get chatWelcomeGreetingAnon => 'Hola, soy tu entrenador personal';

  @override
  String get chatInputHint => 'Escribe tu pregunta...';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSectionPersonal => 'DATOS PERSONALES';

  @override
  String get profileSectionSettings => 'AJUSTES';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileWeightSection => 'EVOLUCIÓN DE PESO';

  @override
  String get profileWeightRegister => 'Registrar';

  @override
  String get profileWeightModalTitle => 'Registrar peso';

  @override
  String get profileWeightNotesHint => 'Notas (opcional)';

  @override
  String get profileWeightNoData => 'Registra tu peso para ver la evolución';

  @override
  String get profileWeightLastLabel => 'Último registro';

  @override
  String profileWeightDelta(String delta) {
    return '$delta kg desde el anterior';
  }

  @override
  String get onboardingLoadingPhase0 => 'Analizando tu perfil...';

  @override
  String get onboardingLoadingPhase1 => 'Creando tu plan personalizado...';

  @override
  String onboardingLoadingDone(String name) {
    return '¡Listo, $name!';
  }

  @override
  String get onboardingLoadingPlanReady => 'Tu plan está preparado';

  @override
  String get profilePhotosSection => 'FOTOS DE PROGRESO';

  @override
  String get profilePhotosAdd => 'Añadir';

  @override
  String get profilePhotosEmpty =>
      'Añade tu primera foto\npara ver tu evolución';

  @override
  String get profilePhotosCompare => 'Comparar';

  @override
  String get profilePhotosCamera => 'Cámara';

  @override
  String get profilePhotosGallery => 'Galería';

  @override
  String get profilePhotosNotesHint => 'Notas (opcional)';

  @override
  String get profilePhotosWeightHint => 'Peso en esta foto, ej: 75.5';

  @override
  String get profilePhotosUploadButton => 'Subir foto';

  @override
  String get profilePhotosUploading => 'Subiendo...';

  @override
  String get profilePhotosDeleteConfirm => '¿Eliminar esta foto?';

  @override
  String get profilePhotosDeleteMessage => 'Esta acción no se puede deshacer';

  @override
  String get profilePhotosDelete => 'Eliminar';

  @override
  String get profilePhotosCompareTitle => 'Comparativa de progreso';

  @override
  String get profilePhotosFirst => 'Inicio';

  @override
  String get profilePhotosLatest => 'Ahora';

  @override
  String get profilePhotosSaved => 'Foto guardada';

  @override
  String get profilePhotosDeleted => 'Foto eliminada';

  @override
  String get profilePhotosErrorUpload => 'Error al subir la foto';

  @override
  String profilePhotosWeightDelta(String delta) {
    return '$delta kg de diferencia';
  }
}
