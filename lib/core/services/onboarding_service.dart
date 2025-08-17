import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _firstLaunchKey = 'first_launch';

  // Onboarding tugagan yoki tugamaganini tekshirish
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // Onboarding ni tugatilgan deb belgilash
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // App birinchi marta ochilgan yoki yo'qini tekshirish
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  // App ochilgan deb belgilash
  static Future<void> markAppLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  // Onboarding holatini qayta o'rnatish (testing uchun)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_firstLaunchKey);
  }

  // Barcha onboarding ma'lumotlarini olish
  static Future<Map<String, bool>> getOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isCompleted': prefs.getBool(_onboardingKey) ?? false,
      'isFirstLaunch': prefs.getBool(_firstLaunchKey) ?? true,
    };
  }
}
