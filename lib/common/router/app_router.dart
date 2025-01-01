import 'package:blog/presentation/auth/screens/signin.dart';
import 'package:blog/presentation/auth/screens/signup.dart';
import 'package:blog/presentation/home/screens/home/home.dart';
import 'package:blog/presentation/home/screens/new_blog/screen/blog_editor.dart';
import 'package:blog/presentation/landing/landing.dart';
import 'package:go_router/go_router.dart';

class AppRouterConstants {
  static const String newblog = '/blog';
}

class AppRouter {
  final GoRouter router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const Landing()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUp()),
    GoRoute(path: '/signin', builder: (context, state) => SignIn()),
    GoRoute(path: '/login', builder: (context, state) => SignIn()),
    GoRoute(
        path: '${AppRouterConstants.newblog}/:uid',
        builder: (context, state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;
          return BlogEditor(
            uid: state.pathParameters['uid'] ?? '',
            title: extra?['title'],
            content: extra?['content'],
            htmlPreview: extra?['htmlPreview'],
          );
        }),
    GoRoute(
      path: '/home',
      builder: (context, state) => const Home(),
    ),
  ]);
}
