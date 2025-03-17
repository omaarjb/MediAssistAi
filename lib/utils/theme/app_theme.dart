import 'package:dr_ai/utils/constant/color.dart';
import 'package:dr_ai/utils/constant/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: const Color.fromARGB(255, 2, 89, 219),
        selectionColor: const Color.fromARGB(255, 2, 89, 219).withOpacity(0.3),
        selectionHandleColor: const Color.fromARGB(255, 2, 89, 219),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll(
              const Color.fromARGB(255, 2, 89, 219).withOpacity(0.1)),
          foregroundColor:
              const WidgetStatePropertyAll(Color.fromARGB(255, 2, 89, 219)),
          side: WidgetStatePropertyAll(BorderSide(
              width: 3,
              color: const Color.fromARGB(255, 2, 89, 219).withOpacity(0.3))),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          fixedSize: WidgetStatePropertyAll(Size(95.w, 50.h)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          overlayColor:
              WidgetStatePropertyAll(ColorManager.white.withOpacity(0.2)),
          foregroundColor: const WidgetStatePropertyAll(ColorManager.white),
          backgroundColor:
              const WidgetStatePropertyAll(Color.fromARGB(255, 2, 89, 219)),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          fixedSize: WidgetStatePropertyAll(Size(double.maxFinite, 48.h)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: const WidgetStatePropertyAll(ColorManager.white),
        fillColor: const WidgetStatePropertyAll(ColorManager.white),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.dm)),
        side: BorderSide(color: ColorManager.grey, width: 1.dm),
      ),
      iconTheme: const IconThemeData(color: ColorManager.black),
      switchTheme: const SwitchThemeData(
        trackOutlineColor:
            WidgetStatePropertyAll(Color.fromARGB(255, 2, 89, 219)),
        thumbColor: WidgetStatePropertyAll(ColorManager.white),
        trackColor: WidgetStatePropertyAll(Color.fromARGB(255, 2, 89, 219)),
        thumbIcon: WidgetStatePropertyAll(
            Icon(Icons.light_mode, color: ColorManager.white)),
      ),
      fontFamily: FontFamilyManager.poppins,
      useMaterial3: true,
      scaffoldBackgroundColor: ColorManager.white,
      appBarTheme: AppBarTheme(
        titleTextStyle: TextStyle(
            color: ColorManager.black,
            fontSize: 20.spMin,
            fontWeight: FontWeight.w500),
        backgroundColor: const Color.fromARGB(255, 2, 89, 219),
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: ColorManager.black),
        elevation: 0,
        shadowColor: ColorManager.black.withOpacity(0.3),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
            fontSize: 24.spMin,
            color: ColorManager.black,
            fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(
            fontSize: 16.spMin,
            color: ColorManager.black,
            fontWeight: FontWeight.w500),
        bodySmall: TextStyle(
            fontSize: 14.spMin,
            color: ColorManager.grey,
            fontWeight: FontWeight.w400),
        displayLarge: TextStyle(
            fontSize: 24.spMin,
            color: const Color.fromARGB(255, 2, 89, 219),
            fontWeight: FontWeight.w600),
        displayMedium: TextStyle(
            fontSize: 16.spMin,
            color: ColorManager.white,
            fontWeight: FontWeight.w600),
        displaySmall: TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: const Color.fromARGB(255, 2, 89, 219),
          color: const Color.fromARGB(255, 2, 89, 219),
          fontSize: 14.spMin,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(fontSize: 14.spMin),
        filled: true,
        fillColor: ColorManager.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
              width: 1.7.w, color: const Color.fromARGB(255, 2, 89, 219)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(width: 1.7.w, color: ColorManager.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(width: 2.w, color: ColorManager.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(width: 2.w, color: ColorManager.error),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: const Color.fromARGB(255, 2, 89, 219),
        selectionColor: const Color.fromARGB(255, 2, 89, 219).withOpacity(0.3),
        selectionHandleColor: const Color.fromARGB(255, 2, 89, 219),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll(
              const Color.fromARGB(255, 2, 89, 219).withOpacity(0.1)),
          foregroundColor:
              const WidgetStatePropertyAll(Color.fromARGB(255, 2, 89, 219)),
          side: WidgetStatePropertyAll(BorderSide(
              width: 3,
              color: const Color.fromARGB(255, 2, 89, 219).withOpacity(0.3))),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          fixedSize: WidgetStatePropertyAll(Size(95.w, 50.h)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          overlayColor:
              WidgetStatePropertyAll(ColorManager.white.withOpacity(0.2)),
          foregroundColor: const WidgetStatePropertyAll(ColorManager.white),
          backgroundColor:
              const WidgetStatePropertyAll(Color.fromARGB(255, 2, 89, 219)),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          fixedSize: WidgetStatePropertyAll(Size(double.maxFinite, 48.h)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: const WidgetStatePropertyAll(ColorManager.white),
        fillColor: const WidgetStatePropertyAll(ColorManager.white),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.dm)),
        side: BorderSide(color: ColorManager.grey, width: 1.dm),
      ),
      iconTheme: const IconThemeData(color: ColorManager.white),
      switchTheme: const SwitchThemeData(
        trackOutlineColor:
            WidgetStatePropertyAll(Color.fromARGB(255, 2, 89, 219)),
        thumbColor: WidgetStatePropertyAll(ColorManager.black),
        trackColor: WidgetStatePropertyAll(Color.fromARGB(255, 2, 89, 219)),
        thumbIcon: WidgetStatePropertyAll(
            Icon(Icons.dark_mode, color: ColorManager.black)),
      ),
      fontFamily: FontFamilyManager.poppins,
      useMaterial3: true,
      scaffoldBackgroundColor: ColorManager.black,
      appBarTheme: AppBarTheme(
        titleTextStyle: TextStyle(
            color: ColorManager.white,
            fontSize: 20.spMin,
            fontWeight: FontWeight.w500),
        backgroundColor: const Color.fromARGB(255, 2, 89, 219),
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: ColorManager.white),
        elevation: 0,
        shadowColor: ColorManager.white.withOpacity(0.3),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
            fontSize: 24.spMin,
            color: ColorManager.white,
            fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(
            fontSize: 16.spMin,
            color: ColorManager.white,
            fontWeight: FontWeight.w500),
        bodySmall: TextStyle(
            fontSize: 14.spMin,
            color: ColorManager.grey,
            fontWeight: FontWeight.w400),
        displayLarge: TextStyle(
            fontSize: 24.spMin,
            color: const Color.fromARGB(255, 2, 89, 219),
            fontWeight: FontWeight.w600),
        displayMedium: TextStyle(
            fontSize: 16.spMin,
            color: ColorManager.white,
            fontWeight: FontWeight.w600),
        displaySmall: TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: const Color.fromARGB(255, 2, 89, 219),
          color: const Color.fromARGB(255, 2, 89, 219),
          fontSize: 14.spMin,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(fontSize: 14.spMin),
        filled: true,
        fillColor: ColorManager.black,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
              width: 1.7.w, color: const Color.fromARGB(255, 2, 89, 219)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(width: 1.7.w, color: ColorManager.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(width: 2.w, color: ColorManager.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(width: 2.w, color: ColorManager.error),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      ),
    );
  }
}
