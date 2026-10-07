class AuthService {
  AuthService._();

  static const String _mockUsername = 'admin';
  static const String _mockPassword = 'admin123';
  static const String _mockOtp = '1234';

  static const String registeredPhone = '+91 9876543210';

  static String get mockOtp => _mockOtp;

  static Future<bool> signIn(String usernameOrPhone, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    return usernameOrPhone.trim().toLowerCase() == _mockUsername &&
        password == _mockPassword;
  }

  static Future<bool> sendWhatsAppOtp(String phone) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    return true;
  }

  static Future<bool> verifyOtp(String phone, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return otp == _mockOtp;
  }

  static Future<bool> resetPassword(String phone, String newPassword) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    return true;
  }
}
