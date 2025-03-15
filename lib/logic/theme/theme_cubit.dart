import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

enum ThemeModeState { light, dark }

class ThemeCubit extends Cubit<ThemeModeState> {
  ThemeCubit() : super(ThemeModeState.light);

  void toggleTheme() {
    emit(state == ThemeModeState.light
        ? ThemeModeState.dark
        : ThemeModeState.light);
  }

  // Add a getter for ThemeMode
  ThemeMode get themeMode {
    return state == ThemeModeState.light ? ThemeMode.light : ThemeMode.dark;
  }
}
