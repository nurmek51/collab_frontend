/// Application constants matching backend API specifications
import '../config/app_config.dart';

class AppConstants {
  AppConstants._();

  // API Base URL
  static String get baseUrl => AppConfig.baseUrl;
  static const String apiVersion = 'v1';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String clientOnboardingCompletedKey =
      'client_onboarding_completed';

  // Routes
  static const String clientOnboardingRoutePath = '/client-onboarding';
  static const String myOrdersRoutePath = '/my-orders';

  // Design
  static const double mobileBreakpoint = 440.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int maxNameLength = 50;
  static const int maxEmailLength = 254;
  static const int minPasswordLength = 8;
  static const int otpLength = 4;

  // File upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  // Retry configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Token refresh
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Specializations as defined in the backend API
  static const List<String> specializations = [
    // Marketing & Management
    'marketer',
    'digital_marketer',
    'account_manager',
    'smm_manager',

    // Design
    'graphic_designer',
    'ui_ux_designer',
    'motion_designer',

    // Development
    'web_developer',
    'frontend_developer',
    'frontend_development',
    'backend_developer',
    'backend_development',
    'fullstack_development',
    'mobile_development',
    'devops_engineering',
    'data_science',
    'ai_ml',

    // Content & Writing
    'copywriter',
    'translator_kazakh',

    // Analytics & Data
    'digital_analyst',
    'data_analyst',

    // Product Management
    'product_manager',
    'project_management',

    // Other
    'other',
  ];

  // Skill levels as defined in the backend API
  static const List<String> skillLevels = [
    'entry', // 0-1 years
    'junior', // 1-3 years
    'middle', // 3-5 years
    'senior', // 5+ years
    'expert', // 10+ years
  ];

  // User roles
  static const List<String> userRoles = ['client', 'freelancer', 'admin'];

  // Order statuses
  static const List<String> orderStatuses = [
    'draft', // pending admin review
    'published', // visible to freelancers
    'created', // freelancer assigned
    'in_progress', // work in progress
    'submitted', // work submitted
    'completed', // work completed and approved
  ];

  // Application statuses
  static const List<String> applicationStatuses = [
    'pending',
    'accepted',
    'rejected',
  ];

  // Payment types
  static const List<String> paymentTypes = ['hourly', 'fixed'];

  // Freelancer profile statuses
  static const List<String> freelancerStatuses = [
    'incomplete',
    'pending',
    'approved',
    'rejected',
  ];

  // Human-readable labels for specializations
  static const Map<String, String> specializationLabels = {
    // Marketing & Management
    'marketer': 'Marketer',
    'digital_marketer': 'Digital Marketer',
    'account_manager': 'Account Manager',
    'smm_manager': 'SMM Manager',

    // Design
    'graphic_designer': 'Graphic Designer',
    'ui_ux_designer': 'UI/UX Designer',
    'motion_designer': 'Motion Designer',

    // Development
    'web_developer': 'Web Developer',
    'frontend_developer': 'Frontend Developer',
    'frontend_development': 'Frontend Development',
    'backend_developer': 'Backend Developer',
    'backend_development': 'Backend Development',
    'fullstack_development': 'Fullstack Development',
    'mobile_development': 'Mobile Development',
    'devops_engineering': 'DevOps Engineering',
    'data_science': 'Data Science',
    'ai_ml': 'AI/ML',

    // Content & Writing
    'copywriter': 'Copywriter',
    'translator_kazakh': 'Kazakh Translator',

    // Analytics & Data
    'digital_analyst': 'Digital Analyst',
    'data_analyst': 'Data Analyst',

    // Product Management
    'product_manager': 'Product Manager',
    'project_management': 'Project Management',

    // Other
    'other': 'Other',
  };

  // Human-readable labels for skill levels
  static const Map<String, String> skillLevelLabels = {
    'entry': 'Entry Level (0-1 years)',
    'junior': 'Junior (1-3 years)',
    'middle': 'Middle (3-5 years)',
    'senior': 'Senior (5+ years)',
    'expert': 'Expert (10+ years)',
  };

  // Human-readable labels for user roles
  static const Map<String, String> roleLabels = {
    'client': 'Client',
    'freelancer': 'Freelancer',
    'admin': 'Administrator',
  };

  // Cities in Kazakhstan (commonly used)
  static const List<String> kazakhstanCities = [
    'Almaty',
    'Nur-Sultan',
    'Shymkent',
    'Aktobe',
    'Taraz',
    'Pavlodar',
    'Ust-Kamenogorsk',
    'Semey',
    'Aktau',
    'Kostanay',
    'Kyzylorda',
    'Oral',
    'Petropavl',
    'Temirtau',
    'Turkestan',
    'Karaganda',
    'Atyrau',
  ];

  // Rate limits
  static const int otpRequestLimit = 50; // per hour
  static const int failedLoginAttemptsLimit = 5;

  // Token refresh settings
  static const int tokenRefreshThresholdSeconds = 300; // 5 minutes
  static const int backgroundRefreshIntervalSeconds = 1800; // 30 minutes
}

/// Helper extensions for working with constants
extension SpecializationExtension on String {
  String get specializationLabel =>
      AppConstants.specializationLabels[this] ?? this;
}

extension SkillLevelExtension on String {
  String get skillLevelLabel => AppConstants.skillLevelLabels[this] ?? this;
}

extension RoleExtension on String {
  String get roleLabel => AppConstants.roleLabels[this] ?? this;
}
