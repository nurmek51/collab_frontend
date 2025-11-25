/// Order condition constants and mappings for display translations
class OrderConditionConstants {
  // Pay period translations
  static const Map<String, String> payPerTranslations = {
    'month': 'Месяц',
    'week': 'Неделя',
    'day': 'День',
    'hour': 'Час',
    'project': 'Проект',
  };

  // Schedule type translations
  static const Map<String, String> scheduleTypeTranslations = {
    'full-time': 'Полная занятость',
    'part-time': 'Частичная занятость',
    'contract': 'Контракт',
    'freelance': 'Фриланс',
  };

  // Format type translations
  static const Map<String, String> formatTypeTranslations = {
    'remote': 'Удаленно',
    'office': 'В офисе',
    'hybrid': 'Гибрид',
    'on-site': 'На месте',
  };

  /// Get translated pay period
  static String getPayPerDisplay(String key) {
    return payPerTranslations[key] ?? key;
  }

  /// Get translated schedule type
  static String getScheduleTypeDisplay(String key) {
    return scheduleTypeTranslations[key] ?? key;
  }

  /// Get translated format type
  static String getFormatTypeDisplay(String key) {
    return formatTypeTranslations[key] ?? key;
  }
}
