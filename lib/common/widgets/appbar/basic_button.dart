import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final Color? color;
  final bool? dynamic;
  final double? width;
  final Widget? customWidget;
  final bool? enableBorder;
  const BasicButton(
      {super.key,
      this.onPressed,
      this.text,
      this.color,
      this.dynamic,
      this.width,
      this.customWidget,
      this.enableBorder});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed ?? () {},
        child: width != null
            ? Container(
                alignment: Alignment.center,
                width: width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: color ??
                      (context.isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight),
                  borderRadius: BorderRadius.circular(4),
                  // border: Border.all(
                  //     width: 10,
                  //     color: (enableBorder ?? false)
                  //         ? color ??
                  //             (context.isDark
                  //                 ? AppColors.primaryDark
                  //                 : AppColors.primaryLight)
                  //         : Colors.transparent)
                ),
                child: customWidget ??
                    Text(
                      text ?? 'Button',
                      style: GoogleFonts.robotoMono(
                        color: Colors.black,
                        fontSize: (dynamic ?? false)
                            ? (context.isMobile ? 18 : 24)
                            : 18,
                      ),
                    ))
            : Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    // border: Border.all(
                    //     color: (enableBorder ?? false)
                    //         ? color ??
                    //             (context.isDark
                    //                 ? AppColors.primaryDark
                    //                 : AppColors.primaryLight)
                    //         : Colors.transparent),
                    color: color ??
                        (context.isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight),
                    borderRadius: BorderRadius.circular(4)),
                child: customWidget ??
                    Text(
                      text ?? 'Button',
                      style: GoogleFonts.robotoMono(
                        color: Colors.black,
                        fontSize: (dynamic ?? false)
                            ? (context.isMobile ? 18 : 24)
                            : 18,
                      ),
                    )));
  }
}
