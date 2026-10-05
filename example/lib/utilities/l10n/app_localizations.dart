import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @serverErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverErrorTitle;

  /// No description provided for @serverErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong on our end. Please try again later.'**
  String get serverErrorMessage;

  /// No description provided for @unexpectedErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error'**
  String get unexpectedErrorTitle;

  /// No description provided for @unexpectedErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please restart the app and try again.'**
  String get unexpectedErrorMessage;

  /// No description provided for @noDataErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get noDataErrorTitle;

  /// No description provided for @noDataErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any data for you at the moment. Please try again later.'**
  String get noDataErrorMessage;

  /// No description provided for @noNetworkErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'No Network Connection'**
  String get noNetworkErrorTitle;

  /// No description provided for @noNetworkErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'You are not connected to the internet. Please check your connection and try again.'**
  String get noNetworkErrorMessage;

  /// No description provided for @unauthorizedErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorizedErrorTitle;

  /// No description provided for @unauthorizedErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to access this content. Please log in and try again.'**
  String get unauthorizedErrorMessage;

  /// No description provided for @updateRequiredErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredErrorTitle;

  /// No description provided for @updateRequiredErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to continue.'**
  String get updateRequiredErrorMessage;

  /// No description provided for @jailbreakErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Risk Detected'**
  String get jailbreakErrorTitle;

  /// No description provided for @jailbreakErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'\nThis device appears to be jailbroken or compromised.\n\n For your security, the app cannot run on this device.'**
  String get jailbreakErrorMessage;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonViewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get commonViewMore;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get commonSeeAll;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get commonUpdate;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get commonLogout;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get commonOk;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get commonExit;

  /// No description provided for @common_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get common_get_started;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @commonLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get commonLanguage;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_fail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get common_fail;

  /// No description provided for @common_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get common_warning;

  /// No description provided for @common_dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get common_dismiss;

  /// No description provided for @common_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get common_details;

  /// No description provided for @common_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get common_apply;

  /// No description provided for @login_view_login_button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login_view_login_button;

  /// No description provided for @login_view_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get login_view_email_label;

  /// No description provided for @login_view_email_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get login_view_email_placeholder;

  /// No description provided for @login_view_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_view_password_label;

  /// No description provided for @login_view_password_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get login_view_password_placeholder;

  /// No description provided for @login_view_username_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get login_view_username_empty_error;

  /// No description provided for @login_view_email_format_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get login_view_email_format_error;

  /// No description provided for @login_view_password_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get login_view_password_empty_error;

  /// No description provided for @login_view_title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Sign you in'**
  String get login_view_title;

  /// No description provided for @login_view_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Please enter your credentials to access your account'**
  String get login_view_subtitle;

  /// No description provided for @login_view_continue_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Continue as a guest'**
  String get login_view_continue_as_guest;

  /// No description provided for @create_account_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account_title;

  /// No description provided for @create_account_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to get started'**
  String get create_account_subtitle;

  /// No description provided for @login_dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get login_dont_have_account;

  /// No description provided for @login_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get login_sign_up;

  /// No description provided for @create_account_full_name_field.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get create_account_full_name_field;

  /// No description provided for @create_account_full_name_field_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get create_account_full_name_field_placeholder;

  /// No description provided for @create_account_create_account_button_title.
  ///
  /// In en, this message translates to:
  /// **'Create An Account'**
  String get create_account_create_account_button_title;

  /// No description provided for @create_account_login.
  ///
  /// In en, this message translates to:
  /// **'Do you have an account?'**
  String get create_account_login;

  /// No description provided for @create_account_full_name_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Full name cannot be empty'**
  String get create_account_full_name_empty_error;

  /// No description provided for @create_account_success_title.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get create_account_success_title;

  /// No description provided for @create_account_success_message.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully.'**
  String get create_account_success_message;

  /// No description provided for @tab_home_title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tab_home_title;

  /// No description provided for @tab_booking_title.
  ///
  /// In en, this message translates to:
  /// **'My Booking'**
  String get tab_booking_title;

  /// No description provided for @tab_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tab_profile_title;

  /// No description provided for @category_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get category_all;

  /// No description provided for @category_villas.
  ///
  /// In en, this message translates to:
  /// **'Villas'**
  String get category_villas;

  /// No description provided for @category_hotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get category_hotels;

  /// No description provided for @category_apartments.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get category_apartments;

  /// No description provided for @pull_to_refresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pull_to_refresh;

  /// No description provided for @home_popular_section_title.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get home_popular_section_title;

  /// No description provided for @home_recommended_section_title.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get home_recommended_section_title;

  /// No description provided for @common_dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get common_dates;

  /// No description provided for @common_guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get common_guest;

  /// No description provided for @common_guests_singular.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get common_guests_singular;

  /// No description provided for @common_guests_plural.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get common_guests_plural;

  /// No description provided for @common_unknown.
  ///
  /// In en, this message translates to:
  /// **'UnKnown'**
  String get common_unknown;

  /// No description provided for @common_night.
  ///
  /// In en, this message translates to:
  /// **'night'**
  String get common_night;

  /// No description provided for @common_bed.
  ///
  /// In en, this message translates to:
  /// **'bed'**
  String get common_bed;

  /// No description provided for @common_bathroom.
  ///
  /// In en, this message translates to:
  /// **'bathroom'**
  String get common_bathroom;

  /// No description provided for @common_per_night.
  ///
  /// In en, this message translates to:
  /// **'Per Night'**
  String get common_per_night;

  /// No description provided for @log_out_button_title.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get log_out_button_title;

  /// No description provided for @onboarding_title_1.
  ///
  /// In en, this message translates to:
  /// **'Luxury and Comfort, Just a Tap Away'**
  String get onboarding_title_1;

  /// No description provided for @onboarding_subtitle_1.
  ///
  /// In en, this message translates to:
  /// **'Semper in cursus magna et eu varius nunc adipiscing. Elementum justo, laoreet id sem.'**
  String get onboarding_subtitle_1;

  /// No description provided for @onboarding_title_2.
  ///
  /// In en, this message translates to:
  /// **'Book with Ease, Stay with Style'**
  String get onboarding_title_2;

  /// No description provided for @onboarding_subtitle_2.
  ///
  /// In en, this message translates to:
  /// **'Semper in cursus magna et eu varius nunc adipiscing. Elementum justo, laoreet id sem.'**
  String get onboarding_subtitle_2;

  /// No description provided for @onboarding_title_3.
  ///
  /// In en, this message translates to:
  /// **'Discover Your Dream Hotel, Effortlessly'**
  String get onboarding_title_3;

  /// No description provided for @onboarding_subtitle_3.
  ///
  /// In en, this message translates to:
  /// **'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'**
  String get onboarding_subtitle_3;

  /// No description provided for @setting_curent_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get setting_curent_language;

  /// No description provided for @settings_logged_in_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get settings_logged_in_subtitle;

  /// No description provided for @settings_guest_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Register or login to your account'**
  String get settings_guest_subtitle;

  /// No description provided for @settings_logout_confirmation_title.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure?'**
  String get settings_logout_confirmation_title;

  /// No description provided for @settings_logout_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out ?'**
  String get settings_logout_confirmation_message;

  /// No description provided for @settings_login_button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get settings_login_button;

  /// No description provided for @setting_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Theme (Dark)'**
  String get setting_theme_dark;

  /// No description provided for @setting_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Theme (Light)'**
  String get setting_theme_light;

  /// No description provided for @account_info_view_title.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get account_info_view_title;

  /// No description provided for @account_info_first_name_label.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get account_info_first_name_label;

  /// No description provided for @account_info_last_name_label.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get account_info_last_name_label;

  /// No description provided for @account_info_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get account_info_email_label;

  /// No description provided for @account_info_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get account_info_phone_label;

  /// No description provided for @account_info_save_changes_button.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get account_info_save_changes_button;

  /// No description provided for @account_info_first_name_error.
  ///
  /// In en, this message translates to:
  /// **'First name must be at least 3 characters'**
  String get account_info_first_name_error;

  /// No description provided for @account_info_last_name_error.
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least 3 characters'**
  String get account_info_last_name_error;

  /// No description provided for @account_info_phone_error.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Egyptian mobile number (11 digits, starts with 01).'**
  String get account_info_phone_error;

  /// No description provided for @settings_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}'**
  String settings_welcome_title(Object name);

  /// No description provided for @settings_user_placeholder.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get settings_user_placeholder;

  /// No description provided for @search_view_title.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_view_title;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search here...'**
  String get search_hint;

  /// No description provided for @filter_category_title.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filter_category_title;

  /// No description provided for @filter_category_label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filter_category_label;

  /// No description provided for @filter_price_label.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get filter_price_label;

  /// No description provided for @filter_facilities_title.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get filter_facilities_title;

  /// No description provided for @filter_location_title.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filter_location_title;

  /// No description provided for @filter_instant_book_title.
  ///
  /// In en, this message translates to:
  /// **'Instant Book'**
  String get filter_instant_book_title;

  /// No description provided for @filter_instant_book_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Book without waiting for the host to respond'**
  String get filter_instant_book_subtitle;

  /// No description provided for @filter_ratings_title.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get filter_ratings_title;

  /// No description provided for @filter_apply_button.
  ///
  /// In en, this message translates to:
  /// **'Apply filter'**
  String get filter_apply_button;

  /// No description provided for @filter_reset_button.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filter_reset_button;

  /// No description provided for @booking_view_title.
  ///
  /// In en, this message translates to:
  /// **'Request to book'**
  String get booking_view_title;

  /// No description provided for @booking_view_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get booking_view_date;

  /// No description provided for @booking_view_check_in.
  ///
  /// In en, this message translates to:
  /// **'Check - In'**
  String get booking_view_check_in;

  /// No description provided for @booking_view_check_out.
  ///
  /// In en, this message translates to:
  /// **'Check - Out'**
  String get booking_view_check_out;

  /// No description provided for @booking_view_guest_count.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get booking_view_guest_count;

  /// No description provided for @booking_view_payment_details.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get booking_view_payment_details;

  /// No description provided for @booking_view_total_nights.
  ///
  /// In en, this message translates to:
  /// **'Total : {nights} Night'**
  String booking_view_total_nights(Object nights);

  /// No description provided for @booking_view_cleaning_fee.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Fee'**
  String get booking_view_cleaning_fee;

  /// No description provided for @booking_view_service_fee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get booking_view_service_fee;

  /// No description provided for @booking_view_total_payment.
  ///
  /// In en, this message translates to:
  /// **'Total Payment:'**
  String get booking_view_total_payment;

  /// No description provided for @common_checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get common_checkout;

  /// No description provided for @booking_view_select_date_in_title.
  ///
  /// In en, this message translates to:
  /// **'Select Check-In Date'**
  String get booking_view_select_date_in_title;

  /// No description provided for @booking_view_select_date_out_title.
  ///
  /// In en, this message translates to:
  /// **'Select Check-Out Date'**
  String get booking_view_select_date_out_title;

  /// No description provided for @hotel_details_common_facilities.
  ///
  /// In en, this message translates to:
  /// **'Common Facilities'**
  String get hotel_details_common_facilities;

  /// No description provided for @hotel_details_description_title.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get hotel_details_description_title;

  /// No description provided for @hotel_details_read_more.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get hotel_details_read_more;

  /// No description provided for @hotel_details_read_less.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get hotel_details_read_less;

  /// No description provided for @hotel_details_location_title.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get hotel_details_location_title;

  /// No description provided for @hotel_details_open_map.
  ///
  /// In en, this message translates to:
  /// **'Open Map'**
  String get hotel_details_open_map;

  /// No description provided for @hotel_details_booking_price_title.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get hotel_details_booking_price_title;

  /// No description provided for @hotel_details_booking_button_title.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get hotel_details_booking_button_title;

  /// No description provided for @hotel_details_facilities_list_title.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get hotel_details_facilities_list_title;

  /// No description provided for @hotel_details_facilities_count.
  ///
  /// In en, this message translates to:
  /// **'({count} Facilities)'**
  String hotel_details_facilities_count(Object count);

  /// No description provided for @booking_empty_message.
  ///
  /// In en, this message translates to:
  /// **'No bookings found yet'**
  String get booking_empty_message;

  /// No description provided for @booking_test_checkout_button.
  ///
  /// In en, this message translates to:
  /// **'Go to Checkout (Test)'**
  String get booking_test_checkout_button;

  /// No description provided for @checkout_title.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout_title;

  /// No description provided for @checkout_cancel_booking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get checkout_cancel_booking;

  /// No description provided for @checkout_more_options.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get checkout_more_options;

  /// No description provided for @checkout_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Checkout details will appear here'**
  String get checkout_placeholder;

  /// No description provided for @checkout_your_booking.
  ///
  /// In en, this message translates to:
  /// **'Your Booking'**
  String get checkout_your_booking;

  /// No description provided for @checkout_room_type.
  ///
  /// In en, this message translates to:
  /// **'Room type'**
  String get checkout_room_type;

  /// No description provided for @checkout_price_details.
  ///
  /// In en, this message translates to:
  /// **'Price Details'**
  String get checkout_price_details;

  /// No description provided for @checkout_admin_fee.
  ///
  /// In en, this message translates to:
  /// **'Admin fee'**
  String get checkout_admin_fee;

  /// No description provided for @checkout_total_price.
  ///
  /// In en, this message translates to:
  /// **'Total price'**
  String get checkout_total_price;

  /// No description provided for @checkout_default_room_type.
  ///
  /// In en, this message translates to:
  /// **'Queen Room'**
  String get checkout_default_room_type;

  /// No description provided for @checkout_one_room_suffix.
  ///
  /// In en, this message translates to:
  /// **'(1 Room)'**
  String get checkout_one_room_suffix;

  /// No description provided for @checkout_guest_count.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Guest} other{Guests}}'**
  String checkout_guest_count(num count);

  /// No description provided for @checkout_confirm_booking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get checkout_confirm_booking;

  /// No description provided for @checkout_booking_complete.
  ///
  /// In en, this message translates to:
  /// **'Booking Complete'**
  String get checkout_booking_complete;

  /// No description provided for @checkout_booking_complete_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your reservation has been confirmed. You can find all the stay details in your booking list.'**
  String get checkout_booking_complete_subtitle;

  /// No description provided for @checkout_booking_details.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get checkout_booking_details;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @booking_delete_confirmation_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Booking'**
  String get booking_delete_confirmation_title;

  /// No description provided for @booking_delete_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this booking?'**
  String get booking_delete_confirmation_message;

  /// No description provided for @common_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get common_none;

  /// No description provided for @setting_language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get setting_language_en;

  /// No description provided for @setting_language_ar.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get setting_language_ar;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
