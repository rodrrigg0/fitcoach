// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Your personal AI trainer';

  @override
  String get navHome => 'Home';

  @override
  String get navTraining => 'Training';

  @override
  String get navNutrition => 'Nutrition';

  @override
  String get navChat => 'Chat';

  @override
  String get loginTitle => 'Welcome';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get loginEmailHint => 'Email address';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get loginCreateAccount => 'Create new account';

  @override
  String get loginRecoverTitle => 'Recover password';

  @override
  String get loginRecoverSent => 'Recovery email sent. Check your inbox.';

  @override
  String get loginRecoverError => 'Could not send recovery email';

  @override
  String get loginError => 'Error signing in';

  @override
  String get cancel => 'Cancel';

  @override
  String get send => 'Send';

  @override
  String get save => 'Save';

  @override
  String get or => 'or';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Start your transformation today';

  @override
  String get registerNameHint => 'Full name';

  @override
  String get registerConfirmPasswordHint => 'Confirm password';

  @override
  String get registerButton => 'Create account';

  @override
  String get registerTerms => 'By registering you accept our\n';

  @override
  String get registerTermsLink => 'Terms and conditions';

  @override
  String get registerError => 'Error creating account';

  @override
  String get validateEmail => 'Enter your email';

  @override
  String get validateEmailFormat => 'Invalid email format';

  @override
  String get validatePassword => 'Enter your password';

  @override
  String get validatePasswordLength => 'Minimum 8 characters';

  @override
  String get validateConfirmPassword => 'Confirm your password';

  @override
  String get validatePasswordMismatch => 'Passwords do not match';

  @override
  String get validateName => 'Enter your name';

  @override
  String homeHello(String name) {
    return 'Hello, $name';
  }

  @override
  String homeStreak(int days) {
    return '🔥 $days days';
  }

  @override
  String homeHeroTag(String category) {
    return 'TODAY · $category';
  }

  @override
  String get homeRestMessage => 'Rest is part of training';

  @override
  String get homeStartSession => 'Start session';

  @override
  String get homeViewFullPlan => 'View full plan';

  @override
  String get homeCaloriesToday => 'Calories today';

  @override
  String get homeNextMeal => 'Next meal';

  @override
  String get homePlanCompleted => 'Plan completed';

  @override
  String get homeCurrentWeight => 'Current weight';

  @override
  String get homeWeightFromProfile => 'from profile';

  @override
  String get homeSleepLabel => 'Last night\'s sleep';

  @override
  String get homeSleepQuestion => 'How much did you sleep?';

  @override
  String get homeSleepRegister => 'Log';

  @override
  String get homeSleepHours => 'Sleep hours';

  @override
  String get homeWeekLabel => 'THIS WEEK';

  @override
  String get homeMacrosLabel => 'TODAY\'S MACROS';

  @override
  String get homeNoPlan => 'No plan';

  @override
  String get homeNoPlanActive => 'No active plan';

  @override
  String get homeGeneratingAI => 'Generating plan with AI...';

  @override
  String get homeGeneratePlan => 'Generate my plan';

  @override
  String get homeGeneratePlanDesc =>
      'Generate your personalized training plan with AI';

  @override
  String get homeCoach => 'FitCoach Trainer';

  @override
  String get homeNoPlanQuestion => 'Do you have any questions about your plan?';

  @override
  String get homeRestQuestion => 'How did you recover today?';

  @override
  String homeReadyQuestion(String sport) {
    return 'Ready for your $sport session?';
  }

  @override
  String homeCaloriesOf(int consumed, int goal) {
    return '$consumed of $goal kcal';
  }

  @override
  String get homeMacroProtein => 'Protein';

  @override
  String get homeMacroCarbs => 'Carbs';

  @override
  String get homeMacroFat => 'Fat';

  @override
  String get trainingTitle => 'Training';

  @override
  String get trainingRegenerate => 'Regenerate';

  @override
  String get trainingEmptyTitle => 'Your plan is being prepared';

  @override
  String get trainingEmptyDesc =>
      'Generate your first personalized\ntraining plan with AI';

  @override
  String get trainingGeneratePlan => 'Generate my plan';

  @override
  String get trainingWhyTitle => 'WHY THIS SCHEDULE';

  @override
  String get trainingPreviousSessions => 'PREVIOUS SESSIONS';

  @override
  String get trainingViewHistory => 'View full history';

  @override
  String get trainingNewPlan => 'Generate new plan';

  @override
  String get trainingFullHistory => 'FULL HISTORY';

  @override
  String get trainingTypeGym => 'GYM';

  @override
  String get trainingTypeSport => 'SPORT';

  @override
  String get trainingTypeRest => 'REST';

  @override
  String trainingExercises(int count) {
    return '$count exercises';
  }

  @override
  String get trainingNoSeries => 'No sets recorded';

  @override
  String get sessionStartButton => 'Start session';

  @override
  String get sessionWhyToday => 'Why today';

  @override
  String get sessionObjectives => 'OBJECTIVES';

  @override
  String get sessionExercises => 'EXERCISES';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get nutritionTabToday => 'Today';

  @override
  String get nutritionTabWeek => 'Week';

  @override
  String get nutritionTabShop => 'Shop';

  @override
  String get nutritionRegenerate => 'Regenerate';

  @override
  String get nutritionMacros => 'Macros';

  @override
  String get nutritionEmptyTitle => 'Your nutrition plan';

  @override
  String get nutritionEmptySubtitle => 'is being prepared';

  @override
  String get nutritionEmptyDesc =>
      'Generate your personalized nutrition plan with AI to reach your goals';

  @override
  String get nutritionGeneratePlan => 'Generate nutrition plan';

  @override
  String get nutritionDayMon => 'Monday';

  @override
  String get nutritionDayTue => 'Tuesday';

  @override
  String get nutritionDayWed => 'Wednesday';

  @override
  String get nutritionDayThu => 'Thursday';

  @override
  String get nutritionDayFri => 'Friday';

  @override
  String get nutritionDaySat => 'Saturday';

  @override
  String get nutritionDaySun => 'Sunday';

  @override
  String get nutritionToday => 'TODAY';

  @override
  String get nutritionShopTitle => 'Shopping list';

  @override
  String get nutritionShopEmpty => 'Generate your weekly shopping list with AI';

  @override
  String get nutritionShopGenerate => 'Generate list';

  @override
  String get nutritionShopGenerating => 'Generating list...';

  @override
  String nutritionShopProgress(int done, int total) {
    return '$done of $total items';
  }

  @override
  String get nutritionIngredients => 'INGREDIENTS';

  @override
  String get nutritionPreparation => 'PREPARATION';

  @override
  String get nutritionMarkDone => 'Mark as completed';

  @override
  String get nutritionMarkCompleted => 'Completed ✓';

  @override
  String get chatWelcomeLine1 => 'How can I';

  @override
  String get chatWelcomeLine2 => 'help you today?';

  @override
  String chatWelcomeGreeting(String name) {
    return 'Hi $name, I\'m your personal trainer';
  }

  @override
  String get chatWelcomeGreetingAnon => 'Hi, I\'m your personal trainer';

  @override
  String get chatInputHint => 'Type your question...';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSectionPersonal => 'PERSONAL DATA';

  @override
  String get profileSectionSettings => 'SETTINGS';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileWeightSection => 'WEIGHT EVOLUTION';

  @override
  String get profileWeightRegister => 'Log';

  @override
  String get profileWeightModalTitle => 'Log weight';

  @override
  String get profileWeightNotesHint => 'Notes (optional)';

  @override
  String get profileWeightNoData => 'Log your weight to see evolution';

  @override
  String get profileWeightLastLabel => 'Last entry';

  @override
  String profileWeightDelta(String delta) {
    return '$delta kg since last entry';
  }

  @override
  String get onboardingLoadingPhase0 => 'Analysing your profile...';

  @override
  String get onboardingLoadingPhase1 => 'Creating your personalized plan...';

  @override
  String onboardingLoadingDone(String name) {
    return 'Ready, $name!';
  }

  @override
  String get onboardingLoadingPlanReady => 'Your plan is ready';

  @override
  String get profilePhotosSection => 'PROGRESS PHOTOS';

  @override
  String get profilePhotosAdd => 'Add';

  @override
  String get profilePhotosEmpty =>
      'Add your first photo\nto track your progress';

  @override
  String get profilePhotosCompare => 'Compare';

  @override
  String get profilePhotosCamera => 'Camera';

  @override
  String get profilePhotosGallery => 'Gallery';

  @override
  String get profilePhotosNotesHint => 'Notes (optional)';

  @override
  String get profilePhotosWeightHint => 'Weight in this photo, e.g. 75.5';

  @override
  String get profilePhotosUploadButton => 'Upload photo';

  @override
  String get profilePhotosUploading => 'Uploading...';

  @override
  String get profilePhotosDeleteConfirm => 'Delete this photo?';

  @override
  String get profilePhotosDeleteMessage => 'This action cannot be undone';

  @override
  String get profilePhotosDelete => 'Delete';

  @override
  String get profilePhotosCompareTitle => 'Progress comparison';

  @override
  String get profilePhotosFirst => 'Start';

  @override
  String get profilePhotosLatest => 'Now';

  @override
  String get profilePhotosSaved => 'Photo saved';

  @override
  String get profilePhotosDeleted => 'Photo deleted';

  @override
  String get profilePhotosErrorUpload => 'Error uploading photo';

  @override
  String profilePhotosWeightDelta(String delta) {
    return '$delta kg difference';
  }
}
