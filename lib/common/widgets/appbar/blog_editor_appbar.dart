import 'package:blog/common/widgets/appbar/basic_button.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/theme_shift/bloc/theme_cubit.dart';
import 'package:blog/presentation/theme_shift/widget/theme_button.dart';
import 'package:blog/responsive/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class BlogEditorAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final Widget? customActionWidget;
  final Widget? textRepacement;
  final VoidCallback onBackButtonPressed;
  const BlogEditorAppbar({
    required this.isMobile,
    super.key,
    this.customActionWidget,
    required this.onBackButtonPressed,
    this.textRepacement,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, state) {
        return ResponsiveLayout(
          desktopWidget: AppBar(
            elevation: 0,
            backgroundColor: state == ThemeMode.dark
                ? AppColors.darkBackground
                : Colors.white,
            title: Row(
              children: [
                Text(
                  'Blog',
                  style: GoogleFonts.robotoMono(fontSize: 18),
                ),
                const SizedBox(width: 60),
                Text('Home', style: GoogleFonts.robotoMono(fontSize: 18)),
                const SizedBox(width: 20),
                Text('Users', style: GoogleFonts.robotoMono(fontSize: 18)),
                const SizedBox(width: 20),
                Text(
                  'Explore',
                  style: GoogleFonts.robotoMono(fontSize: 18),
                ),
              ],
            ),
            actions: [
              BasicButton(
                onPressed: onBackButtonPressed,
                customWidget: textRepacement ??
                    Text(
                      'Save Draft',
                      style: GoogleFonts.robotoMono(
                          color: Colors.white, fontSize: 18),
                    ),
                dynamic: true,
              ),
              const ThemeButton(),
              customActionWidget ?? const SizedBox(),
            ],
          ),
          mobileWidget: AppBar(
            elevation: 0,
            backgroundColor: state == ThemeMode.light
                ? Colors.white
                : AppColors.darkBackground,
            title: Row(
              children: [
                Text(
                  'Blog',
                  style: GoogleFonts.robotoMono(fontSize: 18),
                ),
              ],
            ),
            actions: [
              BasicButton(
                onPressed: onBackButtonPressed,
                customWidget: textRepacement,
                dynamic: true,
              ),
              customActionWidget ?? const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.1);
}
