import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? color;
  final Color? textColor;
  final bool dynamic;
  final double? width;
  final Widget? customWidget;
  final bool noBorder;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? iconSize;
  final double elevation;

  const BasicButton({
    super.key,
    this.onPressed,
    this.text = 'Button',
    this.color,
    this.textColor,
    this.dynamic = false,
    this.width,
    this.customWidget,
    this.noBorder = false,
    this.fontSize,
    this.padding,
    this.borderColor,
    this.borderRadius = 8.0,
    this.borderWidth = 1.0,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.iconSize,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isMobile = context.isMobile;

    // Calculate default colors
    final defaultColor =
        color ?? (isDark ? NexusColors.primaryBlue : NexusColors.primaryBlue);
    final defaultTextColor = textColor ??
        (defaultColor == Colors.transparent
            ? (isDark ? Colors.white : Colors.black87)
            : _getContrastColor(defaultColor));

    // Calculate font size
    final calculatedFontSize =
        fontSize ?? (dynamic ? (isMobile ? 14.0 : 16.0) : 14.0);

    // Calculate padding
    final calculatedPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: dynamic ? (isMobile ? 16.0 : 24.0) : 16.0,
          vertical: dynamic ? (isMobile ? 12.0 : 16.0) : 10.0,
        );

    // Build button content
    Widget buttonContent;

    if (isLoading) {
      buttonContent = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(defaultTextColor),
        ),
      );
    } else if (customWidget != null) {
      buttonContent = customWidget!;
    } else {
      // Standard text/icon button
      List<Widget> rowChildren = [];

      // Add leading icon if provided
      if (leadingIcon != null) {
        rowChildren.add(Icon(
          leadingIcon,
          color: defaultTextColor,
          size: iconSize ?? calculatedFontSize + 4,
        ));
        rowChildren.add(SizedBox(width: 8));
      }

      // Add text
      rowChildren.add(Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          color: defaultTextColor,
          fontSize: calculatedFontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ));

      // Add trailing icon if provided
      if (trailingIcon != null) {
        rowChildren.add(SizedBox(width: 8));
        rowChildren.add(Icon(
          trailingIcon,
          color: defaultTextColor,
          size: iconSize ?? calculatedFontSize + 4,
        ));
      }

      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowChildren,
      );
    }

    // Create button with Material for better interaction feedback
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: elevation,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          padding: calculatedPadding,
          decoration: BoxDecoration(
            color: defaultColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: noBorder
                ? null
                : Border.all(
                    color: borderColor ?? defaultColor,
                    width: borderWidth,
                  ),
          ),
          child: Center(child: buttonContent),
        ),
      ),
    );
  }

  // Helper method to determine text color based on background color
  Color _getContrastColor(Color backgroundColor) {
    if (backgroundColor == Colors.transparent) {
      return Colors.black87;
    }

    // Calculate luminance to determine if text should be light or dark
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
  }
}
