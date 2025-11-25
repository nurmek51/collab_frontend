// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get welcome_title => 'Работа для специалистов.\nСпециалисты для работы';

  @override
  String get welcome_btn_specialist => 'Я специалист';

  @override
  String get welcome_btn_employer => 'Я работодатель';

  @override
  String get phone_number_btn_send => 'Получить код';

  @override
  String get otp_label_resend => 'Не пришел код?';

  @override
  String get otp_btn_resend => 'Отправить повторно';

  @override
  String get freelancer_form_title => 'Расскажи о себе';

  @override
  String get specialization_levels_title => 'В чем ты специалист?';

  @override
  String get specialization_levels_subtitle => 'Выбери одно или несколько направлений';

  @override
  String get experience_title => 'Расскажи о своем опыте';

  @override
  String get experience_hint_bio => 'Расскажи, где работал и чем гордишься. Можно похвастаться — мы любим хорошие истории!';

  @override
  String get experience_hint_social => 'Ссылки на соцсети (LinkedIn, Instagram и др.)';

  @override
  String get experience_hint_portfolio => 'Ссылки на портфолио (Behance, Dribbble и др.)';

  @override
  String get success_title => 'Спасибо, мы получили твою анкету и теперь ее проверяем!';

  @override
  String get success_subtitle => 'Обычно это занимает 1–2 дня, после чего мы свяжемся с тобой.';

  @override
  String get success_btn_edit => 'Редактировать анкету';

  @override
  String get orders_empty_state_title => 'Активных заказов нет';

  @override
  String get orders_onboarding_step_1 => 'Опишите задачу или закажите звонок.';

  @override
  String get orders_onboarding_step_2 => 'Наш менеджер уточнит детали.';

  @override
  String get orders_onboarding_step_3 => 'Мы подберём команду под проект.';

  @override
  String get orders_onboarding_step_4 => 'Подпишем договор и начинаем работать.';

  @override
  String get orders_new_description_hint => 'Кратко опишите задачу, например: \n«нужен сайт для запуска продукта»';

  @override
  String get orders_waiting_state_title => 'Спасибо, заказ создан!';

  @override
  String get orders_waiting_state_subtitle => 'Наш менеджер свяжется с вами в течение двух часов (в рабочее время)';

  @override
  String get orders_waiting_state_new_button => 'Создать еще заказ';

  @override
  String get orders_callback_state_title => 'Заявка на звонок принята';

  @override
  String get orders_callback_state_subtitle => 'После звонка здесь появятся ваши проекты. Наш менеджер перезвонит вам в течение двух часов (в рабочее время)';

  @override
  String get orders_callback_accepted_title => 'Заявка на звонок принята';

  @override
  String get orders_callback_accepted_subtitle => 'Наш менеджер перезвонит вам в течение двух часов (в рабочее время)';

  @override
  String get orders_getting_started_title => 'Как начать:';

  @override
  String get orders_create_order_button => 'Создать заказ';

  @override
  String get orders_help_button => 'Помощь';

  @override
  String get my_work_active_projects_title => 'Активные проекты';

  @override
  String get my_work_active_projects_empty_subtitle => 'Пока активных проектов нет. Откликайтесь на офферы, чтобы начать работу.';

  @override
  String get my_work_responses_title => 'Отклики';

  @override
  String get callback_success_title => 'Готово!';

  @override
  String get callback_success_subtitle => 'Вы успешно откликнулись на оффер. Следить за статусом можно в разделе «Моя работа».';

  @override
  String get callback_success_button => 'Проверить статус';
}
