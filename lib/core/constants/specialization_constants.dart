/// Specialization constants and mappings
class SpecializationConstants {
  // Map of English keys to Russian display names
  static const Map<String, String> keyToDisplayName = {
    'general_marketer': 'Маркетолог общего профиля',
    'digital_marketer': 'Диджитал Маркетолог / Трафик менеджер',
    'account_manager': 'Аккаунт менеджер / Менеджер проекта',
    'smm_manager': 'СММ менеджер',
    'graphic_designer': 'Дизайнер графический',
    'ui_ux_designer': 'Дизайнер UI/UX',
    'motion_designer': 'Дизайнер Моушн',
    'web_developer': 'Разработчик ВЕБ',
    'frontend_developer': 'Разработчик Фронтенд',
    'backend_developer': 'Разработчик Бэкенд',
    'copywriter': 'Копирайтер',
    'kazakh_translator': 'Переводчик казахский',
    'digital_analyst': 'Диджитал Аналитик',
    'data_analyst': 'Дата Аналитик',
    'product_manager': 'Продакт менеджер',
    'other': 'Другое',
  };

  // Map of Russian display names to English keys
  static const Map<String, String> displayNameToKey = {
    'Маркетолог общего профиля': 'general_marketer',
    'Диджитал Маркетолог / Трафик менеджер': 'digital_marketer',
    'Аккаунт менеджер / Менеджер проекта': 'account_manager',
    'СММ менеджер': 'smm_manager',
    'Дизайнер графический': 'graphic_designer',
    'Дизайнер UI/UX': 'ui_ux_designer',
    'Дизайнер Моушн': 'motion_designer',
    'Разработчик ВЕБ': 'web_developer',
    'Разработчик Фронтенд': 'frontend_developer',
    'Разработчик Бэкенд': 'backend_developer',
    'Копирайтер': 'copywriter',
    'Переводчик казахский': 'kazakh_translator',
    'Диджитал Аналитик': 'digital_analyst',
    'Дата Аналитик': 'data_analyst',
    'Продакт менеджер': 'product_manager',
    'Другое': 'other',
  };

  // Available specializations for selection
  static const List<Map<String, String>> availableSpecializations = [
    {'title': 'Маркетолог общего профиля', 'key': 'general_marketer'},
    {
      'title': 'Диджитал Маркетолог / Трафик менеджер',
      'key': 'digital_marketer',
    },
    {'title': 'Аккаунт менеджер / Менеджер проекта', 'key': 'account_manager'},
    {'title': 'СММ менеджер', 'key': 'smm_manager'},
    {'title': 'Дизайнер графический', 'key': 'graphic_designer'},
    {'title': 'Дизайнер UI/UX', 'key': 'ui_ux_designer'},
    {'title': 'Дизайнер Моушн', 'key': 'motion_designer'},
    {'title': 'Разработчик ВЕБ', 'key': 'web_developer'},
    {'title': 'Разработчик Фронтенд', 'key': 'frontend_developer'},
    {'title': 'Разработчик Бэкенд', 'key': 'backend_developer'},
    {'title': 'Копирайтер', 'key': 'copywriter'},
    {'title': 'Переводчик казахский', 'key': 'kazakh_translator'},
    {'title': 'Диджитал Аналитик', 'key': 'digital_analyst'},
    {'title': 'Дата Аналитик', 'key': 'data_analyst'},
    {'title': 'Продакт менеджер', 'key': 'product_manager'},
    {'title': 'Другое', 'key': 'other'},
  ];

  /// Get English key from Russian display name
  static String getKeyFromDisplayName(String displayName) {
    return displayNameToKey[displayName] ?? displayName;
  }

  /// Get Russian display name from English key
  static String getDisplayNameFromKey(String key) {
    return keyToDisplayName[key] ?? key;
  }

  /// Get specialization title by key (for backward compatibility)
  static String getSpecializationTitle(String key) {
    return getDisplayNameFromKey(key);
  }

  /// Check if a specialization is a standard one (from constants)
  static bool isStandardSpecialization(String specialization) {
    return displayNameToKey.containsKey(specialization);
  }

  /// Get all standard specialization display names
  static Set<String> getAllStandardSpecializations() {
    return displayNameToKey.keys.toSet();
  }
}
