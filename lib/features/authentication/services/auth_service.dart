import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/authentication/models/auth_model.dart';

class AuthService {
  AuthService._();

  static Future<String?> signIn(String identifier, String password) async {
    final input = identifier.trim();
    final normalizedInput = input.replaceAll(RegExp(r'[\s-]'), '');
    final normalizedPhone = AuthModel.registeredPhone;

    final isPhone = normalizedInput == normalizedPhone;
    final isAdminEmail =
        input.toLowerCase() == AuthModel.adminEmail.toLowerCase();
    final isStaffEmail =
        input.toLowerCase() == AuthModel.staffEmail.toLowerCase();

    if (!isPhone && !isAdminEmail && !isStaffEmail) {
      debugPrint('[AuthService] Unsupported sign-in identifier.');
      return null;
    }

    final accounts = isPhone
        ? [
            (email: AuthModel.adminEmail, role: 'admin'),
            (email: AuthModel.staffEmail, role: 'staff'),
          ]
        : [
            (
              email: isAdminEmail ? AuthModel.adminEmail : AuthModel.staffEmail,
              role: isAdminEmail ? 'admin' : 'staff',
            ),
          ];

    for (final account in accounts) {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: account.email,
              password: password,
            );

        if (credential.user == null) {
          continue;
        }

        debugPrint('[AuthService] Firebase sign-in successful.');

        return account.role;
      } on FirebaseAuthException catch (error) {
        debugPrint('[AuthService] Sign-in attempt failed: ${error.code}');

        // If one account's credentials fail, try the next account.
        // Other Firebase errors should stop the login attempt.
        const credentialErrors = {
          'invalid-credential',
          'wrong-password',
          'user-not-found',
          'invalid-email',
        };

        if (credentialErrors.contains(error.code)) {
          continue;
        }

        return null;
      } catch (error) {
        debugPrint('[AuthService] Sign-in failed: $error');
        return null;
      }
    }

    return null;
  }

  static Future<bool> sendWhatsAppOtp(String phone) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    return phone.replaceAll(RegExp(r'[\s-]'), '') == AuthModel.registeredPhone;
  }

  static Future<bool> verifyOtp(String phone, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return phone.replaceAll(RegExp(r'[\s-]'), '') ==
            AuthModel.registeredPhone &&
        otp == AuthModel.mockOtp;
  }

  static Future<bool> resetPassword(String phone, String newPassword) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    return phone.replaceAll(RegExp(r'[\s-]'), '') ==
            AuthModel.registeredPhone &&
        newPassword.trim().length >= 6;
  }
}
