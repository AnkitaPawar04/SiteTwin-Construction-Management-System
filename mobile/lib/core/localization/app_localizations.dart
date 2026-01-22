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
  String get start => translate('start');
  String get end => translate('end');
  String get startDate => translate('start_date');
  String get endDate => translate('end_date');
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
  'assign_task': 'Assign Task',
  'stock_inventory': 'Stock & Inventory',
  'time_vs_cost': 'Time vs Cost Analysis',
  'confirm_logout': 'Confirm Logout',
  'confirm_logout_message': 'Are you sure you want to logout?',
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
  'start': 'Start',
  'end': 'End',
  'start_date': 'Start Date',
  'end_date': 'End Date',
  'coordinates': 'Coordinates',
  'view_on_map': 'View on map',
  'no_projects': 'No projects found',
  'lat_label': 'Lat',
  'lng_label': 'Lng',
  'add_project': 'Add Project',
  'edit_project': 'Edit Project',
  'create_project': 'Create Project',
  'latitude': 'Latitude',
  'longitude': 'Longitude',
  'offline': 'Offline',
  'online': 'Online',
  'checking_connection': 'Checking connection...',
  'close': 'Close',
  'success': 'Success',
  'error': 'Error',
  'loading': 'Loading...',
  'no_data': 'No data available',
  'retry': 'Retry',
  'current_location': 'Current Location',
  'select_on_map': 'Select on Map',
  'manage_users': 'Manage Users',
  'project_users': 'Project Users',
  'no_users_assigned': 'No users assigned yet',
  'add_users_to_project': 'Add Users to Project',
  'all_users_assigned': 'All users are already assigned',
  'owner': 'Owner',
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
  'assign_task': 'कार्य असाइन करें',
  'stock_inventory': 'स्टॉक और इन्वेंट्री',
  'time_vs_cost': 'समय बनाम लागत विश्लेषण',
  'confirm_logout': 'लॉगआउट की पुष्टि करें',
  'confirm_logout_message': 'क्या आप वाकई लॉगआउट करना चाहते हैं?',
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
  'start': 'प्रारंभ',
  'end': 'समाप्ति',
  'start_date': 'प्रारंभ तिथि',
  'end_date': 'समाप्ति तिथि',
  'coordinates': 'निर्देशांक',
  'view_on_map': 'मानचित्र पर देखें',
  'no_projects': 'कोई परियोजना नहीं मिली',
  'lat_label': 'अक्षांश',
  'lng_label': 'देशांतर',
  'add_project': 'परियोजना जोड़ें',
  'edit_project': 'परियोजना संपादित करें',
  'create_project': 'परियोजना बनाएं',
  'latitude': 'अक्षांश',
  'longitude': 'देशांतर',
  'offline': 'ऑफ़लाइन',
  'online': 'ऑनलाइन',
  'checking_connection': 'कनेक्शन की जाँच...',
  'close': 'बंद करें',
  'success': 'सफलता',
  'error': 'त्रुटि',
  'loading': 'लोड हो रहा है...',
  'no_data': 'कोई डेटा उपलब्ध नहीं',
  'retry': 'पुनः प्रयास करें',
  'current_location': 'वर्तमान स्थान',
  'select_on_map': 'नक्शे पर चुनें',
  'manage_users': 'उपयोगकर्ताओं को प्रबंधित करें',
  'project_users': 'परियोजना उपयोगकर्ता',
  'no_users_assigned': 'अभी तक कोई उपयोगकर्ता नियुक्त नहीं है',
  'add_users_to_project': 'परियोजना में उपयोगकर्ता जोड़ें',
  'all_users_assigned': 'सभी उपयोगकर्ता पहले से नियुक्त हैं',
  'owner': 'मालिक',
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
  'assign_task': 'பணியை ஒதுக்கவும்',
  'stock_inventory': 'சரக்கு & கையிருப்பு',
  'time_vs_cost': 'நேரம் vs செலவு பகுப்பாய்வு',
  'confirm_logout': 'வெளியேறலை உறுதிசெய்க',
  'confirm_logout_message': 'நீங்கள் உண்மையில் வெளியேற விரும்புகிறீர்களா?',
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
  'start': 'தொடக்கம்',
  'end': 'முடிவு',
  'start_date': 'தொடக்க தேதி',
  'end_date': 'முடிவு தேதி',
  'coordinates': 'கோணங்கள்',
  'view_on_map': 'வரைபடத்தில் காண்க',
  'no_projects': 'திட்டங்கள் எதுவும் இல்லை',
  'lat_label': 'அட்ச',
  'lng_label': 'நெட',
  'add_project': 'திட்டம் சேர்க்கவும்',
  'edit_project': 'திட்டத்தை திருத்தவும்',
  'create_project': 'திட்டத்தை உருவாக்கவும்',
  'latitude': 'அட்சரேகை',
  'longitude': 'தீர்க்கரேகை',
  'offline': 'இணையம் இல்லை',
  'online': 'இணையில் உள்ளது',
  'checking_connection': 'இணைப்பு சரிபார்க்கப்படுகிறது...',
  'close': 'மூடுக',
  'success': 'வெற்றி',
  'error': 'பிழை',
  'manage_users': 'பயனர்களை நிர்வகிக்க',
  'project_users': 'திட்ட பயனர்கள்',
  'no_users_assigned': 'இன்னும் பயனர்கள் நியமிக்கப்படவில்லை',
  'add_users_to_project': 'திட்டத்திற்கு பயனர்களைச் சேர்க்கவும்',
  'all_users_assigned': 'அனைத்து பயனர்களும் ஏற்கனவே நியமிக்கப்பட்டுள்ளனர்',
  'loading': 'ஏற்றம்...',
  'no_data': 'தகவல் கிடைக்கவில்லை',
  'retry': 'மீண்டும் முயற்சி செய்க',
  'current_location': 'தற்போதைய இடம்',
  'select_on_map': 'வரைபடத்தில் தேர்வு செய்க',
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
  'assign_task': 'कार्य असाइन करा',
  'stock_inventory': 'स्टॉक आणि इन्व्हेंटरी',
  'time_vs_cost': 'वेळ विरुद्ध खर्च विश्लेषण',
  'confirm_logout': 'लॉगआउटची पुष्टी करा',
  'confirm_logout_message': 'आपण खरोखर लॉगआउट करू इच्छिता?',
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
  'start': 'सुरुवात',
  'end': 'शेवट',
  'start_date': 'सुरुवातीची तारीख',
  'end_date': 'शेवटची तारीख',
  'coordinates': 'निर्देशांक',
  'view_on_map': 'नकाशावर पहा',
  'no_projects': 'एकही प्रकल्प सापडला नाही',
  'lat_label': 'अक्षांश',
  'lng_label': 'रेखांश',
  'edit_project': 'प्रकल्प संपादित करा',
  'add_project': 'प्रकल्प जोडा',
  'create_project': 'प्रकल्प तयार करा',
  'latitude': 'अक्षांश',
  'longitude': 'रेखांश',
  'manage_users': 'वापरकर्ते व्यवस्थापित करा',
  'project_users': 'प्रकल्प वापरकर्ते',
  'no_users_assigned': 'अजूनही कोणीही वापरकर्ता नियुक्त केलेला नाही',
  'add_users_to_project': 'प्रकल्पात वापरकर्ते जोडा',
  'all_users_assigned': 'सर्व वापरकर्ते आधीच नियुक्त आहेत',
  'offline': 'ऑफलाइन',
  'online': 'ऑनलाइन',
  'checking_connection': 'कनेक्शन तपासत आहे...',
  'close': 'बंद करा',
  'success': 'यश',
  'error': 'त्रुटी',
  'loading': 'लोड हो रहे...',
  'current_location': 'सद्य स्थान',
  'select_on_map': 'नकाशावर निवडा',
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
