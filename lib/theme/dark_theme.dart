import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xffFFB13D),
  secondaryHeaderColor: const Color(0xFF010d75),
  disabledColor: const Color(0xFF6f7275),
  brightness: Brightness.dark,
  hintColor: const Color(0xFFbebebe),
  cardColor: Colors.black,
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xffFFB13D),)),
  colorScheme: const ColorScheme.dark(
          primary: Color(0xffFFB13D), secondary: Color(0xffFFB13D),)
      .copyWith(error: const Color(0xffFFB13D),),
);
