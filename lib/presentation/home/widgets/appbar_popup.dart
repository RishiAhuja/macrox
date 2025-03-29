import 'package:blog/common/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget appBarInfoPopup(
    bool isDark, String name, String username, String email, String id) {
  // Return a simple IconButton that navigates directly to the profile page
  return Builder(builder: (context) {
    return IconButton(
      icon: const Icon(Icons.supervised_user_circle_sharp),
      tooltip: 'View Profile',
      onPressed: () {
        context.go('${AppRouterConstants.profile}/@$username');
      },
    );
  });
}
