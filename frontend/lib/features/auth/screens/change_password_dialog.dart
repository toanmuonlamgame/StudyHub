import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../auth_controller.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key, required this.controller});

  final AuthController controller;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_current.text.isEmpty ||
        _next.text.length < 8 ||
        _next.text == _current.text ||
        _next.text != _confirm.text) {
      setState(() => _error = l10n.changePasswordValidation);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final changed = await widget.controller.changePassword(
      _current.text,
      _next.text,
    );
    if (!mounted) return;
    if (changed) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _busy = false;
        _error = l10n.changePasswordFailed;
      });
    }
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        scrollable: true,
        title: Text(l10n.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.changePasswordSignInAgain),
            for (final (controller, label) in [
              (_current, l10n.currentPassword),
              (_next, l10n.newPassword),
              (_confirm, l10n.confirmNewPassword),
            ]) ...[
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                enabled: !_busy,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 128,
                decoration: InputDecoration(labelText: label, counterText: ''),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Semantics(liveRegion: true, child: Text(_error!)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.progressCancel),
          ),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.changePassword),
          ),
        ],
      ),
    );
  }
}
