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
  final Widget? draftReplacement;
  final VoidCallback onPressedPublish;
  final VoidCallback onPressedDraft;
  final Widget? publishRepacement; // Note the typo in 'Repacement'
  final Widget? mobileDropdown;
  const BlogEditorAppbar({
    required this.isMobile,
    super.key,
    this.customActionWidget,
    this.draftReplacement,
    this.publishRepacement,
    required this.onPressedPublish,
    required this.onPressedDraft,
    this.mobileDropdown,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, state) {
        final isDark = state == ThemeMode.dark;

        return ResponsiveLayout(
          desktopWidget: AppBar(
            elevation: 0,
            backgroundColor: isDark ? NexusColors.darkSurface : Colors.white,
            title: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: NexusColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.signal_cellular_alt_rounded,
                        color: NexusColors.primaryBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nexus Signal',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: NexusColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Draft button - removed GestureDetector and replaced with direct draftReplacement
              draftReplacement != null
                  ? GestureDetector(
                      onTap: onPressedDraft,
                      child: draftReplacement!,
                    )
                  : GestureDetector(
                      onTap: onPressedDraft,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          border: Border.all(
                            width: 1,
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Save Draft',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),

              // Publish button
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: publishRepacement != null
                    ? GestureDetector(
                        onTap: onPressedPublish,
                        child: publishRepacement!,
                      )
                    : ElevatedButton.icon(
                        onPressed: onPressedPublish,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: NexusColors.primaryBlue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        icon: const Icon(Icons.publish),
                        label: Text(
                          'Publish',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
              const ThemeButton(),
              customActionWidget ?? const SizedBox(),
            ],
          ),
          mobileWidget: AppBar(
            // Similar changes for mobile widget
            // [Mobile actions section - same changes as desktop]
            elevation: 0,
            backgroundColor: isDark ? NexusColors.darkSurface : Colors.white,
            title: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: NexusColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.signal_cellular_alt_rounded,
                        color: NexusColors.primaryBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nexus Signal',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: NexusColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              mobileDropdown ?? const SizedBox(),
              // Draft button
              draftReplacement != null
                  ? GestureDetector(
                      onTap: onPressedDraft,
                      child: draftReplacement!,
                    )
                  : GestureDetector(
                      onTap: onPressedDraft,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          border: Border.all(
                            width: 1,
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Save Draft',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),

              // Publish button
              Container(
                margin: const EdgeInsets.only(right: 12),
                child: publishRepacement != null
                    ? GestureDetector(
                        onTap: onPressedPublish,
                        child: publishRepacement!,
                      )
                    : ElevatedButton(
                        onPressed: onPressedPublish,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: NexusColors.primaryBlue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(
                          'Publish',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
              const ThemeButton(),
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
