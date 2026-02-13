import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await Provider.of<AuthProvider>(context, listen: false).register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.registrationFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/taskssphere_only_logo.png',
                height: 60,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.register,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 32),
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
                          decoration: const InputDecoration(hintText: 'email@example.com'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value == null || !value.contains('@') ? l10n.invalidEmail : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel(l10n.password),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(hintText: '••••••••'),
                          obscureText: true,
                          validator: (value) => value == null || value.length < 8 ? l10n.passwordTooShort : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel(l10n.passwordConfirmation),
                        TextFormField(
                          controller: _passwordConfirmController,
                          decoration: const InputDecoration(hintText: '••••••••'),
                          obscureText: true,
                          validator: (value) => value != _passwordController.text ? l10n.passwordsDoNotMatch : null,
                        ),
                        const SizedBox(height: 32),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF3b82f6)
                                        : const Color(0xFF111827),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    l10n.registerButton,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.alreadyHaveAccount,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
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
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : const Color(0xFF374151),
        ),
      ),
    );
  }
}
