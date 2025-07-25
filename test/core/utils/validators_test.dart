import 'package:flutter_test/flutter_test.dart';
import 'package:surabhi/core/utils/validators.dart';

void main() {
  group('AppValidators.emailValidator', () {
    test('returns error if email is empty', () {
      expect(AppValidators.emailValidator(''), 'Please enter your email');
    });

    test('returns error if email is invalid', () {
      expect(AppValidators.emailValidator('invalidemail'), 'Please enter a valid email');
    });

    test('returns null if email is valid', () {
      expect(AppValidators.emailValidator('test@example.com'), null);
    });
  });

  group('AppValidators.passwordValidator', () {
    test('returns error if password is empty', () {
      expect(AppValidators.passwordValidator(''), 'Please enter a password');
    });

    test('returns error if password is less than 8 chars', () {
      expect(AppValidators.passwordValidator('abc12'), 'Password must be at least 8 characters');
    });

    test('returns error if password does not contain letter and number', () {
      expect(AppValidators.passwordValidator('abcdefgh'), 'Password must contain at least 1 letter and 1 number');
      expect(AppValidators.passwordValidator('12345678'), 'Password must contain at least 1 letter and 1 number');
    });

    test('returns null if password is valid', () {
      expect(AppValidators.passwordValidator('abc12345'), null);
    });
  });

  group('AppValidators.confirmPasswordValidator', () {
    test('returns error if confirm password is empty', () {
      expect(AppValidators.confirmPasswordValidator('', 'password123'), 'Please confirm your password');
    });

    test('returns error if passwords do not match', () {
      expect(AppValidators.confirmPasswordValidator('password124', 'password123'), 'Passwords do not match');
    });

    test('returns null if passwords match', () {
      expect(AppValidators.confirmPasswordValidator('password123', 'password123'), null);
    });
  });
}