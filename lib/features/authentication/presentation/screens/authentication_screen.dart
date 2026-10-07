import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raigon_art/app/app_router.dart';
import 'package:raigon_art/core/constants/asset_constants.dart';
import 'package:raigon_art/core/theme/app_colors.dart';
import 'package:raigon_art/core/widgets/app_snackbar.dart';
import 'package:raigon_art/features/authentication/presentation/widgets/auth_widget.dart';
import 'package:raigon_art/features/authentication/services/auth_service.dart';

enum AuthStep { signIn, forgot, otp, newPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const int _resendSeconds = 120;

  AuthStep _step = AuthStep.signIn;

  final _usernameCtrl = TextEditingController(text: 'admin');
  final _passwordCtrl = TextEditingController(text: 'admin123');
  final _phoneCtrl = TextEditingController(text: AuthService.registeredPhone);
  final _otpCtrl = TextEditingController(text: '1234');
  final _newPassCtrl = TextEditingController(text: '1234567890');
  final _confirmPassCtrl = TextEditingController(text: '1234567890');

  bool _hidePassword = true;
  bool _hideNewPass = true;
  bool _hideConfirmPass = true;
  bool _loading = false;

  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }


  void _goTo(AuthStep step) => setState(() => _step = step);

  void _backToSignIn() {
    _timer?.cancel();
    _otpCtrl.text = AuthService.mockOtp;
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();
    _passwordCtrl.clear();
    _goTo(AuthStep.signIn);
  }

  Future<void> _signIn() async {
    final user = _usernameCtrl.text.trim();
    final pass = _passwordCtrl.text;
    if (user.isEmpty) {
      AppSnackBar.error(context, 'Enter your phone number or username.');
      return;
    }
    if (pass.isEmpty) {
      AppSnackBar.error(context, 'Enter your password.');
      return;
    }
    setState(() => _loading = true);
    final ok = await AuthService.signIn(user, pass);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      AppSnackBar.success(context, 'Welcome to Raigon Arts Management System!');
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else {
      AppSnackBar.error(context, 'Invalid username or password.');
    }
  }

  Future<void> _sendOtp() async {
    setState(() => _loading = true);

    final ok = await AuthService.sendWhatsAppOtp(_phoneCtrl.text);

    if (!mounted) return;

    setState(() => _loading = false);

    if (!ok) {
      AppSnackBar.error(context, 'Could not send OTP. Try again.');
      return;
    }

    _otpCtrl.text = AuthService.mockOtp;

    _startTimer();
    _goTo(AuthStep.otp);

    AppSnackBar.success(
      context,
      '💬 WhatsApp OTP sent to ${_phoneCtrl.text}! '
      'Verification Code: ${AuthService.mockOtp}',
    );
  }

  Future<void> _resendOtp() async {
    if (_secondsLeft > 0 || _loading) return;

    final ok = await AuthService.sendWhatsAppOtp(_phoneCtrl.text);

    if (!mounted) return;

    if (ok) {
      _otpCtrl.text = AuthService.mockOtp;

      _startTimer();

      AppSnackBar.success(
        context,
        '💬 WhatsApp OTP resent to ${_phoneCtrl.text}! '
        'Verification Code: ${AuthService.mockOtp}',
      );
    } else {
      AppSnackBar.error(context, 'Could not resend OTP. Try again.');
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 4) {
      AppSnackBar.error(context, 'Enter the 4-digit code.');
      return;
    }
    setState(() => _loading = true);
    final ok = await AuthService.verifyOtp(_phoneCtrl.text, otp);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      _timer?.cancel();

      _newPassCtrl.text = '1234567890';
      _confirmPassCtrl.text = '1234567890';

      _goTo(AuthStep.newPassword);

      AppSnackBar.success(
        context,
        'OTP Verified Successfully! Please create your new password.',
      );
    } else {
      AppSnackBar.error(context, 'Invalid OTP. Please try again.');
    }
  }

  Future<void> _savePassword() async {
    final pass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;
    if (pass.length < 6) {
      AppSnackBar.error(context, 'Password must be at least 6 characters.');
      return;
    }
    if (pass != confirm) {
      AppSnackBar.error(context, 'Passwords do not match.');
      return;
    }
    setState(() => _loading = true);
    final ok = await AuthService.resetPassword(_phoneCtrl.text, pass);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      _backToSignIn();
      AppSnackBar.success(context, 'Password updated. Please sign in.');
    } else {
      AppSnackBar.error(context, 'Could not update password. Try again.');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timeText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    height: isWide ? 570 : null,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textLabel.withValues(alpha: 0.14),
                          blurRadius: 60,
                          offset: const Offset(0, 24),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isWide
                        ? Row(
                            children: [
                              const Expanded(child: _LogoPanel()),
                              Expanded(child: _formPanel()),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 200, child: _LogoPanel()),
                              _formPanel(),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _formPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: switch (_step) {
              AuthStep.signIn => _signInContent(),
              AuthStep.forgot => _forgotContent(),
              AuthStep.otp => _otpContent(),
              AuthStep.newPassword => _newPasswordContent(),
            },
          ),
        ),
      ),
    );
  }

  Widget _eyeButton(bool hidden, VoidCallback onTap) => IconButton(
    onPressed: onTap,
    splashRadius: 18,
    icon: Icon(
      hidden ? Icons.visibility : Icons.visibility_off,
      size: 20,
      color: AppColors.fieldIcon,
    ),
  );


  Widget _signInContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          icon: Icons.shield_outlined,
          title: 'Welcome Back',
          subtitle: 'Please sign in to access your workshop dashboard.',
        ),
        const SizedBox(height: 40),
        const AuthFieldLabel('Phone Number / Username'),
        AuthTextField(
          controller: _usernameCtrl,
          prefixIcon: Icons.person,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        const AuthFieldLabel('Password'),
        AuthTextField(
          controller: _passwordCtrl,
          prefixIcon: Icons.lock,
          obscureText: _hidePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _signIn(),
          suffix: _eyeButton(
            _hidePassword,
            () => setState(() => _hidePassword = !_hidePassword),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: AuthTextLink(
            label: 'Forgot Password?',
            onTap: () => _goTo(AuthStep.forgot),
          ),
        ),
        const SizedBox(height: 14),
        AuthButton(
          label: 'Sign In to Workshop',
          icon: Icons.login,
          iconAfter: true,
          gradient: AppColors.darkGradient,
          loading: _loading,
          loadingLabel: 'Signing in...',
          onPressed: _signIn,
        ),
      ],
    );
  }

  Widget _forgotContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          green: true,
          icon: Icons.chat_bubble_outline,
          title: 'Forgot Password?',
          subtitle: 'OTP will be sent to your database registered phone.',
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Registered Phone Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLabel,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Database Saved',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.green,
                ),
              ),
            ),
          ],
        ),
        AuthTextField(
          controller: _phoneCtrl,
          prefixIcon: Icons.smartphone,
          iconColor: AppColors.green,
          readOnly: true,
        ),
        const SizedBox(height: 14),
        AuthButton(
          label: 'Send OTP to Saved Number',
          icon: Icons.chat_bubble_outline,
          gradient: AppColors.greenGradient,
          shadowColor: AppColors.green,
          loading: _loading,
          loadingLabel: 'Sending OTP via WhatsApp...',
          onPressed: _sendOtp,
        ),
        const SizedBox(height: 18),
        Center(
          child: AuthTextLink(
            label: 'Back to Sign In',
            icon: Icons.arrow_back,
            onTap: _backToSignIn,
          ),
        ),
      ],
    );
  }

  Widget _otpContent() {
    final canResend = _secondsLeft == 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          icon: Icons.shield_outlined,
          title: 'Enter WhatsApp OTP',
          subtitleSpan: TextSpan(
            children: [
              const TextSpan(text: 'We sent a 4-digit code to '),
              TextSpan(
                text: _phoneCtrl.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        const AuthFieldLabel('4-Digit Verification Code *'),
        AuthTextField(
          controller: _otpCtrl,
          prefixIcon: Icons.vpn_key,
          autofocus: true,
          maxLength: 4,
          letterSpacing: 8,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => _verifyOtp(),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.otpPanelFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 18,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  text: 'Resend code in ',
                  children: [
                    TextSpan(
                      text: _timeText,
                      style: const TextStyle(color: AppColors.gold),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: canResend ? _resendOtp : null,
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 16,
                      color: canResend
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: canResend
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        AuthButton(
          label: 'Verify OTP & Continue',
          icon: Icons.check_circle,
          gradient: AppColors.darkGradient,
          loading: _loading,
          loadingLabel: 'Verifying...',
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: 18),
        Center(
          child: AuthTextLink(
            label: 'Back to Sign In',
            icon: Icons.arrow_back,
            onTap: _backToSignIn,
          ),
        ),
      ],
    );
  }

  Widget _newPasswordContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          green: true,
          icon: Icons.lock,
          title: 'Create New Password',
          subtitle: 'Set a strong new password for your workshop account.',
        ),
        const SizedBox(height: 32),
        const AuthFieldLabel('New Password *'),
        AuthTextField(
          controller: _newPassCtrl,
          prefixIcon: Icons.lock,
          hint: 'Enter new password (min 6 chars)',
          obscureText: _hideNewPass,
          autofocus: true,
          textInputAction: TextInputAction.next,
          suffix: _eyeButton(
            _hideNewPass,
            () => setState(() => _hideNewPass = !_hideNewPass),
          ),
        ),
        const SizedBox(height: 10),
        const AuthFieldLabel('Confirm New Password *'),
        AuthTextField(
          controller: _confirmPassCtrl,
          prefixIcon: Icons.lock,
          hint: 'Re-enter new password',
          obscureText: _hideConfirmPass,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _savePassword(),
          suffix: _eyeButton(
            _hideConfirmPass,
            () => setState(() => _hideConfirmPass = !_hideConfirmPass),
          ),
        ),
        const SizedBox(height: 14),
        AuthButton(
          label: 'Save New Password & Sign In',
          icon: Icons.save,
          gradient: AppColors.greenSolidGradient,
          shadowColor: AppColors.green,
          loading: _loading,
          loadingLabel: 'Saving...',
          onPressed: _savePassword,
        ),
        const SizedBox(height: 18),
        Center(
          child: AuthTextLink(
            label: 'Back to Sign In',
            icon: Icons.arrow_back,
            onTap: _backToSignIn,
          ),
        ),
      ],
    );
  }
}

class _LogoPanel extends StatelessWidget {
  const _LogoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gold,
      child: Image.asset(
        AssetConstants.raigonLogo,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
