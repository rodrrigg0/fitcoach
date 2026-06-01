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

  @override
  String get monthJan => 'enero';

  @override
  String get monthFeb => 'febrero';

  @override
  String get monthMar => 'marzo';

  @override
  String get monthApr => 'abril';

  @override
  String get monthMay => 'mayo';

  @override
  String get monthJun => 'junio';

  @override
  String get monthJul => 'julio';

  @override
  String get monthAug => 'agosto';

  @override
  String get monthSep => 'septiembre';

  @override
  String get monthOct => 'octubre';

  @override
  String get monthNov => 'noviembre';

  @override
  String get monthDec => 'diciembre';

  @override
  String get trainingRegenDialogTitle => '¿Regenerar plan?';

  @override
  String get trainingRegenDialogContent =>
      'Ya tienes un plan activo. Regenerarlo consumirá créditos de IA. ¿Estás seguro?';

  @override
  String get nutritionDailyTotals => 'TOTALES DEL DÍA';

  @override
  String get nutritionAdjustMacros => 'Ajustar macros';

  @override
  String get nutritionProtein => 'Proteínas';

  @override
  String get nutritionCarbohydrates => 'Carbohidratos';

  @override
  String nutritionMacroGoalOf(int value) {
    return 'de ${value}g';
  }

  @override
  String get nutritionWarnProtein =>
      'Proteínas por debajo de 1.6g/kg. Puede limitar la recuperación muscular.';

  @override
  String get nutritionWarnCalories =>
      'Total inferior a 1200 kcal. No recomendado sin supervisión médica.';

  @override
  String get nutritionRestoreAuto => 'Restaurar automático';

  @override
  String get nutritionSaveChanges => 'Guardar cambios';

  @override
  String get nutritionGoalsUpdated => 'Objetivos actualizados';

  @override
  String get profileStreakLabel => 'Racha\nactual';

  @override
  String get profileDaysThisWeekLabel => 'Días esta\nsemana';

  @override
  String get profileDaysInAppLabel => 'Días en\nFitCoach';

  @override
  String get profileLabelSport => 'Deporte';

  @override
  String get profileLabelPlace => 'Lugar';

  @override
  String get profileLabelDaysPerWeek => 'Días/semana';

  @override
  String get profileLabelSessionDuration => 'Duración sesión';

  @override
  String get profileLabelDiet => 'Dieta';

  @override
  String get profileLabelUsualSleep => 'Sueño habitual';

  @override
  String get profileMyProfile => 'MI PERFIL';

  @override
  String get profileStatisticsSection => 'ESTADÍSTICAS';

  @override
  String get profileStatStreak => 'Racha actual';

  @override
  String get profileStatDaysTrained => 'Días entrenados esta semana';

  @override
  String get profileStatMemberSince => 'Miembro desde';

  @override
  String get profileWeeklyReportsSection => 'INFORMES SEMANALES';

  @override
  String profileWeekOf(String date) {
    return 'Semana del $date';
  }

  @override
  String profileSessionsCount(int done, int total) {
    return '$done/$total sesiones';
  }

  @override
  String profileAvgEnergy(String energy) {
    return '⌀ $energy energía';
  }

  @override
  String get profileViewReport => 'Ver informe';

  @override
  String profileWeeklyReportTitle(String date) {
    return 'Informe semanal — $date';
  }

  @override
  String get profileReportUnavailable => 'Informe no disponible.';

  @override
  String get profileViewTutorialAgain => 'Ver tutorial de nuevo';

  @override
  String get profileTutorialReset =>
      'Tutorial restablecido. Vuelve al inicio para verlo.';

  @override
  String profileDayCount(int count) {
    return '$count días';
  }

  @override
  String profileHourCount(int count) {
    return '$count horas';
  }

  @override
  String get tutorialNavTitle => 'Navegación principal';

  @override
  String get tutorialNavDesc =>
      'Accede a Inicio, Entrenamiento, Nutrición y Chat desde aquí.';

  @override
  String get tutorialProfileTitle => 'Tu perfil';

  @override
  String get tutorialProfileDesc =>
      'Aquí aparece tu nombre y tu racha de días entrenando. Pulsa el avatar para ver y editar tu perfil completo.';

  @override
  String get tutorialWorkoutTitle => 'Tu entrenamiento de hoy';

  @override
  String get tutorialWorkoutDesc =>
      'Aquí ves la sesión programada. Pulsa \'Iniciar sesión\' para empezar y registrar tus pesos y repeticiones.';

  @override
  String get tutorialMetricsTitle => 'Tus métricas del día';

  @override
  String get tutorialMetricsDesc =>
      'Calorías, próxima comida, peso actual y horas de sueño de un vistazo.';

  @override
  String get tutorialStreakTitle => 'Racha semanal';

  @override
  String get tutorialStreakDesc =>
      'Días entrenados esta semana. ¡Intenta completar todos tus días programados!';

  @override
  String get tutorialMacrosTitle => 'Macros del día';

  @override
  String get tutorialMacrosDesc =>
      'Seguimiento de proteínas, carbohidratos y grasas en tiempo real.';

  @override
  String get tutorialCoachTitle => 'Tu entrenador personal';

  @override
  String get tutorialCoachDesc =>
      'Pulsa el Chat en la barra inferior para hablar con tu entrenador 24h sobre entrenamientos, nutrición, suplementación o cualquier duda.';

  @override
  String chatMessagesRemaining(int count) {
    return '$count mensajes restantes hoy';
  }

  @override
  String get planLoadingReady => '¡Plan listo!';

  @override
  String get trainingLoadPhase0 => 'Analizando tu perfil deportivo...';

  @override
  String get trainingLoadPhase1 => 'Diseñando la periodización...';

  @override
  String get trainingLoadPhase2 => 'Seleccionando ejercicios...';

  @override
  String get trainingLoadPhase3 => 'Optimizando series y repeticiones...';

  @override
  String get loadingLastAdjustments => 'Últimos ajustes...';

  @override
  String get nutritionLoadPhase0 => 'Calculando tus macronutrientes...';

  @override
  String get nutritionLoadPhase1 => 'Planificando menú semanal...';

  @override
  String get nutritionLoadPhase2 => 'Ajustando al presupuesto...';

  @override
  String get nutritionLoadPhase3 => 'Generando lista de la compra...';

  @override
  String get registerTermsAnd => ' y la ';

  @override
  String get registerPrivacyLink => 'Política de privacidad';

  @override
  String get legalTermsTitle => 'Términos y condiciones';

  @override
  String get legalPrivacyTitle => 'Política de privacidad';

  @override
  String get profileSectionLegal => 'LEGAL';

  @override
  String get legalTermsContent =>
      'Última actualización: mayo 2026\n\n1. Descripción del servicio\nFitCoach es una aplicación de asesoramiento deportivo y nutricional basada en inteligencia artificial. El contenido generado no constituye consejo médico profesional y no debe sustituir la consulta con un profesional sanitario cualificado.\n\n2. Responsabilidad médica\nAntes de iniciar cualquier plan de entrenamiento o nutrición, los usuarios con condiciones de salud preexistentes, lesiones o historial médico son responsables de consultar a un médico o especialista.\n\n3. Servicio «tal cual»\nEl servicio se presta «tal cual», sin garantías de ningún tipo. FitCoach no garantiza la exactitud, integridad ni idoneidad de los planes generados para ningún propósito específico.\n\n4. Modificaciones\nFitCoach se reserva el derecho de modificar estos términos en cualquier momento. Se notificará a los usuarios de cambios significativos a través de la aplicación.\n\n5. Plan gratuito\nEl plan gratuito incluye un número limitado de interacciones diarias con la IA. Los límites de uso pueden ajustarse en cualquier momento.\n\n6. Plan premium\nEl plan premium ofrece interacciones ilimitadas. El precio de la suscripción se muestra en la aplicación. Puedes cancelar en cualquier momento; la cancelación surte efecto al final del período de facturación en curso.\n\n7. Aceptación\nAl crear una cuenta confirmas que has leído y aceptas estos Términos y Condiciones.';

  @override
  String get legalPrivacyContent =>
      'Responsable del tratamiento: Rodrigo Bachiller Sanz\nContacto: rodrigobachillersanz@gmail.com\n\n1. Datos recogidos\nDirección de correo electrónico, peso, altura, edad, sexo, deporte, nivel de condición física, lesiones, hábitos de sueño, tipo de dieta, alergias alimentarias, presupuesto, conversaciones del chat con el entrenador IA, registros de entrenamiento e historial de peso.\n\n2. Finalidad\nGenerar planes de entrenamiento y nutrición personalizados adaptados a tu perfil.\n\n3. Base legal\nConsentimiento explícito prestado al registrarte (artículo 6.1.a del RGPD). Los datos relacionados con la salud (lesiones, dieta, alergias) se tratan como categoría especial conforme al artículo 9 del RGPD.\n\n4. Almacenamiento\nTus datos se almacenan en Firebase (servidores de Google Cloud). La política de privacidad de Google aplica al procesamiento a nivel de infraestructura.\n\n5. Período de conservación\nLos datos se conservan mientras la cuenta esté activa. Todos los datos personales se eliminan definitivamente al borrar la cuenta.\n\n6. Terceros\nTus datos no se venden ni comparten con terceros. Un resumen anonimizado de tu perfil se envía a la API de Anthropic únicamente para generar tus planes. Anthropic no almacena estos datos según su política de privacidad.\n\n7. Caché local\nLa aplicación utiliza SharedPreferences para almacenar datos en caché localmente en tu dispositivo por motivos de rendimiento.\n\n8. Tus derechos\nTienes derecho de acceso, rectificación, supresión, portabilidad y oposición al tratamiento de tus datos. Para ejercerlos, contacta en: rodrigobachillersanz@gmail.com';
}
