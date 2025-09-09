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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar Converter'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @todayGregorianTitle.
  ///
  /// In en, this message translates to:
  /// **'Gregorian Date'**
  String get todayGregorianTitle;

  /// No description provided for @todayHijriTitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date'**
  String get todayHijriTitle;

  /// No description provided for @convertFromGregorian.
  ///
  /// In en, this message translates to:
  /// **'Convert from Gregorian'**
  String get convertFromGregorian;

  /// No description provided for @convertFromHijri.
  ///
  /// In en, this message translates to:
  /// **'Convert from Hijri'**
  String get convertFromHijri;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @moreButton.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreButton;

  /// No description provided for @watchAdReward.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad to Earn Reward'**
  String get watchAdReward;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri & Gregorian date conversion'**
  String get appSubtitle;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Date Converter'**
  String get app_name;

  /// No description provided for @noteAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Dates may not be 100% accurate.'**
  String get noteAccuracy;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// No description provided for @resultWeekday.
  ///
  /// In en, this message translates to:
  /// **'Weekday'**
  String get resultWeekday;

  /// No description provided for @resultHijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get resultHijri;

  /// No description provided for @resultGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get resultGregorian;

  /// No description provided for @occasion.
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get occasion;

  /// No description provided for @selectAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please select day, month, and year.'**
  String get selectAllFields;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversion Result'**
  String get resultTitle;

  /// No description provided for @todayWord.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayWord;

  /// No description provided for @hijriNewYear.
  ///
  /// In en, this message translates to:
  /// **'Hijri New Year'**
  String get hijriNewYear;

  /// No description provided for @hijriAshura.
  ///
  /// In en, this message translates to:
  /// **'Ashura'**
  String get hijriAshura;

  /// No description provided for @hijriArbaeen.
  ///
  /// In en, this message translates to:
  /// **'Arbaeen of Imam Hussein'**
  String get hijriArbaeen;

  /// No description provided for @hijriProphetDeath.
  ///
  /// In en, this message translates to:
  /// **'Prophet Muhammad\'s Death'**
  String get hijriProphetDeath;

  /// No description provided for @hijriProphetBirthday.
  ///
  /// In en, this message translates to:
  /// **'Prophet Muhammad\'s Birthday'**
  String get hijriProphetBirthday;

  /// No description provided for @hijriAliBirthday.
  ///
  /// In en, this message translates to:
  /// **'Imam Ali\'s Birthday'**
  String get hijriAliBirthday;

  /// No description provided for @hijriIsraMiraj.
  ///
  /// In en, this message translates to:
  /// **'Isra and Mi\'raj / Mab\'ath'**
  String get hijriIsraMiraj;

  /// No description provided for @hijriMidShaban.
  ///
  /// In en, this message translates to:
  /// **'Mid-Sha\'ban Night'**
  String get hijriMidShaban;

  /// No description provided for @hijriRamadanStart.
  ///
  /// In en, this message translates to:
  /// **'Start of Ramadan'**
  String get hijriRamadanStart;

  /// No description provided for @hijriBadr.
  ///
  /// In en, this message translates to:
  /// **'Battle of Badr'**
  String get hijriBadr;

  /// No description provided for @hijriAliMartyrdom.
  ///
  /// In en, this message translates to:
  /// **'Martyrdom of Imam Ali'**
  String get hijriAliMartyrdom;

  /// No description provided for @hijriEidFitr.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr'**
  String get hijriEidFitr;

  /// No description provided for @hijriTarwiyah.
  ///
  /// In en, this message translates to:
  /// **'Day of Tarwiyah'**
  String get hijriTarwiyah;

  /// No description provided for @hijriArafah.
  ///
  /// In en, this message translates to:
  /// **'Day of Arafah'**
  String get hijriArafah;

  /// No description provided for @hijriEidAdha.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Adha'**
  String get hijriEidAdha;

  /// No description provided for @hijriGhadir.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Ghadir'**
  String get hijriGhadir;

  /// No description provided for @gregNewYear.
  ///
  /// In en, this message translates to:
  /// **'New Year\'s Day'**
  String get gregNewYear;

  /// No description provided for @gregEpiphany.
  ///
  /// In en, this message translates to:
  /// **'Epiphany'**
  String get gregEpiphany;

  /// No description provided for @gregOrthodoxChristmas.
  ///
  /// In en, this message translates to:
  /// **'Orthodox Christmas'**
  String get gregOrthodoxChristmas;

  /// No description provided for @gregMartinLutherKingBirthday.
  ///
  /// In en, this message translates to:
  /// **'Martin Luther King Jr. Birthday'**
  String get gregMartinLutherKingBirthday;

  /// No description provided for @gregWorldCancerDay.
  ///
  /// In en, this message translates to:
  /// **'World Cancer Day'**
  String get gregWorldCancerDay;

  /// No description provided for @gregValentinesDay.
  ///
  /// In en, this message translates to:
  /// **'Valentine\'s Day'**
  String get gregValentinesDay;

  /// No description provided for @gregInternationalWomensDay.
  ///
  /// In en, this message translates to:
  /// **'International Women\'s Day'**
  String get gregInternationalWomensDay;

  /// No description provided for @gregEinsteinBirthday.
  ///
  /// In en, this message translates to:
  /// **'Albert Einstein\'s Birthday'**
  String get gregEinsteinBirthday;

  /// No description provided for @gregPoetryDay.
  ///
  /// In en, this message translates to:
  /// **'World Poetry Day'**
  String get gregPoetryDay;

  /// No description provided for @gregAprilFools.
  ///
  /// In en, this message translates to:
  /// **'April Fools\' Day'**
  String get gregAprilFools;

  /// No description provided for @gregWorldHealthDay.
  ///
  /// In en, this message translates to:
  /// **'World Health Day'**
  String get gregWorldHealthDay;

  /// No description provided for @gregBaghdadFall2003.
  ///
  /// In en, this message translates to:
  /// **'Fall of Baghdad (2003)'**
  String get gregBaghdadFall2003;

  /// No description provided for @gregYuriGagarin.
  ///
  /// In en, this message translates to:
  /// **'First Space Flight - Yuri Gagarin'**
  String get gregYuriGagarin;

  /// No description provided for @gregTitanicSinking.
  ///
  /// In en, this message translates to:
  /// **'Titanic Sinking'**
  String get gregTitanicSinking;

  /// No description provided for @gregLaborDay.
  ///
  /// In en, this message translates to:
  /// **'International Workers\' Day'**
  String get gregLaborDay;

  /// No description provided for @gregNakba.
  ///
  /// In en, this message translates to:
  /// **'Nakba Day (Palestine)'**
  String get gregNakba;

  /// No description provided for @gregWorldEnvironmentDay.
  ///
  /// In en, this message translates to:
  /// **'World Environment Day'**
  String get gregWorldEnvironmentDay;

  /// No description provided for @gregWorldMusicDay.
  ///
  /// In en, this message translates to:
  /// **'World Music Day'**
  String get gregWorldMusicDay;

  /// No description provided for @gregUSAIndependence.
  ///
  /// In en, this message translates to:
  /// **'US Independence Day'**
  String get gregUSAIndependence;

  /// No description provided for @gregMoonLanding.
  ///
  /// In en, this message translates to:
  /// **'Moon Landing'**
  String get gregMoonLanding;

  /// No description provided for @gregHiroshima.
  ///
  /// In en, this message translates to:
  /// **'Hiroshima Bombing'**
  String get gregHiroshima;

  /// No description provided for @gregNagasaki.
  ///
  /// In en, this message translates to:
  /// **'Nagasaki Bombing'**
  String get gregNagasaki;

  /// No description provided for @greg9_11.
  ///
  /// In en, this message translates to:
  /// **'September 11 Attacks'**
  String get greg9_11;

  /// No description provided for @gregPeaceDay.
  ///
  /// In en, this message translates to:
  /// **'International Day of Peace'**
  String get gregPeaceDay;

  /// No description provided for @gregElderlyDay.
  ///
  /// In en, this message translates to:
  /// **'International Day of Older Persons'**
  String get gregElderlyDay;

  /// No description provided for @gregSputnik.
  ///
  /// In en, this message translates to:
  /// **'Sputnik Launch'**
  String get gregSputnik;

  /// No description provided for @gregFoodDay.
  ///
  /// In en, this message translates to:
  /// **'World Food Day'**
  String get gregFoodDay;

  /// No description provided for @gregBerlinWallFall.
  ///
  /// In en, this message translates to:
  /// **'Fall of the Berlin Wall'**
  String get gregBerlinWallFall;

  /// No description provided for @gregWW1End.
  ///
  /// In en, this message translates to:
  /// **'End of World War I'**
  String get gregWW1End;

  /// No description provided for @gregWorldAidsDay.
  ///
  /// In en, this message translates to:
  /// **'World AIDS Day'**
  String get gregWorldAidsDay;

  /// No description provided for @gregHumanRightsDay.
  ///
  /// In en, this message translates to:
  /// **'Human Rights Day'**
  String get gregHumanRightsDay;

  /// No description provided for @gregChristmas.
  ///
  /// In en, this message translates to:
  /// **'Christmas'**
  String get gregChristmas;

  /// No description provided for @gregNewYearsEve.
  ///
  /// In en, this message translates to:
  /// **'New Year\'s Eve'**
  String get gregNewYearsEve;
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
      'on GitHub with a reproducible sample app and the gen-l10n