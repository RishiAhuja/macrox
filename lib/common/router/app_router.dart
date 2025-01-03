import 'package:blog/presentation/auth/screens/signin.dart';
import 'package:blog/presentation/auth/screens/signup.dart';
import 'package:blog/presentation/home/screens/home/home.dart';
import 'package:blog/presentation/home/screens/new_blog/screen/blog_editor.dart';
import 'package:blog/presentation/landing/landing.dart';
import 'package:blog/presentation/profile/screen/profile_page.dart';
import 'package:blog/presentation/users/screen/users.dart';
import 'package:go_router/go_router.dart';

class AppRouterConstants {
  static const String newblog = '/blog';
  static const String profile = '/profile';
}

class AppRouter {
  final GoRouter router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const Landing()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUp()),
    GoRoute(path: '/signin', builder: (context, state) => SignIn()),
    GoRoute(path: '/login', builder: (context, state) => SignIn()),
    GoRoute(path: '/users', builder: (context, state) => const Users()),
    GoRoute(
        path: '${AppRouterConstants.newblog}/:uid',
        builder: (context, state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;
          return BlogEditor(
            userUid: extra?['userUid'] ?? '',
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
    GoRoute(
      path: '${AppRouterConstants.profile}/@:username',
      builder: (context, state) {
        final Map<String, dynamic>? extra =
            state.extra as Map<String, dynamic>?;
        return ProfilePage(
          email: extra!['email'],
          name: extra['name'],
          userUid: extra['userUid'],
          username: extra['username'],
        );
      },
    ),
  ]);
}
