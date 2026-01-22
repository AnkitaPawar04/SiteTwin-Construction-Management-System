import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _languageKey = 'app_language';
  static const String _selectedProjectKey = 'selected_project_id';
  static const String _themeKey = 'app_theme';
  
  static PreferencesService? _instance;
  static SharedPreferences? _preferences;
  
  PreferencesService._();
  
  static Future<PreferencesService> getInstance() async {
    _instance ??= PreferencesService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  // Language Preferences
  Future<void> setLanguage(String languageCode) async {
    await _preferences!.setString(_languageKey, languageCode);
  }
  
  String? getLanguage() {
    return _preferences!.getString(_languageKey);
  }
  
  // Project Selection Preferences
  Future<void> setSelectedProject(int projectId) async {
    await _preferences!.setInt(_selectedProjectKey, projectId);
  }
  
  int? getSelectedProject() {
    return _preferences!.getInt(_selectedProjectKey);
  }
  
  Future<void> clearSelectedProject() async {
    await _preferences!.remove(_selectedProjectKey);
  }
  
  // Theme Preferences
  Future<void> setThemeMode(String mode) async {
    await _preferences!.setString(_themeKey, mode);
  }
  
  String getThemeMode() {
    return _preferences!.getString(_themeKey) ?? 'light';
  }
  
  // Clear all preferences
  Future<void> clearAll() async {
    await _preferences!.clear();
  }
}
