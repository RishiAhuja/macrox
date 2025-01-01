import 'package:blog/presentation/theme_shift/bloc/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, state) {
        return IconButton(
          onPressed: () => state == ThemeMode.light
              ? (context.read<ThemeCubit>().updateTheme(ThemeMode.dark))
              : context.read<ThemeCubit>().updateTheme(ThemeMode.light),
          icon: Icon(state == ThemeMode.light
              ? Icons.nightlight_round
              : Icons.wb_sunny_rounded),
        );
      },
    );
  }
}
