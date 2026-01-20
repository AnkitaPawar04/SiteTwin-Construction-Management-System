import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('hi', 'IN'), // Hindi
    Locale('ta', 'IN'), // Tamil
    Locale('mr', 'IN'), // Marathi
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _en,
    'hi': _hi,
    'ta': _ta,
    'mr': _mr,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Convenience getters
  String get appName => translate('app_name');
  String get attendance => translate('attendance');
  String get tasks => translate('tasks');
  String get dpr => translate('dpr');
  String get dailyProgress => translate('daily_progress');
  String get materialRequests => translate('material_requests');
  String get dashboard => translate('dashboard');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get logout => translate('logout');
  String get login => translate('login');
  String get phoneNumber => translate('phone_number');
  String get enterPhoneNumber => translate('enter_phone_number');
  String get checkIn => translate('check_in');
  String get checkOut => translate('check_out');
  String get submit => translate('submit');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get approve => translate('approve');
  String get reject => translate('reject');
  String get pending => translate('pending');
  String get approved => translate('approved');
  String get rejected => translate('rejected');
  String get completed => translate('completed');
  String get inProgress => translate('in_progress');
  String get confirmLogout => translate('confirm_logout');
  String get areYouSureLogout => translate('are_you_sure_logout');
}

// English translations
const Map<String, String> _en = {
  'app_name': 'Construction Manager',
  'attendance': 'Attendance',
  'tasks': 'Tasks',
  'dpr': 'DPR',
  'daily_progress': 'Daily Progress',
  'material_requests': 'Material Requests',
  'dashboard': 'Dashboard',
  'profile': 'Profile',
  'settings': 'Settings',
  'logout': 'Logout',
  'login': 'Login',
  'phone_number': 'Phone Number',
  'enter_phone_number': 'Enter your 10-digit phone number',
  'check_in': 'Check In',
  'check_out': 'Check Out',
  'submit': 'Submit',
  'cancel': 'Cancel',
  'save': 'Save',
  'delete': 'Delete',
  'edit': 'Edit',
  'approve': 'Approve',
  'reject': 'Reject',
  'pending': 'Pending',
  'approved': 'Approved',
  'rejected': 'Rejected',
  'completed': 'Completed',
  'in_progress': 'In Progress',
  'confirm_logout': 'Confirm Logout',
  'are_you_sure_logout': 'Are you sure you want to logout?',
};

// Hindi translations
const Map<String, String> _hi = {
  'app_name': 'निर्माण प्रबंधक',
  'attendance': 'उपस्थिति',
  'tasks': 'कार्य',
  'dpr': 'डीपीआर',
  'daily_progress': 'दैनिक प्रगति',
  'material_requests': 'सामग्री अनुरोध',
  'dashboard': 'डैशबोर्ड',
  'profile': 'प्रोफ़ाइल',
  'settings': 'सेटिंग्स',
  'logout': 'लॉगआउट',
  'login': 'लॉगिन',
  'phone_number': 'फोन नंबर',
  'enter_phone_number': 'अपना 10 अंकों का फोन नंबर दर्ज करें',
  'check_in': 'चेक इन',
  'check_out': 'चेक आउट',
  'submit': 'जमा करें',
  'cancel': 'रद्द करें',
  'save': 'सहेजें',
  'delete': 'हटाएं',
  'edit': 'संपादित करें',
  'approve': 'स्वीकृत करें',
  'reject': 'अस्वीकार करें',
  'pending': 'लंबित',
  'approved': 'स्वीकृत',
  'rejected': 'अस्वीकृत',
  'completed': 'पूर्ण',
  'in_progress': 'प्रगति में',
  'confirm_logout': 'लॉगआउट की पुष्टि करें',
  'are_you_sure_logout': 'क्या आप निश्चित रूप से लॉगआउट करना चाहते हैं?',
};

// Tamil translations
const Map<String, String> _ta = {
  'app_name': 'கட்டுமான மேலாளர்',
  'attendance': 'வருகைப் பதிவு',
  'tasks': 'பணிகள்',
  'dpr': 'டிபிஆர்',
  'daily_progress': 'தினசரி முன்னேற்றம்',
  'material_requests': 'பொருள் கோரிக்கைகள்',
  'dashboard': 'கட்டுப்பாட்டு பலகை',
  'profile': 'சுயவிவரம்',
  'settings': 'அமைப்புகள்',
  'logout': 'வெளியேறு',
  'login': 'உள்நுழைவு',
  'phone_number': 'தொலைபேசி எண்',
  'enter_phone_number': 'உங்கள் 10 இலக்க தொலைபேசி எண்ணை உள்ளிடவும்',
  'check_in': 'செக் இன்',
  'check_out': 'செக் அவுட்',
  'submit': 'சமர்ப்பிக்கவும்',
  'cancel': 'ரத்துசெய்',
  'save': 'சேமி',
  'delete': 'நீக்கு',
  'edit': 'திருத்து',
  'approve': 'அனுமதி',
  'reject': 'நிராகரி',
  'pending': 'நிலுவை',
  'approved': 'அனுமதிக்கப்பட்டது',
  'rejected': 'நிராகரிக்கப்பட்டது',
  'completed': 'முடிந்தது',
  'in_progress': 'முன்னேற்றத்தில்',
  'confirm_logout': 'வெளியேறுவதை உறுதிப்படுத்தவும்',
  'are_you_sure_logout': 'நீங்கள் உறுதியாக வெளியேற விரும்புகிறீர்களா?',
};

// Marathi translations
const Map<String, String> _mr = {
  'app_name': 'बांधकाम व्यवस्थापक',
  'attendance': 'उपस्थिती',
  'tasks': 'कार्ये',
  'dpr': 'डीपीआर',
  'daily_progress': 'दैनंदिन प्रगती',
  'material_requests': 'साहित्य विनंत्या',
  'dashboard': 'डॅशबोर्ड',
  'profile': 'प्रोफाइल',
  'settings': 'सेटिंग्ज',
  'logout': 'लॉगआउट',
  'login': 'लॉगिन',
  'phone_number': 'फोन नंबर',
  'enter_phone_number': 'तुमचा 10 अंकी फोन नंबर प्रविष्ट करा',
  'check_in': 'चेक इन',
  'check_out': 'चेक आउट',
  'submit': 'सबमिट करा',
  'cancel': 'रद्द करा',
  'save': 'जतन करा',
  'delete': 'हटवा',
  'edit': 'संपादित करा',
  'approve': 'मंजूर करा',
  'reject': 'नाकारा',
  'pending': 'प्रलंबित',
  'approved': 'मंजूर',
  'rejected': 'नाकारले',
  'completed': 'पूर्ण',
  'in_progress': 'प्रगतीपथावर',
  'confirm_logout': 'लॉगआउट पुष्टी करा',
  'are_you_sure_logout': 'तुम्हाला खात्री आहे की तुम्ही लॉगआउट करू इच्छिता?',
};

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'ta', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
