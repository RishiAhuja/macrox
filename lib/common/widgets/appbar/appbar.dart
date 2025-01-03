import 'package:blog/common/widgets/appbar/basic_button.dart';
import 'package:blog/common/widgets/appbar/nav_item.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/theme_shift/bloc/theme_cubit.dart';
import 'package:blog/presentation/theme_shift/widget/theme_button.dart';
import 'package:blog/responsive/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? isLanding;
  final Widget? customActionWidgetPrefix;
  final Widget? customActionWidgetSuffix;
  const BasicAppBar({
    super.key,
    this.isLanding,
    this.customActionWidgetPrefix,
    this.customActionWidgetSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, state) {
        final currentPath = GoRouterState.of(context).uri.toString();
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
                NavItem(
                  label: 'Home',
                  isActive: currentPath == '/home',
                  onTap: () {
                    if (currentPath != '/home') {
                      context.go('/home');
                    }
                  },
                ),
                const SizedBox(width: 20),
                NavItem(
                  label: 'Users',
                  isActive: currentPath == '/users',
                  onTap: () => context.go('/users'),
                ),
                const SizedBox(width: 20),
                NavItem(
                  label: 'Explore',
                  isActive: currentPath == '/explore',
                  onTap: () => context.go('/explore'),
                ),
              ],
            ),
            actions: [
              customActionWidgetSuffix ?? const SizedBox(),
              if (customActionWidgetPrefix != null && !isLanding!)
                const SizedBox(width: 10),
              const ThemeButton(),
              if (isLanding != null && !isLanding!) const SizedBox(width: 10),
              if (isLanding ?? true)
                const BasicButton(
                  text: 'Get Started',
                  dynamic: false,
                ),
              customActionWidgetPrefix ?? const SizedBox(),
              if (customActionWidgetPrefix != null && !isLanding!)
                const SizedBox(width: 20),
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
              customActionWidgetSuffix ?? const SizedBox(),
              if (customActionWidgetPrefix != null && !isLanding!)
                const SizedBox(width: 10),
              const ThemeButton(),
              if (isLanding != null && !isLanding!) const SizedBox(width: 10),
              if (isLanding ?? true) const BasicButton(text: 'Get Started'),
              customActionWidgetPrefix ?? const SizedBox(),
              if (customActionWidgetPrefix != null && !isLanding!)
                const SizedBox(width: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.1);
}
