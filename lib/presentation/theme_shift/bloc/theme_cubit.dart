import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  @override
  fromJson(Map<String, dynamic> json) {
    print('fromJson ${json['themeMode']}');
    return ThemeMode.values[json['themeMode'] as int];
  }

  @override
  Map<String, dynamic>? toJson(state) {
    print('toJson ${state.index}');
    return {'themeMode': state.index};
  }

  void updateTheme(ThemeMode mode) => emit(mode);
}
