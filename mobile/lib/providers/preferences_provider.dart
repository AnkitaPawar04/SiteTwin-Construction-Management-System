import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/storage/preferences_service.dart';

// Selected project ID provider (stores just the ID)
final selectedProjectProvider = NotifierProvider<SelectedProjectNotifier, int?>(() {
  return SelectedProjectNotifier();
});

class SelectedProjectNotifier extends Notifier<int?> {
  @override
  int? build() {
    _loadSelectedProject();
    return null;
  }
  
  Future<void> _loadSelectedProject() async {
    final prefs = await PreferencesService.getInstance();
    state = prefs.getSelectedProject();
  }
  
  Future<void> selectProject(int projectId) async {
    state = projectId;
    final prefs = await PreferencesService.getInstance();
    await prefs.setSelectedProject(projectId);
  }
  
  Future<void> clearSelection() async {
    state = null;
    final prefs = await PreferencesService.getInstance();
    await prefs.clearSelectedProject();
  }
}

// Language provider
final languageProvider = NotifierProvider<LanguageNotifier, String>(() {
  return LanguageNotifier();
});

class LanguageNotifier extends Notifier<String> {
  @override
  String build() {
    _loadLanguage();
    return 'en';
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await PreferencesService.getInstance();
    state = prefs.getLanguage() ?? 'en';
  }
  
  Future<void> setLanguage(String languageCode) async {
    state = languageCode;
    final prefs = await PreferencesService.getInstance();
    await prefs.setLanguage(languageCode);
  }
}
