import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  String? _selectedLanguage;
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _emailController = TextEditingController(text: user?.email);
    _selectedLanguage = user?.language ?? 'de';

    // Profil vom Server laden, um sicherzustellen, dass wir aktuelle Daten haben
    Future.microtask(() async {
      await authProvider.fetchProfile();
      if (mounted) {
        final updatedUser = authProvider.user;
        setState(() {
          _firstNameController.text = updatedUser?.firstName ?? '';
          _lastNameController.text = updatedUser?.lastName ?? '';
          _emailController.text = updatedUser?.email ?? '';
          _selectedLanguage = updatedUser?.language ?? 'de';
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await Provider.of<AuthProvider>(context, listen: false).updateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      language: _selectedLanguage,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      passwordConfirmation: _passwordConfirmController.text.isNotEmpty ? _passwordConfirmController.text : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdateFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.personalInfo,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildLabel(l10n.firstName),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(hintText: 'Max'),
                validator: (value) => value == null || value.isEmpty ? l10n.enterFirstName : null,
              ),
              const SizedBox(height: 16),
              _buildLabel(l10n.lastName),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(hintText: 'Mustermann'),
                validator: (value) => value == null || value.isEmpty ? l10n.enterLastName : null,
              ),
              const SizedBox(height: 16),
              _buildLabel(l10n.email),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'max@example.com'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@') ? l10n.invalidEmail : null,
              ),
              const SizedBox(height: 16),
              _buildLabel(l10n.language),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF374151)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    items: [
                      DropdownMenuItem(value: 'de', child: Text(l10n.german)),
                      DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.changePassword,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.leaveBlank,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildLabel(l10n.newPasswordOptional),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: '••••••••'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildLabel(l10n.confirmPassword),
              TextFormField(
                controller: _passwordConfirmController,
                decoration: const InputDecoration(hintText: '••••••••'),
                obscureText: true,
                validator: (value) {
                  if (_passwordController.text.isNotEmpty && value != _passwordController.text) {
                    return l10n.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: Text(l10n.saveChanges.toUpperCase()),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[700],
        ),
      ),
    );
  }
}
