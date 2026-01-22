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

  // Common getters
  String get appName => translate('app_name');
  String get submit => translate('submit');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get approve => translate('approve');
  String get reject => translate('reject');
  String get close => translate('close');
  String get logout => translate('logout');
  String get login => translate('login');
  String get success => translate('success');
  String get error => translate('error');
  String get loading => translate('loading');
  String get noData => translate('no_data');
  String get retry => translate('retry');

  // Navigation
  String get attendance => translate('attendance');
  String get tasks => translate('tasks');
  String get dpr => translate('dpr');
  String get dailyProgress => translate('daily_progress');
  String get materialRequests => translate('material_requests');
  String get dashboard => translate('dashboard');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get invoices => translate('invoices');
  String get projects => translate('projects');
  String get notifications => translate('notifications');

  // Status
  String get pending => translate('pending');
  String get approved => translate('approved');
  String get rejected => translate('rejected');
  String get completed => translate('completed');
  String get inProgress => translate('in_progress');
  String get present => translate('present');
  String get absent => translate('absent');

  // Common fields
  String get date => translate('date');
  String get time => translate('time');
  String get status => translate('status');
  String get name => translate('name');
  String get email => translate('email');
  String get phoneNumber => translate('phone_number');
  String get location => translate('location');
  String get description => translate('description');
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
  'invoices': 'Invoices',
  'projects': 'Projects',
  'notifications': 'Notifications',
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
  'present': 'Present',
  'absent': 'Absent',
  'late': 'Late',
  'on_time': 'On Time',
  'date': 'Date',
  'status': 'Status',
  'time': 'Time',
  'name': 'Name',
  'email': 'Email',
  'location': 'Location',
  'description': 'Description',
  'close': 'Close',
  'success': 'Success',
  'error': 'Error',
  'loading': 'Loading...',
  'no_data': 'No data available',
  'retry': 'Retry',
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
  'invoices': 'चालान',
  'projects': 'परियोजनाएं',
  'notifications': 'सूचनाएं',
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
  'present': 'उपस्थित',
  'absent': 'अनुपस्थित',
  'late': 'देरी',
  'on_time': 'समय पर',
  'date': 'तारीख',
  'status': 'स्थिति',
  'time': 'समय',
  'name': 'नाम',
  'email': 'ईमेल',
  'location': 'स्थान',
  'description': 'विवरण',
  'close': 'बंद करें',
  'success': 'सफलता',
  'error': 'त्रुटि',
  'loading': 'लोड हो रहा है...',
  'no_data': 'कोई डेटा उपलब्ध नहीं',
  'retry': 'पुनः प्रयास करें',
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
  'invoices': 'ஏலளை',
  'projects': 'திட்டங்கள்',
  'notifications': 'அறிவிப்புகள்',
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
  'present': 'நிகழ்பவர்',
  'absent': 'இல்லாத',
  'late': 'தாமதம்',
  'on_time': 'சரியான நேரத்தில்',
  'date': 'தேதி',
  'status': 'நிலை',
  'time': 'நேரம்',
  'name': 'பெயர்',
  'email': 'மின்னஞ்சல்',
  'location': 'இருப்பிடம்',
  'description': 'விளக்கம்',
  'close': 'மூடுக',
  'success': 'வெற்றி',
  'error': 'பிழை',
  'loading': 'ஏற்றம்...',
  'no_data': 'தகவல் கிடைக்கவில்லை',
  'retry': 'மீண்டும் முயற்சி செய்க',
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
  'invoices': 'चलने',
  'projects': 'प्रकल्प',
  'notifications': 'सूचना',
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
  'present': 'उपस्थित',
  'absent': 'अनुपस्थित',
  'late': 'उशीर',
  'on_time': 'वेळेत',
  'date': 'तारीख',
  'status': 'स्थिती',
  'time': 'वेळ',
  'name': 'नाव',
  'email': 'ईमेल',
  'location': 'स्थान',
  'description': 'वर्णन',
  'close': 'बंद करा',
  'success': 'यश',
  'error': 'त्रुटी',
  'loading': 'लोड हो रहे...',
  'no_data': 'कोई डेटा उपलब्ध नहीं है',
  'retry': 'पुन: प्रयास करा',
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
