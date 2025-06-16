import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';

class ResendCodeLink extends StatefulWidget {
  final String email;
  final VoidCallback onPressed;

  const ResendCodeLink({
    super.key,
    required this.email,
    required this.onPressed,
  });

  @override
  State<ResendCodeLink> createState() => _ResendCodeLinkState();
}

class _ResendCodeLinkState extends State<ResendCodeLink> {
  int _countdown = 0;
  bool _canResend = true;

  void _startCountdown() {
    setState(() {
      _canResend = false;
      _countdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown == 0) {
          setState(() {
            _canResend = true;
          });
          return false;
        }
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _canResend ? () {
        widget.onPressed();
        _startCountdown();
      } : null,
      child: Text(
        _canResend ? 'Renvoyer le code' : 'Renvoyer dans ${_countdown}s',
        style: TextStyle(
            color: _canResend ? AppColors.primary : Colors.grey,
            fontSize: 14,
            decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}