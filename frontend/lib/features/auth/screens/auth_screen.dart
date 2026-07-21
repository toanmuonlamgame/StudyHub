import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});
  final AuthController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  bool _registering = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authWelcome,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.authWelcomeBody, textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    if (_registering) ...[
                      TextFormField(
                        controller: _displayName,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.displayName,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? l10n.contributionValidationRequired
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) =>
                          value == null ||
                              !RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(value.trim())
                          ? l10n.authInvalidEmail
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      autofillHints: [
                        _registering
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          value == null ||
                              value.length < 8 ||
                              value.length > 128
                          ? l10n.authPasswordLength
                          : null,
                    ),
                    if (widget.controller.errorCode != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        switch (widget.controller.errorCode) {
                          'INVALID_CREDENTIALS' => l10n.authInvalidCredentials,
                          'AUTHENTICATION_REQUIRED' => l10n.authSessionExpired,
                          _ => l10n.authRequestFailed,
                        },
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: widget.controller.loading ? null : _submit,
                      child: widget.controller.loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_registering ? l10n.register : l10n.signIn),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: widget.controller.loading
                          ? null
                          : () => setState(() => _registering = !_registering),
                      child: Text(
                        _registering
                            ? '${l10n.haveAccount} ${l10n.signIn}'
                            : '${l10n.noAccount} ${l10n.register}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_registering) {
      await widget.controller.register(
        email: _email.text,
        password: _password.text,
        displayName: _displayName.text,
      );
    } else {
      await widget.controller.login(
        email: _email.text,
        password: _password.text,
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _displayName.dispose();
    super.dispose();
  }
}
