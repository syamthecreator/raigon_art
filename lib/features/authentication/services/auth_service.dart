import 'package:raigon_art/features/authentication/models/auth_model.dart';

class AuthService {
  AuthService._();

  static const String _mockUsername = 'admin';
  static const String _mockPassword = 'admin123';

  static Future<bool> signIn(String usernameOrPhone, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    return usernameOrPhone.trim().toLowerCase() == _mockUsername &&
        password == _mockPassword;
  }

  static Future<bool> sendWhatsAppOtp(String phone) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    //Replace with backend/WhatsApp API.
    return phone.trim().isNotEmpty;
  }

  static Future<bool> verifyOtp(String phone, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Replace with server-side OTP verification.
    return otp == AuthModel.mockOtp;
  }

  static Future<bool> resetPassword(String phone, String newPassword) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    // Replace with backend/Firebase password update.
    return phone.trim().isNotEmpty && newPassword.isNotEmpty;
  }
}
