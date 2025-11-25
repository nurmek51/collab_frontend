import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Work for specialists.\nSpecialists for work'**
  String get welcome_title;

  /// No description provided for @welcome_btn_specialist.
  ///
  /// In en, this message translates to:
  /// **'I\'m a specialist'**
  String get welcome_btn_specialist;

  /// No description provided for @welcome_btn_employer.
  ///
  /// In en, this message translates to:
  /// **'I\'m an employer'**
  String get welcome_btn_employer;

  /// No description provided for @phone_number_btn_send.
  ///
  /// In en, this message translates to:
  /// **'Get code'**
  String get phone_number_btn_send;

  /// No description provided for @otp_label_resend.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otp_label_resend;

  /// No description provided for @otp_btn_resend.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get otp_btn_resend;

  /// No description provided for @freelancer_form_title.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get freelancer_form_title;

  /// No description provided for @specialization_levels_title.
  ///
  /// In en, this message translates to:
  /// **'What\'s your specialty?'**
  String get specialization_levels_title;

  /// No description provided for @specialization_levels_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more areas'**
  String get specialization_levels_subtitle;

  /// No description provided for @experience_title.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your experience'**
  String get experience_title;

  /// No description provided for @experience_hint_bio.
  ///
  /// In en, this message translates to:
  /// **'Share where you\'ve worked and what you\'re proud of. Feel free to brag — we love good stories!'**
  String get experience_hint_bio;

  /// No description provided for @experience_hint_social.
  ///
  /// In en, this message translates to:
  /// **'Links to social media (LinkedIn, Instagram, etc.)'**
  String get experience_hint_social;

  /// No description provided for @experience_hint_portfolio.
  ///
  /// In en, this message translates to:
  /// **'Links to portfolio (Behance, Dribbble, etc.)'**
  String get experience_hint_portfolio;

  /// No description provided for @success_title.
  ///
  /// In en, this message translates to:
  /// **'Thank you, we received your form and are checking it!'**
  String get success_title;

  /// No description provided for @success_subtitle.
  ///
  /// In en, this message translates to:
  /// **'This usually takes 1–2 days, after which we\'ll contact you.'**
  String get success_subtitle;

  /// No description provided for @success_btn_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit form'**
  String get success_btn_edit;

  /// No description provided for @orders_empty_state_title.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get orders_empty_state_title;

  /// No description provided for @orders_onboarding_step_1.
  ///
  /// In en, this message translates to:
  /// **'Describe your task or order a callback.\nOur manager will clarify the details.'**
  String get orders_onboarding_step_1;

  /// No description provided for @orders_onboarding_step_2.
  ///
  /// In en, this message translates to:
  /// **'Our manager will clarify the details.'**
  String get orders_onboarding_step_2;

  /// No description provided for @orders_onboarding_step_3.
  ///
  /// In en, this message translates to:
  /// **'We\'ll select a team for your project.'**
  String get orders_onboarding_step_3;

  /// No description provided for @orders_onboarding_step_4.
  ///
  /// In en, this message translates to:
  /// **'We\'ll sign the contract and start working.'**
  String get orders_onboarding_step_4;

  /// No description provided for @orders_new_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe your task, for example: \n«we need a website to launch a product»'**
  String get orders_new_description_hint;

  /// No description provided for @orders_waiting_state_title.
  ///
  /// In en, this message translates to:
  /// **'Thank you, order created!'**
  String get orders_waiting_state_title;

  /// No description provided for @orders_waiting_state_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Our manager will contact you within two hours (during business hours)'**
  String get orders_waiting_state_subtitle;

  /// No description provided for @orders_waiting_state_new_button.
  ///
  /// In en, this message translates to:
  /// **'Create another order'**
  String get orders_waiting_state_new_button;

  /// No description provided for @orders_callback_state_title.
  ///
  /// In en, this message translates to:
  /// **'Callback request received'**
  String get orders_callback_state_title;

  /// No description provided for @orders_callback_state_subtitle.
  ///
  /// In en, this message translates to:
  /// **'After the call, your projects will appear here. Our manager will call you within two hours (during business hours)'**
  String get orders_callback_state_subtitle;

  /// No description provided for @orders_callback_accepted_title.
  ///
  /// In en, this message translates to:
  /// **'Callback request received'**
  String get orders_callback_accepted_title;

  /// No description provided for @orders_callback_accepted_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Our manager will call you within two hours (during business hours)'**
  String get orders_callback_accepted_subtitle;

  /// No description provided for @orders_getting_started_title.
  ///
  /// In en, this message translates to:
  /// **'How to get started:'**
  String get orders_getting_started_title;

  /// No description provided for @orders_create_order_button.
  ///
  /// In en, this message translates to:
  /// **'Create order'**
  String get orders_create_order_button;

  /// No description provided for @orders_help_button.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get orders_help_button;

  /// No description provided for @my_work_active_projects_title.
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get my_work_active_projects_title;

  /// No description provided for @my_work_active_projects_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'No active projects yet. Respond to offers to start working.'**
  String get my_work_active_projects_empty_subtitle;

  /// No description provided for @my_work_responses_title.
  ///
  /// In en, this message translates to:
  /// **'Responses'**
  String get my_work_responses_title;

  /// No description provided for @callback_success_title.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get callback_success_title;

  /// No description provided for @callback_success_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You have successfully responded to the offer. You can track the status in the \'My Work\' section.'**
  String get callback_success_subtitle;

  /// No description provided for @callback_success_button.
  ///
  /// In en, this message translates to:
  /// **'Check Status'**
  String get callback_success_button;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
