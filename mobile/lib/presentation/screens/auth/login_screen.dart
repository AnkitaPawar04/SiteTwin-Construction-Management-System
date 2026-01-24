import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/storage/preferences_service.dart';
import 'package:mobile/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = await ref.read(loginActionProvider(_phoneController.text.trim()).future);
      
      if (!mounted) return;
      
      if (user != null) {
        // Invalidate auth state to force rebuild
        ref.invalidate(authStateProvider);
        // Small delay to ensure state updates
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _showServerSettings() async {
    final prefs = await PreferencesService.getInstance();
    final currentUrl = prefs.getServerUrl() ?? ApiConstants.baseUrl;
    final controller = TextEditingController(text: currentUrl);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure the backend server URL:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'http://your-server:8000/api',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Current: $currentUrl',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Default: ${ApiConstants.baseUrl}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await prefs.setServerUrl(ApiConstants.baseUrl);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset to default URL')),
                );
              }
            },
            child: const Text('Reset to Default'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL cannot be empty')),
                );
                return;
              }
              
              await prefs.setServerUrl(url);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server URL updated to: $url')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'server_settings') {
                _showServerSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'server_settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Server Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon
                  Icon(
                    Icons.construction,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Construction Manager',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Field Management System',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Phone Input
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter 10-digit phone number',
                      prefixIcon: Icon(Icons.phone),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Phone number must contain only digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Info Text
                  Text(
                    'Login with your registered phone number',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Test Credentials
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Login:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTestCredential('Owner', '9876543210'),
                          _buildTestCredential('Manager', '9876543211'),
                          _buildTestCredential('Engineer', '9876543213'),
                          _buildTestCredential('Worker', '9876543220'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTestCredential(String role, String phone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$role:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(phone),
          const Spacer(),
          TextButton(
            onPressed: () {
              _phoneController.text = phone;
            },
            child: const Text('Use'),
          ),
        ],
      ),
    );
  }
}
