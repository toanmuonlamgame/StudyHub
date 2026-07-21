import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../core/app_motion.dart';
import '../../../core/widgets/studyhub_ui.dart';
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
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.xxl,
              AppSpacing.screenHorizontal,
              AppSpacing.screenBottom,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.formMaxWidth,
              ),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadii.feature),
                        ),
                        child: Column(
                          children: [
                            StudyHubIconSurface(
                              icon: Icons.auto_stories_rounded,
                              foregroundColor: theme.colorScheme.onPrimary,
                              backgroundColor: theme.colorScheme.primary,
                              size: 58,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              l10n.appTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AnimatedSwitcher(
                              duration: AppMotion.duration(
                                context,
                                AppMotion.standard,
                              ),
                              child: Text(
                                l10n.authWelcome,
                                key: ValueKey(_registering),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.authWelcomeBody,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AnimatedSize(
                        duration: AppMotion.duration(
                          context,
                          AppMotion.standard,
                        ),
                        curve: AppMotion.standardCurve,
                        child: _registering
                            ? Column(
                                children: [
                                  TextFormField(
                                    controller: _displayName,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: l10n.displayName,
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
                                      ),
                                    ),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? l10n.contributionValidationRequired
                                        : null,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
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
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: widget.controller.loading
                            ? null
                            : (_) => _submit(),
                        autofillHints: [
                          _registering
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? l10n.showPassword
                                : l10n.hidePassword,
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
                        const SizedBox(height: AppSpacing.md),
                        _AuthErrorMessage(
                          message: switch (widget.controller.errorCode) {
                            'INVALID_CREDENTIALS' =>
                              l10n.authInvalidCredentials,
                            'AUTHENTICATION_REQUIRED' =>
                              l10n.authSessionExpired,
                            _ => l10n.authRequestFailed,
                          },
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        onPressed: widget.controller.loading ? null : _submit,
                        icon: widget.controller.loading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _registering
                                    ? Icons.person_add_outlined
                                    : Icons.login,
                              ),
                        label: Text(_registering ? l10n.register : l10n.signIn),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: widget.controller.loading
                            ? null
                            : () =>
                                  setState(() => _registering = !_registering),
                        child: Text(
                          _registering
                              ? '${l10n.haveAccount} ${l10n.signIn}'
                              : '${l10n.noAccount} ${l10n.register}',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SocialDivider(label: l10n.authOrContinueWith),
                      const SizedBox(height: AppSpacing.lg),
                      OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                        label: Text(l10n.googleSignInComingSoon),
                      ),
                    ],
                  ),
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

class _AuthErrorMessage extends StatelessWidget {
  const _AuthErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              size: AppIconSizes.standard,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label, style: style),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
