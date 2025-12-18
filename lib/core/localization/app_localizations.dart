import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'dashboard_title': 'GrinGuide Dashboard',
      'hello': 'Hello',
      'checklist_tab': 'Checklist',
      'vaccine_tab': 'Vaccines',
      'dental_tab': 'Dental',
      'insights_tab': 'Insights',
      'brush_morning': 'Morning Brush ☀️',
      'brush_night': 'Night Brush 🌙',
      'floss_morning': 'Morning Floss 🧵',
      'floss_night': 'Night Floss 🧵',
      'healthy_food': 'Healthy Breakfast 🍎',
      'vaccine_report_tooltip': 'Generate Report',
      'settings_title': 'Settings',
      'add_child': 'Add Child Profile',
      'child_name': 'Child Name',
      'date': 'Date',
      'age_label_birth': 'At Birth',
      'doctor_dialog_title': 'Set Doctor/Clinic',
      'doctor_name_label': "Doctor's Name",
      'save': 'Save',
      'cancel': 'Cancel',
      'pending': 'Pending',
      'done': 'Done',
      'vaccination_record': 'Vaccination Record',
      'daily_checklist_title': 'Daily Checklist',
      'timer': 'Timer ⏳',
      'ask_bot': 'Chatbot 🤖',
      'find_dentist': 'Find Dentist 🦷',
      'find_doc': 'Find Doc 🩺',
      'test_notif': 'Test Notif 🔔',
    },
    'ta': {
      'dashboard_title': 'GrinGuide முகப்பு',
      'hello': 'வணக்கம்',
      'checklist_tab': 'பட்டியல்',
      'vaccine_tab': 'தடுப்பூசி',
      'dental_tab': 'பல் மருத்துவம்',
      'insights_tab': 'தகவல்கள்',
      'brush_morning': 'காலை பல் துலக்குதல் ☀️',
      'brush_night': 'இரவு பல் துலக்குதல் 🌙',
      'floss_morning': 'காலை ஃப்ளோஸ் 🧵',
      'floss_night': 'இரவு ஃப்ளோஸ் 🧵',
      'healthy_food': 'சத்தான காலை உணவு 🍎',
      'vaccine_report_tooltip': 'அறிக்கை உருவாக்கு',
      'settings_title': 'அமைப்புகள்',
      'add_child': 'குழந்தை சேர்க்க',
      'child_name': 'குழந்தை பெயர்',
      'date': 'தேதி',
      'age_label_birth': 'பிறப்பில்',
      'doctor_dialog_title': 'மருத்துவர் பெயர்',
      'doctor_name_label': "மருத்துவர் பெயர்",
      'save': 'சேமி',
      'cancel': 'ரத்து',
      'pending': 'நிலுவையில்',
      'done': 'முடிந்தது',
      'vaccination_record': 'தடுப்பூசி பதிவு',
      'daily_checklist_title': 'தினசரி பட்டியல்',
      'timer': 'டைமர் ⏳',
      'ask_bot': 'சாட்பாட் 🤖',
      'find_dentist': 'பல் மருத்துவர் 🦷',
      'find_doc': 'மருத்துவர் 🩺',
      'test_notif': 'அறிவிப்பு சோதனை 🔔',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ta'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
