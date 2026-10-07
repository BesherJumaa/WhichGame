import 'package:flutter/widgets.dart';

enum AppLanguage {
  english('en', 'English', 'English'),
  arabic('ar', 'Arabic', 'العربية');

  const AppLanguage(this.code, this.englishLabel, this.nativeLabel);

  final String code;
  final String englishLabel;
  final String nativeLabel;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}
