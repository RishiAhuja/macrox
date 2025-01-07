import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlogPreview extends StatelessWidget {
  const BlogPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final String? username =
        GoRouterState.of(context).pathParameters['username'];
    final String? uid = GoRouterState.of(context).pathParameters['uid'];

    return Scaffold(
      body: username != null && uid != null
          ? Center(
              child: Text('Blog by $username with ID: $uid'),
            )
          : const Center(
              child: Text('Invalid blog URL'),
            ),
    );
  }
}
