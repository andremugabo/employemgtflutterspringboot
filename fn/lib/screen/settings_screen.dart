import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricAuthEnabled = false;
  String _selectedLanguage = 'English';
  double _fontSize = 1.0; // 1.0 is normal size

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Japanese',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = _prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = _prefs.getBool('notifications') ?? true;
      _biometricAuthEnabled = _prefs.getBool('biometricAuth') ?? false;
      _selectedLanguage = _prefs.getString('language') ?? 'English';
      _fontSize = _prefs.getDouble('fontSize') ?? 1.0;
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text(
              'Are you sure you want to reset all settings to default?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _resetSettings();
                  Navigator.pop(context);
                },
                child: const Text('Reset', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _resetSettings() async {
    setState(() {
      _isDarkMode = false;
      _notificationsEnabled = true;
      _biometricAuthEnabled = false;
      _selectedLanguage = 'English';
      _fontSize = 1.0;
    });

    await _prefs.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings reset to defaults')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset Settings',
            onPressed: _showResetConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance'),
            _buildDarkModeSwitch(),
            _buildFontSizeSlider(),
            const Divider(height: 32),

            _buildSectionHeader('Preferences'),
            _buildLanguageDropdown(),
            _buildNotificationSwitch(),
            _buildBiometricAuthSwitch(),
            const Divider(height: 32),

            _buildSectionHeader('About'),
            _buildAppInfoCard(),
            _buildSectionHeader('Account'),
            _buildAccountSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDarkModeSwitch() {
    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: _isDarkMode,
      onChanged: (value) async {
        setState(() => _isDarkMode = value);
        await _savePreference('darkMode', value);
        // TODO: Implement theme change notifier
      },
      secondary: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
    );
  }

  Widget _buildFontSizeSlider() {
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Font Size'),
          Slider(
            value: _fontSize,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            label: _fontSize.toStringAsFixed(1),
            onChanged: (value) async {
              setState(() => _fontSize = value);
              await _savePreference('fontSize', value);
              // TODO: Implement font size change notifier
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        underline: Container(),
        items:
            _languages.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: (String? newValue) async {
          if (newValue != null) {
            setState(() => _selectedLanguage = newValue);
            await _savePreference('language', newValue);
            // TODO: Implement language change
          }
        },
      ),
    );
  }

  Widget _buildNotificationSwitch() {
    return SwitchListTile(
      title: const Text('Enable Notifications'),
      value: _notificationsEnabled,
      onChanged: (value) async {
        setState(() => _notificationsEnabled = value);
        await _savePreference('notifications', value);
        // TODO: Implement notification permission handling
      },
      secondary: const Icon(Icons.notifications),
    );
  }

  Widget _buildBiometricAuthSwitch() {
    return SwitchListTile(
      title: const Text('Biometric Authentication'),
      value: _biometricAuthEnabled,
      onChanged: (value) async {
        setState(() => _biometricAuthEnabled = value);
        await _savePreference('biometricAuth', value);
        // TODO: Implement biometric auth setup
      },
      secondary: const Icon(Icons.fingerprint),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Version'),
              trailing: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Check for Updates'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement update check
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Checking for updates...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Open privacy policy
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to profile edit
            },
          ),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to password change
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Change Email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to email change
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () {
              // TODO: Show delete account confirmation
            },
          ),
        ],
      ),
    );
  }
}
