import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/authentication/models/auth_model.dart';
import 'package:raigon_art/features/authentication/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const int _resendSeconds = 120;

  AuthModel _state = const AuthModel();
  Timer? _timer;

  AuthModel get state => _state;
  AuthStep get step => _state.step;
  bool get isLoading => _state.isLoading;
  int get secondsLeft => _state.secondsLeft;
  bool get canResend => _state.canResend;
  bool get isAuthenticated => _state.isAuthenticated;
  String? get errorMessage => _state.errorMessage;
  String? get successMessage => _state.successMessage;

  String get registeredPhone => AuthModel.registeredPhone;
  String get mockOtp => AuthModel.mockOtp;
  String get timeText => _state.timeText;

  void _update(AuthModel state) {
    _state = state;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _update(
      _state.copyWith(isLoading: value, clearError: value, clearSuccess: value),
    );
  }

  void goTo(AuthStep step) {
    if (step == AuthStep.signIn) {
      backToSignIn();
      return;
    }

    _update(_state.copyWith(step: step, clearError: true, clearSuccess: true));
  }

  void backToSignIn() {
    _stopTimer();

    _update(
      _state.copyWith(
        step: AuthStep.signIn,
        secondsLeft: 0,
        isLoading: false,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<bool> signIn(String usernameOrPhone, String password) async {
    if (isLoading) return false;

    _setLoading(true);

    try {
      final success = await AuthService.signIn(usernameOrPhone, password);

      if (success) {
        _update(
          _state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            clearError: true,
          ),
        );
        return true;
      }

      _update(
        _state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: 'Invalid username or password.',
        ),
      );
      return false;
    } catch (_) {
      _update(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to sign in. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> sendOtp(String phone) async {
    if (isLoading) return false;

    _setLoading(true);

    try {
      final success = await AuthService.sendWhatsAppOtp(phone);

      if (!success) {
        _update(
          _state.copyWith(
            isLoading: false,
            errorMessage: 'Could not send OTP. Try again.',
          ),
        );
        return false;
      }

      _update(
        _state.copyWith(
          step: AuthStep.otp,
          isLoading: false,
          secondsLeft: _resendSeconds,
          clearError: true,
        ),
      );

      _startTimer();
      return true;
    } catch (_) {
      _update(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Could not send OTP. Try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> resendOtp(String phone) async {
    if (!canResend || isLoading) return false;

    _setLoading(true);

    try {
      final success = await AuthService.sendWhatsAppOtp(phone);

      if (!success) {
        _update(
          _state.copyWith(
            isLoading: false,
            errorMessage: 'Could not resend OTP. Try again.',
          ),
        );
        return false;
      }

      _update(
        _state.copyWith(
          isLoading: false,
          secondsLeft: _resendSeconds,
          clearError: true,
        ),
      );

      _startTimer();
      return true;
    } catch (_) {
      _update(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Could not resend OTP. Try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    if (isLoading) return false;

    _setLoading(true);

    try {
      final success = await AuthService.verifyOtp(phone, otp);

      if (!success) {
        _update(
          _state.copyWith(
            isLoading: false,
            errorMessage: 'Invalid OTP. Please try again.',
          ),
        );
        return false;
      }

      _stopTimer();

      _update(
        _state.copyWith(
          step: AuthStep.newPassword,
          isLoading: false,
          secondsLeft: 0,
          clearError: true,
        ),
      );
      return true;
    } catch (_) {
      _update(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to verify OTP. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> resetPassword(String phone, String newPassword) async {
    if (isLoading) return false;

    _setLoading(true);

    try {
      final success = await AuthService.resetPassword(phone, newPassword);

      if (!success) {
        _update(
          _state.copyWith(
            isLoading: false,
            errorMessage: 'Could not update password. Try again.',
          ),
        );
        return false;
      }

      _update(_state.copyWith(isLoading: false, clearError: true));
      return true;
    } catch (_) {
      _update(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Could not update password. Try again.',
        ),
      );
      return false;
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.secondsLeft <= 1) {
        timer.cancel();
        _update(_state.copyWith(secondsLeft: 0));
        return;
      }

      _update(_state.copyWith(secondsLeft: _state.secondsLeft - 1));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
