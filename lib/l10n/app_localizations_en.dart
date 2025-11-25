// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome_title => 'Work for specialists.\nSpecialists for work';

  @override
  String get welcome_btn_specialist => 'I\'m a specialist';

  @override
  String get welcome_btn_employer => 'I\'m an employer';

  @override
  String get phone_number_btn_send => 'Get code';

  @override
  String get otp_label_resend => 'Didn\'t receive the code?';

  @override
  String get otp_btn_resend => 'Send again';

  @override
  String get freelancer_form_title => 'Tell us about yourself';

  @override
  String get specialization_levels_title => 'What\'s your specialty?';

  @override
  String get specialization_levels_subtitle => 'Choose one or more areas';

  @override
  String get experience_title => 'Tell us about your experience';

  @override
  String get experience_hint_bio => 'Share where you\'ve worked and what you\'re proud of. Feel free to brag — we love good stories!';

  @override
  String get experience_hint_social => 'Links to social media (LinkedIn, Instagram, etc.)';

  @override
  String get experience_hint_portfolio => 'Links to portfolio (Behance, Dribbble, etc.)';

  @override
  String get success_title => 'Thank you, we received your form and are checking it!';

  @override
  String get success_subtitle => 'This usually takes 1–2 days, after which we\'ll contact you.';

  @override
  String get success_btn_edit => 'Edit form';

  @override
  String get orders_empty_state_title => 'No active orders';

  @override
  String get orders_onboarding_step_1 => 'Describe your task or order a callback.\nOur manager will clarify the details.';

  @override
  String get orders_onboarding_step_2 => 'Our manager will clarify the details.';

  @override
  String get orders_onboarding_step_3 => 'We\'ll select a team for your project.';

  @override
  String get orders_onboarding_step_4 => 'We\'ll sign the contract and start working.';

  @override
  String get orders_new_description_hint => 'Briefly describe your task, for example: \n«we need a website to launch a product»';

  @override
  String get orders_waiting_state_title => 'Thank you, order created!';

  @override
  String get orders_waiting_state_subtitle => 'Our manager will contact you within two hours (during business hours)';

  @override
  String get orders_waiting_state_new_button => 'Create another order';

  @override
  String get orders_callback_state_title => 'Callback request received';

  @override
  String get orders_callback_state_subtitle => 'After the call, your projects will appear here. Our manager will call you within two hours (during business hours)';

  @override
  String get orders_callback_accepted_title => 'Callback request received';

  @override
  String get orders_callback_accepted_subtitle => 'Our manager will call you within two hours (during business hours)';

  @override
  String get orders_getting_started_title => 'How to get started:';

  @override
  String get orders_create_order_button => 'Create order';

  @override
  String get orders_help_button => 'Help';

  @override
  String get my_work_active_projects_title => 'Active Projects';

  @override
  String get my_work_active_projects_empty_subtitle => 'No active projects yet. Respond to offers to start working.';

  @override
  String get my_work_responses_title => 'Responses';

  @override
  String get callback_success_title => 'Done!';

  @override
  String get callback_success_subtitle => 'You have successfully responded to the offer. You can track the status in the \'My Work\' section.';

  @override
  String get callback_success_button => 'Check Status';
}
