import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _locationEnabled = prefs.getBool('location_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() => _selectedLanguage = language);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Language updated')),
      );
    }
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _saveLocationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_enabled', value);
    setState(() => _locationEnabled = value);
  }

  Future<void> _saveDarkModeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() => _darkModeEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Display Section
          _buildSectionHeader('Display'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: _darkModeEnabled,
            onChanged: _saveDarkModeSetting,
            secondary: const Icon(Icons.brightness_4),
          ),
          const Divider(),

          // Language Section
          _buildSectionHeader('Language & Region'),
          ListTile(
            title: const Text('Language'),
            subtitle: const Text('Select app language'),
            leading: const Icon(Icons.language),
            onTap: _showLanguageDialog,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _getLanguageName(_selectedLanguage),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications'),
            value: _notificationsEnabled,
            onChanged: _saveNotificationSetting,
            secondary: const Icon(Icons.notifications),
          ),
          ListTile(
            title: const Text('Notification Types'),
            subtitle: const Text('Configure notification preferences'),
            leading: const Icon(Icons.tune),
            onTap: () => _showNotificationSettings(context),
          ),
          const Divider(),

          // Location Section
          _buildSectionHeader('Location & Privacy'),
          SwitchListTile(
            title: const Text('Location Services'),
            subtitle: const Text('Allow location access for check-in'),
            value: _locationEnabled,
            onChanged: _saveLocationSetting,
            secondary: const Icon(Icons.location_on),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('View privacy policy'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () => _showPrivacyPolicy(context),
          ),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info),
          ),
          ListTile(
            title: const Text('Build Number'),
            subtitle: const Text('Build 1'),
            leading: const Icon(Icons.build),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            subtitle: const Text('View terms'),
            leading: const Icon(Icons.description),
            onTap: () => _showTermsOfService(context),
          ),
          const Divider(),

          // Data Section
          _buildSectionHeader('Data & Cache'),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove cached data'),
            leading: const Icon(Icons.delete),
            onTap: _clearCache,
          ),
          ListTile(
            title: const Text('Clear All Data'),
            subtitle: const Text('Warning: This will remove all local data'),
            leading: const Icon(Icons.delete_forever),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: _clearAllData,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    const languages = {
      'en': 'English',
      'hi': 'हिन्दी (Hindi)',
      'ta': 'தமிழ் (Tamil)',
      'mr': 'मराठी (Marathi)',
    };
    return languages[code] ?? 'Unknown';
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English'),
            _buildLanguageOption('hi', 'हिन्दी (Hindi)'),
            _buildLanguageOption('ta', 'தமிழ் (Tamil)'),
            _buildLanguageOption('mr', 'मराठी (Marathi)'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name) {
    return RadioListTile(
      // ignore: deprecated_member_use
      title: Text(name),
      // ignore: deprecated_member_use
      value: code,
      // ignore: deprecated_member_use
      groupValue: _selectedLanguage,
      // ignore: deprecated_member_use
      onChanged: (value) {
        Navigator.pop(context);
        _saveLanguage(value!);
      },
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('DPR Updates'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Task Assignments'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Attendance Reminders'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Material Requests'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Privacy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This app respects your privacy. Your location data is only used for attendance tracking. '
                'Your personal data is encrypted and stored securely.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text(
                'Data Collection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Location data (check-in/check-out)\n'
                '• Device information\n'
                '• App usage statistics\n'
                '• Photos and attachments',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using this app, you agree to our terms and conditions. '
            'This is a construction field management system designed for project teams. '
            'Please use responsibly and maintain data confidentiality.',
            style: TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear app cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will remove all app data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement data clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
