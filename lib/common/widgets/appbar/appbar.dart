import 'package:blog/common/helper/extensions/is_dark.dart';
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
        final isDark = context.isDark;
        final currentPath = GoRouterState.of(context).uri.toString();

        return ResponsiveLayout(
          desktopWidget: _buildDesktopAppBar(context, isDark, currentPath),
          mobileWidget: _buildMobileAppBar(context, isDark, currentPath),
        );
      },
    );
  }

  Widget _buildDesktopAppBar(BuildContext context, isDark, currentPath) {
    return AppBar(
      backgroundColor: isDark ? NexusColors.darkBackground : Colors.white,
      title: Row(
        children: [
          _buildLogo(isDark),
          const Spacer(),
        ],
      ),
      actions: [
        _buildNetworkStatus(isDark),
        const ThemeButton(),
        customActionWidgetPrefix ?? const SizedBox(),
      ],
    );
  }

  Widget _buildMobileAppBar(
      BuildContext context, bool isDark, String currentPath) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? NexusColors.darkBackground : Colors.white,
      title: Row(
        children: [
          _buildLogo(isDark, isMobile: true),
        ],
      ),
      actions: [
        if (!isLanding!) _buildNetworkStatus(isDark, isMobile: true),
        customActionWidgetSuffix ?? const SizedBox(),
        if (customActionWidgetPrefix != null && !isLanding!)
          const SizedBox(width: 6),
        const ThemeButton(),
        if (isLanding ?? true)
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 12),
            child: _buildCtaButton(isDark, isMobile: true),
          ),
        customActionWidgetPrefix ?? const SizedBox(),
        const SizedBox(width: 8),
      ],
      leading: (isLanding ?? false)
          ? null
          : IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
    );
  }

  Widget _buildLogo(bool isDark, {bool isMobile = false}) {
    return Row(
      children: [
        Container(
          width: isMobile ? 24 : 32,
          height: isMobile ? 24 : 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                NexusColors.gradientStart,
                NexusColors.gradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: NexusColors.primaryBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.hub,
            color: Colors.white,
            size: isMobile ? 14 : 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'NEXUS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: isMobile ? 10 : 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkStatus(bool isDark, {bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: NexusColors.signalGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NexusColors.signalGreen.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
          if (!isMobile) const SizedBox(width: 8),
          if (!isMobile)
            Text(
              'Connected',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(bool isDark, {bool isMobile = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NexusColors.gradientStart,
            NexusColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: NexusColors.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: 8,
            ),
            child: Text(
              isMobile ? 'Join' : 'Join Nexus',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.1);
}
