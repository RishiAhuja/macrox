import 'package:blog/core/configs/constants/app_constants/constants.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget mobileWidget;
  final Widget desktopWidget;

  const ResponsiveLayout({
    super.key,
    required this.mobileWidget,
    required this.desktopWidget,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return constraints.maxWidth < Constants.mobileWidth
          ? widget.mobileWidget
          : widget.desktopWidget;
    });
  }
}

//use aspect ratio