// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:su_event/main.dart';
import 'package:su_event/starting_page.dart';

void main() {
  group('LoginRegisterValidation Logic', () {
    test('Returns null (valid) for emails ending with sabanciuniv.edu', () {
      final result = LoginRegisterValidation(
          'student@sabanciuniv.edu',
          'Enter Su-mail',
          false
      );
      expect(result, null);
    });

    test('Returns error message for non-university email (e.g. gmail)', () {
      final result = LoginRegisterValidation(
          'student@gmail.com',
          'Enter Su-mail',
          false
      );
      expect(result, 'Invalid Email (please use only *****@sabanciuniv.edu mails)');
    });

    test('Returns error for short password', () {
      final result = LoginRegisterValidation(
          '123',
          'Enter password',
          true // isPassword = true
      );
      expect(result, 'Password too short (at least 6 characters)');
    });

    test('Returns null (valid) for acceptable password', () {
      final result = LoginRegisterValidation(
          '123456',
          'Enter password',
          true
      );
      expect(result, null);
    });
  });
}
