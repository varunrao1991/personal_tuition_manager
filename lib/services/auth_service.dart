import '../exceptions/custom_exception.dart';
import '../utils/shared_pref.dart';

class AuthService {
  static const _pinKey = 'appLockPin';
  static const _loginFlagKey = 'isLoggedIn';
  static const _securityQuestionKey = 'securityQuestion';
  static const _securityAnswerKey = 'securityAnswer';

  // Hardcoded security questions
  static const Map<String, String> securityQuestions = {
    "What was your first pet's name?": "pet",
    "What city were you born in?": "city",
    "What is your mother's maiden name?": "mother",
    "What was the name of your first school?": "school",
  };

  Future<void> setPin(String pin, String question, String answer) async {
    await sharedPrefs.saveString(_pinKey, pin);
    await sharedPrefs.saveBool(_loginFlagKey, false);
    await sharedPrefs.saveString(_securityQuestionKey, question);
    await sharedPrefs.saveString(_securityAnswerKey, answer.toLowerCase());
  }

  Future<bool> doesPinExist() async {
    final storedPin = await sharedPrefs.getString(_pinKey);
    return storedPin != null;
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await sharedPrefs.getString(_pinKey);
    if (storedPin == null) throw PinNotSetException('No PIN set');
    return storedPin == pin;
  }

  Future<bool> verifySecurityAnswer(String answer) async {
    final storedAnswer = await sharedPrefs.getString(_securityAnswerKey);
    if (storedAnswer == null) throw PinSecurityNotSetException('No security question set');
    return storedAnswer == answer.toLowerCase();
  }

  
  Future<bool> verifySecurityQuestion(String question) async {
    final storedQuestion = await sharedPrefs.getString(_securityQuestionKey);
    if (storedQuestion == null) throw PinSecurityNotSetException('No security question set');
    return storedQuestion == question;
  }

  Future<String?> getSecurityQuestion() async {
    return await sharedPrefs.getString(_securityQuestionKey);
  }

  Future<Map<String, String>> getSecurityQuestions() async {
    return securityQuestions;
  }

  Future<void> changePin(String newPin) async {
    await sharedPrefs.saveString(_pinKey, newPin);
  }

  Future<void> login() async {
    await sharedPrefs.saveBool(_loginFlagKey, true);
  }

  Future<bool> isLoggedIn() async {
    return await sharedPrefs.getBool(_loginFlagKey) ?? false;
  }

  Future<void> logout() async {
    await sharedPrefs.saveBool(_loginFlagKey, false);
  }

  Future<bool> hasSecurityQuestions() async {
    final question = await sharedPrefs.getString(_securityQuestionKey);
    final answer = await sharedPrefs.getString(_securityAnswerKey);
    return question != null && answer != null;
  }
}