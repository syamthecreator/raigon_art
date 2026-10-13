import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/authentication/models/auth_model.dart';

class AuthService {
  AuthService._();

  static const String _mockUsername = 'admin';
  static const String _mockPassword = 'admin123';
  static const String _adminEmail = 'admin@raigonart.com';

  static Future<bool> signIn(String usernameOrPhone, String password) async {
    debugPrint('[AuthService] Sign-in started.');

    final username = usernameOrPhone.trim().toLowerCase();

    if (username != _mockUsername || password != _mockPassword) {
      debugPrint('[AuthService] Sign-in rejected: invalid credentials.');
      return false;
    }

    debugPrint('[AuthService] Demo credentials validated.');
    debugPrint('[AuthService] Attempting Firebase Authentication...');

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _adminEmail,
        password: password,
      );

      debugPrint(
        '[AuthService] Firebase sign-in successful. '
        'UID: ${credential.user?.uid}',
      );

      return true;
    } on FirebaseAuthException catch (error, stackTrace) {
      debugPrint(
        '[AuthService] Firebase sign-in failed. '
        'Code: ${error.code}, Message: ${error.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('[AuthService] Unexpected sign-in error: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<bool> sendWhatsAppOtp(String phone) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    return phone.trim().isNotEmpty;
  }

  static Future<bool> verifyOtp(String phone, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return otp == AuthModel.mockOtp;
  }

  static Future<bool> resetPassword(String phone, String newPassword) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    return phone.trim().isNotEmpty && newPassword.isNotEmpty;
  }
}
